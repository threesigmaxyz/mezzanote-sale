// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./utils/DefimonsFixture.sol";

contract Defimons_AddSale is DefimonsFixture {
    function setUp() public override {
        super.setUp();
    }

    function test_addSale() public {
        // correct flow already tested in FullSale test
    }

    function test_addSale_invalidSaleIntervalError() public {
        // === arrange ===
        address owner = getOwner();

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.InvalidSaleIntervalError.selector, MOCK_SALE_START, MOCK_SALE_START - 1
            )
        );
        vm.prank(owner);
        MOCK_SALE_FINISH = MOCK_SALE_START - 1;
        _addMockSale(true, false);
    }

    function test_addSale_invalidWhitelistRootError() public {
        // === arrange ===
        address owner_ = getOwner();

        // === act ===
        vm.expectRevert(DefimonsStarterMonsters.InvalidWhitelistRootError.selector);
        vm.prank(owner_);
        whitelistMerkleRoot = bytes32(0);
        _addMockSale(true, false);
    }

    function test_addSale_onlyOwner() public {
        // === act ===
        vm.expectRevert("Ownable: caller is not the owner");
        _addMockSale(true, false);
    }

    function test_addSale_InvalidSaleMaxMintError() public {
        // === arrange ===
        address owner_ = getOwner();

        // === act ===
        vm.expectRevert(DefimonsStarterMonsters.InvalidSaleMaxMintError.selector);
        vm.prank(owner_);
        MOCK_SALE_MAX_MINT = 0;
        _addMockSale(true, true);
    }
}
