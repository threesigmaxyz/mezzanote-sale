// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./utils/MezzanoteSaleFixture.sol";

contract MezzanoteSale_EditSale is MezzanoteSaleFixture {
    function setUp() public override {
        super.setUp();
    }

    function test_editSale() public {
        // === arrange ===
        MOCK_SALE_W_START = MOCK_SALE_W_START * 2;
        MOCK_SALE_W_FINISH = MOCK_SALE_W_FINISH * 2;
        MOCK_SALE_LIMIT = MOCK_SALE_LIMIT * 2;
        MOCK_SALE_PRICE = MOCK_SALE_PRICE * 2;

        // === act === + === assert ===
        _editMockSaleAndValidate(true);
    }

    function test_editSale_saleNotFoundError() public {
        // === arrange ===
        address owner_ = getOwner();

        // === act ===
        vm.expectRevert(abi.encodeWithSelector(MezzanoteSale.SaleNotFoundError.selector, MOCK_SALE_ID_W + 2));
        vm.prank(owner_);
        MOCK_SALE_ID_W = MOCK_SALE_ID_W + 2;
        _editMockSale(false);
    }

    function test_editSale_invalidSaleIntervalError() public {
        // === arrange ===
        address owner_ = getOwner();
        MOCK_SALE_W_FINISH = MOCK_SALE_W_START - 1;

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                MezzanoteSale.InvalidSaleIntervalError.selector, MOCK_SALE_W_START, MOCK_SALE_W_FINISH
            )
        );
        vm.prank(owner_);
        _editMockSale(false);
    }

    function test_editSale_invalidWhitelistRootError() public {
        // === arrange ===
        address owner_ = getOwner();

        // === act ===
        vm.expectRevert(MezzanoteSale.InvalidWhitelistRootError.selector);
        vm.prank(owner_);
        whitelistMerkleRoot = bytes32(0);
        _editMockSale(true);
    }

    function test_editSale_onlyOwner() public {
        // === act ===
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, vm.addr(1)));
        vm.prank(vm.addr(1));
        _editMockSale(false);
    }
}
