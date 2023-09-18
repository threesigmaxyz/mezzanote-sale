from web3 import Web3
import requests
import os
import csv
from decouple import config


class EventHandler:
    def __init__(self, contractAddress, creationBlock, nodeUrl, etherscanApiKey):
        self.nodeUrl = nodeUrl
        self.etherscanApiKey = etherscanApiKey
        self.contractAddress = contractAddress
        self.creationBlock = creationBlock
        self.blockWindow = 10000
        self.w3 = Web3(Web3.HTTPProvider(self.nodeUrl))
        os.makedirs("FetchedContract", exist_ok=True)
        os.makedirs("Data", exist_ok=True)
        self.abi = self.__GetContractAbi()
        self.contract = self.w3.eth.contract(address=self.contractAddress, abi=self.abi)
        self.allEvents = []
        
    
    """
    This function is not necessary but extracts the 
    code of the contract with etherscan
    """
    def GetContractCode(contractAddress):
        r = requests.get('https://api.etherscan.io/api?module=contract&action=getsourcecode&address=' + 
                        contractAddress) 
        sourceCode = str(r.json().get("result")[0].get("SourceCode"))
        with open("FetchedContract/Contract.sol", "w") as f:
            f.write(sourceCode)


    """
    This function fetches the abi of the contract from etherscan
    """

    # verify abi
    def __GetContractAbi(self):
        r = requests.get('https://api.etherscan.io/api?module=contract&action=getabi&address=' + 
                    self.contractAddress) 
        self.abi = str(r.json().get("result"))
        with open("FetchedContract/Abi.json", "w") as f:
            f.write(self.abi)

        return self.abi


    """
    This function gets events between 2 blocks
    """
    def __GetEvents(self, eventName, fromBlock, toBlock):
        return self.contract.events[eventName].createFilter(
                        fromBlock = fromBlock, 
                        toBlock = toBlock).get_all_entries()
            

    """
    This function returns all the events if the events csv 
    already exists. If it does not, it sets up the abi and contract,
    gets all the events and stores them ordered by blocknumber, transaction index
    and log index in a csv file
    """
    def GetAndSaveOrderedEvents(self, eventList, updateFunctionList):            
        self.__GetAllEvents(eventList, updateFunctionList)
        sorted(self.allEvents, key = lambda event: (event['blockNumber'], 
                                        event['transactionId'], 
                                        event['logIndex']))
        self.__SaveEventsToCSV()

        return self.allEvents  
    
    
    def GetEventsFromCsv(self):
        with open('Data/Events.csv', 'r') as f:
            for row in csv.DictReader(f, skipinitialspace=True):
                self.allEvents.append({k: v for k, v in row.items()})
        return self.allEvents


    """
    This function saves the events to a csv file
    """
    def __SaveEventsToCSV(self):
        with open('Data/Events.csv', 'a+') as f:
            writer = csv.DictWriter(f, fieldnames=dict.keys(self.allEvents[0]))
            writer.writeheader()
            for event in self.allEvents:
                writer.writerow(event)


    """
    This function fetches all events 
    in windows of size globals.blockWindow. 
    Each time a batch of events contained in the eventList variable
    is fetched, it calls the corresponding updateFunctionList
    so the user can store the event information in allEvents
    """
    def __GetAllEvents(self, eventList, updateFunctionList):
        latestBlock = self.w3.eth.get_block('latest').number 
        currentFromBlock = self.creationBlock 
        blockWindow = self.blockWindow
        events = {}
        while currentFromBlock < latestBlock:
            try:
                currentToBlock = min(currentFromBlock + blockWindow, latestBlock)

                for eventName in eventList:
                    events[eventName] = self.__GetEvents(
                        eventName, currentFromBlock, currentToBlock)

                for idx, eventName in enumerate(eventList):
                    for event in events[eventName]:
                        updateFunctionList[idx](self.allEvents, event)
                
                currentFromBlock += blockWindow
            except Exception as e:
                print(e) 
                blockWindow = int(blockWindow*0.9) 
            print("block: ", currentFromBlock)
