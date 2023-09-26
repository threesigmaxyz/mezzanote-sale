// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./utils/MezzanotteSaleFixture.sol";

contract MezzanotteSale_EditSale is MezzanotteSaleFixture {
    function setUp() public override {
        super.setUp();
        _addMockSaleAndValidate(true, true);
    }

    function test_editSale() public {
        // === arrange ===
        MOCK_SALE_START = MOCK_SALE_START * 2;
        MOCK_SALE_FINISH = MOCK_SALE_FINISH * 2;
        MOCK_SALE_LIMIT = MOCK_SALE_LIMIT * 2;
        MOCK_SALE_PRICE = MOCK_SALE_PRICE * 2;

        // === act === + === assert ===
        _editMockSaleAndValidate(true);
    }

    function test_editSale_saleNotFoundError() public {
        // === arrange ===
        address owner_ = getOwner();

        // === act ===
        vm.expectRevert(abi.encodeWithSelector(MezzanotteSale.SaleNotFoundError.selector, MOCK_SALE_ID + 2));
        vm.prank(owner_);
        MOCK_SALE_ID = MOCK_SALE_ID + 2;
        _editMockSale(false);
    }

    function test_editSale_invalidSaleIntervalError() public {
        // === arrange ===
        address owner_ = getOwner();
        MOCK_SALE_FINISH = MOCK_SALE_START - 1;

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(MezzanotteSale.InvalidSaleIntervalError.selector, MOCK_SALE_START, MOCK_SALE_FINISH)
        );
        vm.prank(owner_);
        _editMockSale(false);
    }

    function test_editSale_invalidWhitelistRootError() public {
        // === arrange ===
        address owner_ = getOwner();

        // === act ===
        vm.expectRevert(MezzanotteSale.InvalidWhitelistRootError.selector);
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

    function test_editSale_InvalidSaleMaxMintError() public {
        // === arrange ===
        address owner_ = getOwner();

        // === act ===
        vm.expectRevert(MezzanotteSale.InvalidSaleMaxMintError.selector);
        vm.prank(owner_);
        MOCK_SALE_MAX_MINT = 0;
        _editMockSale(true);
    }

    function test_fuzz_setMaxSaleMint(uint40 newSaleMaxMint_, uint40 numberOfSales_) public {
        vm.prank(getOwner());
        _editMockSaleAndValidate(false);

        if (numberOfSales_ > 30) numberOfSales_ = 30;

        vm.warp(MOCK_SALE_START);

        for (uint256 i = 0; i < numberOfSales_; i++) {
            _saleMint(MOCK_SALE_ID, vm.addr(i + 1), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }

        uint40 loggedNewSaleMaxMint_ = newSaleMaxMint_;
        // === act ===
        if (newSaleMaxMint_ != 0) {
            vm.expectEmit(true, true, false, true, address(mezzanote));
            if (newSaleMaxMint_ < numberOfSales_) loggedNewSaleMaxMint_ = numberOfSales_;
            emit LogSaleEdited(
                MOCK_SALE_ID,
                MOCK_SALE_START,
                MOCK_SALE_FINISH,
                MOCK_SALE_LIMIT,
                MOCK_SALE_PRICE,
                false,
                whitelistMerkleRoot,
                true,
                loggedNewSaleMaxMint_
            );
        } else {
            vm.expectRevert(MezzanotteSale.InvalidSaleMaxMintError.selector);
        }

        MOCK_SALE_MAX_MINT = newSaleMaxMint_;
        vm.prank(getOwner());
        _editMockSale(false);
        if (loggedNewSaleMaxMint_ != 0) assertEq(mezzanote.getSale(MOCK_SALE_ID).maxMint, loggedNewSaleMaxMint_);
    }
}
