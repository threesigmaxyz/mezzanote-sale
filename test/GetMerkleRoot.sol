// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";

contract GetMerkleRoot is Test {
    bytes32 private whitelistRoot_;

    function test_getMerkleRoot() public {
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "src/dependencies/threesigma-contracts/scripts/MerkleTreeProvider.py";
        inputs[2] = "output_merkle_root";
        inputs[3] = "snapshot/Data/OwnersSnapshot.csv";

        bytes memory res = vm.ffi(inputs);
        whitelistRoot_ = abi.decode(res, (bytes32));

        console.log("MerkleRoot");
        console.logBytes32(whitelistRoot_);
    }
}
