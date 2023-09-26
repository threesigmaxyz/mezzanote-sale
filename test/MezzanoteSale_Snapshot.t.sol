// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./utils/MezzanotteSaleFixture.sol";

contract MezzanoteSale_Snapshot is MezzanotteSaleFixture {
    address constant TEST_ADDRESS1 = 0x243d558472eF7030aFe3675Bb0a6f9Fb7cE39E13;
    address constant TEST_ADDRESS2 = 0x8b82D758a95c84Bc5476244f91e9AC6478d2a8B0;
    address constant TEST_ADDRESS3 = 0x4577fcfB0642afD21b5f2502753ED6D497B830E9;
    address constant TEST_ADDRESS4 = 0x8b6DCfB251bef4953cF3f3A8C66Af870e6b7466e;
    address constant TEST_ADDRESS5 = 0x25f23845F9F278338138B9224b62dF7DF5398A4d;

    uint256 constant TOTAL_ADDRESSES_SNAPSHOT = 2549;

    address[] addressesSnap;

    function setUp() public override {
        super.setUp();
    }

    function test_snapshot() public {
        string memory path_ = "snapshot/Data/OwnersSnapshot.csv";
        address owner_;
        uint256 allOwners_;
        uint256 length_;

        addressesSnap = new address[](TOTAL_ADDRESSES_SNAPSHOT);

        for (uint256 i = 0; i < TOTAL_ADDRESSES_SNAPSHOT; i++) {
            addressesSnap[i] = vm.parseAddress(vm.readLine(path_));
        }

        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/NTV9_O0-AM9Q0mxLFgBXxi4h5Y4EO07l", 18_220_350);

        allOwners_ = 0;
        length_ = IERC721Enumerable(TEST_ADDRESS1).totalSupply();
        for (uint256 i = 1; i <= length_; i++) {
            owner_ = ERC721(TEST_ADDRESS1).ownerOf(i);
            for (uint256 f = 0; f < TOTAL_ADDRESSES_SNAPSHOT; f++) {
                if (addressesSnap[f] == owner_) {
                    allOwners_++;
                    break;
                }
            }
        }
        assertEq(allOwners_, length_);

        allOwners_ = 0;
        length_ = IERC721Enumerable(TEST_ADDRESS2).totalSupply();
        for (uint256 i = 1; i <= length_; i++) {
            owner_ = ERC721(TEST_ADDRESS2).ownerOf(i);
            for (uint256 f = 0; f < TOTAL_ADDRESSES_SNAPSHOT; f++) {
                if (addressesSnap[f] == owner_) {
                    allOwners_++;
                    break;
                }
            }
        }
        assertEq(allOwners_, length_);

        allOwners_ = 0;
        length_ = IERC721Enumerable(TEST_ADDRESS3).totalSupply();
        for (uint256 i = 1; i <= length_; i++) {
            owner_ = ERC721(TEST_ADDRESS3).ownerOf(i);
            for (uint256 f = 0; f < TOTAL_ADDRESSES_SNAPSHOT; f++) {
                if (addressesSnap[f] == owner_) {
                    allOwners_++;
                    break;
                }
            }
        }
        assertEq(allOwners_, length_);

        allOwners_ = 0;
        length_ = IERC721Enumerable(TEST_ADDRESS4).totalSupply();
        for (uint256 i = 1; i <= length_; i++) {
            owner_ = ERC721(TEST_ADDRESS4).ownerOf(i);
            for (uint256 f = 0; f < TOTAL_ADDRESSES_SNAPSHOT; f++) {
                if (addressesSnap[f] == owner_) {
                    allOwners_++;
                    break;
                }
            }
        }
        assertEq(allOwners_, length_);

        allOwners_ = 0;
        length_ = IERC721Enumerable(TEST_ADDRESS5).totalSupply();
        for (uint256 i = 0; i < length_; i++) {
            owner_ = ERC721(TEST_ADDRESS5).ownerOf(i);
            for (uint256 f = 0; f < TOTAL_ADDRESSES_SNAPSHOT; f++) {
                if (addressesSnap[f] == owner_) {
                    allOwners_++;
                    break;
                }
            }
        }
        assertEq(allOwners_, length_);
    }
}
