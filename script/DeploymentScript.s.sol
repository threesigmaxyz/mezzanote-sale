// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Script.sol";

import "src/DefimonsStarterMonsters.sol";

contract DeploymentScript is Script {
    /// @notice Change these constants to your desired values

    uint256 private constant INITIAL_MAX_MINT = 4500;

    uint64 private constant WHITELIST_SALE_START = 99;
    uint64 private constant WHITELIST_SALE_FINISH = 99;
    uint64 private constant WHITELIST_SALE_PRICE = 99;
    bytes32 private constant WHITELIST_SALE_ROOT = bytes32(uint256(99));
    bool private constant WHITELIST_SALE_HAS_MAX_MINT = false;
    uint40 private constant WHITELIST_SALE_MAX_MINT = 0;

    uint64 private constant PUBLIC_SALE_START = 99;
    uint64 private constant PUBLIC_SALE_FINISH = 99;
    uint64 private constant PUBLIC_SALE_PRICE = 99;
    uint8 private constant PUBLIC_SALE_LIMIT = 3;
    bool private constant PUBLIC_SALE_HAS_MAX_MINT = false;
    uint40 private constant PUBLIC_SALE_MAX_MINT = 0;

    string private constant DESIRED_NAME = "Defimons Starter Monsters"; // TODO change to desired Name
    string private constant DESIRED_SYMBOL = "MONS"; // TODO change to desired Symbol
    address private constant LAYER_ZERO_ENDPOINT = 0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706; // TODO change to desired network LayerZero endpoint
    string private constant METADATA_URI_HOST = "https://defimons.com"; // TODO change to desired Metadata uri host

    function run() external {
        // record calls and contract creations made by our script contract
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // deploy DefimonsStarterMonsters contract
        DefimonsStarterMonsters defimons = new DefimonsStarterMonsters(
            DESIRED_NAME,                    
            DESIRED_SYMBOL,                                         
            LAYER_ZERO_ENDPOINT,                            
            METADATA_URI_HOST,
            INITIAL_MAX_MINT                        
        );

        // add whitelist sale
        defimons.addSale(
            WHITELIST_SALE_START,
            WHITELIST_SALE_FINISH,
            0,
            WHITELIST_SALE_PRICE,
            true,
            WHITELIST_SALE_ROOT,
            WHITELIST_SALE_HAS_MAX_MINT,
            WHITELIST_SALE_MAX_MINT
        );

        // add public sale
        defimons.addSale(
            PUBLIC_SALE_START,
            PUBLIC_SALE_FINISH,
            PUBLIC_SALE_LIMIT,
            PUBLIC_SALE_PRICE,
            false,
            bytes32(0),
            PUBLIC_SALE_HAS_MAX_MINT,
            PUBLIC_SALE_MAX_MINT
        );

        // stop recording calls
        vm.stopBroadcast();
    }
}
