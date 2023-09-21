// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@forge-std/Test.sol";

contract MerkleTreeTest is Test {
    string filename;
    uint256 addressesLength;
    address[] addresses;
    bytes32 root;
    uint32[] proofsLength;
    bytes32[][] merkleProofs;

    function setMerkleTree(string memory _filename) internal {
        filename = _filename;
        merkleTreeSetup();
    }

    function merkleTreeSetup() internal {
        getAddressesAndAmounts();
        getMerkleRoot();
        getMerkleProofLength();
        getMerkleProofs();
    }

    function getAddressesAndAmounts() private {
        delete addresses;
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "src/dependencies/threesigma-contracts/scripts/MerkleTreeProvider.py";
        inputs[2] = "output_addresses_amounts";
        inputs[3] = filename;

        bytes memory res = vm.ffi(inputs);

        uint8 _offset = 20;
        bytes20 addressAux;
        for (uint256 i = 32; i <= res.length + 32 - _offset; i = i + _offset) {
            assembly {
                addressAux := mload(add(res, i))
            }
            addresses.push(address(addressAux));
        }
    }

    function getMerkleRoot() private {
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "src/dependencies/threesigma-contracts/scripts/MerkleTreeProvider.py";
        inputs[2] = "output_merkle_root";
        inputs[3] = filename;

        bytes memory res = vm.ffi(inputs);
        root = abi.decode(res, (bytes32));
    }

    function getMerkleProofLength() private {
        delete proofsLength;
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "src/dependencies/threesigma-contracts/scripts/MerkleTreeProvider.py";
        inputs[2] = "output_merkle_proofs_length";
        inputs[3] = filename;

        bytes memory res = vm.ffi(inputs);
        bytes32 aux;
        uint8 _offset = 4;
        for (uint256 i = 32; i <= res.length + 32 - _offset; i = i + _offset) {
            assembly {
                aux := mload(add(res, i))
            }
            proofsLength.push(uint32(bytes4(aux)));
        }
    }

    function getMerkleProofs() private {
        delete merkleProofs;
        string[] memory inputs = new string[](4);
        // change this to locate files
        inputs[0] = "python3";
        inputs[1] = "src/dependencies/threesigma-contracts/scripts/MerkleTreeProvider.py";
        inputs[2] = "output_merkle_proofs";
        inputs[3] = filename;

        bytes memory res = vm.ffi(inputs);

        bytes32 aux;
        uint256 offset = 0;

        for (uint256 i = 0; i < proofsLength.length; i++) {
            bytes32[] memory proof = new bytes32[](proofsLength[i]);

            for (uint256 j = 0; j < proofsLength[i]; j++) {
                offset = offset + 32;
                assembly {
                    aux := mload(add(res, offset))
                }
                proof[j] = bytes32(aux);
            }
            merkleProofs.push(proof);
        }
    }

    function getFilename() public view returns (string memory) {
        return filename;
    }
}
