// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Script.sol";

import "src/MezzanoteSale.sol";

contract DeploymentScript is Script {
    /// @notice Change these constants to your desired values
    address private constant DESIRED_TOKEN_ADDRESS = address(1);
    uint64 private constant SALE_START = 99;

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
        new MezzanoteSale(
            DESIRED_TOKEN_ADDRESS,                                        
            SALE_START, 
            whitelistRoot_                    
        );

        // stop recording calls
        vm.stopBroadcast();
    }
}
