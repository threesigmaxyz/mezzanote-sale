import csv
import json
import requests
from web3 import Web3


"""
This functions saves the owners to a csv file
"""
def SaveOwnersToCSV(owners):
    with open('Data/OwnersSnapshot.csv', 'w') as f:
        writer = csv.DictWriter(f)
        writer.writerows(owners)


"""
This function assigns all tokenIds a list of all
the owners with different blocknumbers
"""
def FindAndSaveOwnersWithBlockNumber(allEvents):     
    data = {}
    for event in allEvents:
        if event["tokenId"] not in data:
            data[event["tokenId"]] = {}
            
        data[event["tokenId"]][event["blockNumber"]] = event["to"]

    with open('Data/OwnersByTokenId.json', 'w') as convert_file:
        convert_file.write(json.dumps(data))


def SaveOwnersSnapshot(desiredTimestamp, etherscanApiKey):
    """
    This function filters the owners in data\OwnersByTokenId
    by selecting the owner with the biggest blocknumber that
    is smaller than the desired one
    """

    r = requests.get(f"https://api.etherscan.io/api?module=block&action=getblocknobytime&timestamp={desiredTimestamp}&closest=before&apikey={etherscanApiKey}")
    desiredBlocknumber = r.json().get("result")
    
    with open('Data/OwnersByTokenId.json', 'r') as f:
        data = json.load(f)

    ownerAmount = {}
    for tokenId, owners in data.items():
        owner = False
        for blockNumber, currOwner in owners.items():
            if blockNumber <= desiredBlocknumber:
                owner = currOwner

        if owner is False:
            continue

        ownerAmount[owner] = ownerAmount.get(owner, 0) + 1

    ownersSnapshot = []
    for owner in ownerAmount:
        ownersSnapshot.append(
                            {   
                                "owner": owner,
                                "amount": ownerAmount.get(owner)
                                
                            })  
    ownersSnapshot = sorted(ownersSnapshot, key=lambda d: d['amount'], reverse=True) 
    

    SaveOwnersToCSV(ownersSnapshot)
