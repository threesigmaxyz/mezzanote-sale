// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Script.sol";

import "src/MezzanoteSale.sol";

contract DeploymentScript is Script {
    /// @notice Change these constants to your desired values
    string private constant DESIRED_NAME = "MezzanoteSale"; // TODO change to desired Name
    string private constant DESIRED_SYMBOL = "MS"; // TODO change to desired Symbol
    string private constant METADATA_URI_HOST = "https://mezzanote.com"; // TODO change to desired Metadata uri host

    uint64 private constant SALE_START = 99;
    bytes32 private constant WHITELIST_SALE_ROOT = bytes32(uint256(99));
    uint256 private constant INITIAL_MAX_MINT = 555;

    function run() external {
        // record calls and contract creations made by our script contract
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // deploy MezzanoteSale contract
        new MezzanoteSale(
            DESIRED_NAME,                    
            DESIRED_SYMBOL,                                         
            SALE_START, 
            WHITELIST_SALE_ROOT,                          
            METADATA_URI_HOST,
            INITIAL_MAX_MINT                        
        );

        // stop recording calls
        vm.stopBroadcast();
    }
}
