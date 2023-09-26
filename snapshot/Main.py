from EventHandler import EventHandler
from Owners import FindAndSaveOwnersWithBlockNumber, SaveOwnersSnapshot
from decouple import config

# SIM2
CONTRACT_ADDRESS_1 = "0x243d558472eF7030aFe3675Bb0a6f9Fb7cE39E13"
CREATION_BLOCK_1 = 16200347
# Dropicall
CONTRACT_ADDRESS_2 = "0x8b82D758a95c84Bc5476244f91e9AC6478d2a8B0"
CREATION_BLOCK_2 = 14499075
# WHITEHEARTS
CONTRACT_ADDRESS_3 = "0x4577fcfB0642afD21b5f2502753ED6D497B830E9"
CREATION_BLOCK_3 = 15737633
# SIMCARD1
CONTRACT_ADDRESS_4 = "0x8b6DCfB251bef4953cF3f3A8C66Af870e6b7466e"
CREATION_BLOCK_4 = 15455843
# UnchainedMilady
CONTRACT_ADDRESS_5 = "0x25f23845F9F278338138B9224b62dF7DF5398A4d"
CREATION_BLOCK_5 = 17369732

TOBLOCK = 18220350	 # Timistamp for holder's snapshot (Sep-26-2023 01:48:47 PM +UTC)
ETHERSCAN_API_KEY = config('ETHERSCAN_KEY')
NODE_URL = config('RPC_URL_MAINNET')


def addEvent(allEvents, event): 
    tokenId = event.get("args").get("tokenId")
    allEvents.append({"blockNumber" : event.get("blockNumber"),
                    "transactionId" : event.get("transactionIndex"),
                    "logIndex" : event.get("logIndex"), 
                    "tokenId" : tokenId,
                    "from" : event.get("args").get("from"), 
                    "to" : event.get("args").get("to")})


def main():

    eventList = ["Transfer"]
    updateFunctionList = [addEvent]

    eventHandler1 = EventHandler(CONTRACT_ADDRESS_1, CREATION_BLOCK_1, NODE_URL, ETHERSCAN_API_KEY)
    allEvents1 = eventHandler1.GetAndSaveOrderedEvents(eventList, updateFunctionList)
    allEvents1 = eventHandler1.GetEventsFromCsv()

    eventHandler2 = EventHandler(CONTRACT_ADDRESS_2, CREATION_BLOCK_2, NODE_URL, ETHERSCAN_API_KEY)
    allEvents2 = eventHandler2.GetAndSaveOrderedEvents(eventList, updateFunctionList)
    allEvents2 = eventHandler2.GetEventsFromCsv()

    eventHandler3 = EventHandler(CONTRACT_ADDRESS_3, CREATION_BLOCK_3, NODE_URL, ETHERSCAN_API_KEY)
    allEvents3 = eventHandler3.GetAndSaveOrderedEvents(eventList, updateFunctionList)
    allEvents3 = eventHandler3.GetEventsFromCsv()

    eventHandler4 = EventHandler(CONTRACT_ADDRESS_4, CREATION_BLOCK_4, NODE_URL, ETHERSCAN_API_KEY)
    allEvents4 = eventHandler4.GetAndSaveOrderedEvents(eventList, updateFunctionList)
    allEvents4 = eventHandler4.GetEventsFromCsv()

    eventHandler5 = EventHandler(CONTRACT_ADDRESS_5, CREATION_BLOCK_5, NODE_URL, ETHERSCAN_API_KEY)
    allEvents5 = eventHandler5.GetAndSaveOrderedEvents(eventList, updateFunctionList) 
    allEvents5 = eventHandler5.GetEventsFromCsv()

    timestamp = eventHandler1.w3.eth.getBlock(TOBLOCK).timestamp

    open('Data/OwnersSnapshot.csv', 'w+').close() # Reset 'OwnersSnapshot.csv' file

    FindAndSaveOwnersWithBlockNumber(eventHandler1.contractAddress, allEvents1)
    SaveOwnersSnapshot(eventHandler1.contractAddress, timestamp, ETHERSCAN_API_KEY)

    FindAndSaveOwnersWithBlockNumber(eventHandler2.contractAddress, allEvents2)
    SaveOwnersSnapshot(eventHandler2.contractAddress, timestamp, ETHERSCAN_API_KEY)

    FindAndSaveOwnersWithBlockNumber(eventHandler3.contractAddress, allEvents3)
    SaveOwnersSnapshot(eventHandler3.contractAddress, timestamp, ETHERSCAN_API_KEY)

    FindAndSaveOwnersWithBlockNumber(eventHandler4.contractAddress, allEvents4)
    SaveOwnersSnapshot(eventHandler4.contractAddress, timestamp, ETHERSCAN_API_KEY)

    FindAndSaveOwnersWithBlockNumber(eventHandler5.contractAddress, allEvents5)
    SaveOwnersSnapshot(eventHandler5.contractAddress, timestamp, ETHERSCAN_API_KEY)
    


if __name__ == "__main__":
    main()