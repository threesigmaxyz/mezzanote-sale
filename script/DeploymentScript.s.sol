// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Script.sol";

import "src/MezzanoteSale.sol";

contract DeploymentScript is Script {
    /// @notice Change these constants to your desired values
    address private constant DESIRED_TOKEN_ADDRESS = address(1);

    uint64 private constant SALE_START = 99;
    bytes32 private constant WHITELIST_SALE_ROOT = bytes32(uint256(99));

    function run() external {
        // record calls and contract creations made by our script contract
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // deploy MezzanoteSale contract
        new MezzanoteSale(
            DESIRED_TOKEN_ADDRESS,                                        
            SALE_START, 
            WHITELIST_SALE_ROOT                    
        );

        // stop recording calls
        vm.stopBroadcast();
    }
}
