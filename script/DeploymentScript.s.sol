// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Script.sol";

import "src/MezzanotteSale.sol";

contract DeploymentScript is Script {
    /// @notice Change these constants to your desired values
    address private constant DESIRED_TOKEN_ADDRESS = address(1);
    uint64 private constant SALE_START = 1_695_744_000; // Tuesday, September 26th 2023, 12:00:00 pm
    uint64 private constant SALE_DURATION = 3 hours;
    uint64 private constant SALE_PRICE = 0.069 ether;

    bytes32 private whitelistRoot_;

    function setUp() public {
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "src/dependencies/threesigma-contracts/scripts/MerkleTreeProvider.py";
        inputs[2] = "output_merkle_root";
        inputs[3] = "snapshot/Data/OwnersSnapshot.csv";

        bytes memory res = vm.ffi(inputs);
        whitelistRoot_ = abi.decode(res, (bytes32));
    }

    function run() external {
        // record calls and contract creations made by our script contract
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // deploy MezzanoteSale contract
        new MezzanotteSale(
            DESIRED_TOKEN_ADDRESS,                                        
            SALE_START, 
            whitelistRoot_,
            SALE_DURATION,
            SALE_PRICE
        );

        // stop recording calls
        vm.stopBroadcast();
    }
}
