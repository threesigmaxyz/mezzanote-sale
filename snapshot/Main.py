from EventHandler import EventHandler
from Owners import FindAndSaveOwnersWithBlockNumber, SaveOwnersSnapshot
from decouple import config


CONTRACT_ADDRESS = "0x6e1404A557850551EDaA9fD1311c9297BAF7bD52"
CREATION_BLOCK = 15308312 # Creation Block
TOBLOCK = 16869663	 # Current block
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
    eventHandler = EventHandler(CONTRACT_ADDRESS, CREATION_BLOCK, NODE_URL, ETHERSCAN_API_KEY)
    eventList = ["Transfer"]
    updateFunctionList = [addEvent]
    allEvents = eventHandler.GetAndSaveOrderedEvents(eventList, updateFunctionList) 
    allEvents = eventHandler.GetEventsFromCsv()
    timestamp = eventHandler.w3.eth.getBlock(TOBLOCK).timestamp
    FindAndSaveOwnersWithBlockNumber(allEvents)
    SaveOwnersSnapshot(timestamp, ETHERSCAN_API_KEY)


if __name__ == "__main__":
    main()