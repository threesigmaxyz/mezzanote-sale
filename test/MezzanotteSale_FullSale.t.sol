// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import "./utils/MezzanotteSaleFixture.sol";

contract MezzanotteSale_FullSale is MezzanotteSaleFixture {
    uint256 private constant WHITELIST_SALE_ID = 2;
    uint64 private constant WHITELIST_SALE_START = 421;
    uint64 private constant WHITELIST_SALE_FINISH = 8888;
    uint8 private constant WHITELIST_SALE_LIMIT = 10;
    uint64 private constant WHITELIST_SALE_PRICE = 0.06 ether;
    bool private constant WHITELIST_SALE_WHITELIST = true;

    uint256 private constant PUBLIC_SALE_ID = 3;
    uint64 private constant PUBLIC_SALE_START = 8889;
    uint64 private constant PUBLIC_SALE_FINISH = 100_000_000;
    uint8 private constant PUBLIC_SALE_LIMIT = 2;
    uint64 private constant PUBLIC_SALE_PRICE = 0.09 ether;
    bool private constant PUBLIC_SALE_WHITELIST = false;

    function setUp() public override {
        super.setUp();
    }

    function test_sale() public {
        // add whitelist sale
        _addSale(
            WHITELIST_SALE_ID,
            WHITELIST_SALE_START,
            WHITELIST_SALE_FINISH,
            WHITELIST_SALE_LIMIT,
            WHITELIST_SALE_PRICE,
            WHITELIST_SALE_WHITELIST,
            whitelistMerkleRoot,
            false,
            0
        );

        // add public sale
        _addSale(
            PUBLIC_SALE_ID,
            PUBLIC_SALE_START,
            PUBLIC_SALE_FINISH,
            PUBLIC_SALE_LIMIT,
            PUBLIC_SALE_PRICE,
            PUBLIC_SALE_WHITELIST,
            bytes32(0),
            false,
            0
        );

        // go to whitelist sale
        vm.warp(WHITELIST_SALE_START);
        uint256 whitelistSaleParticipants_ = 10;
        uint256 whitelistMinted_;
        uint256 amount_ = 10;
        for (uint256 i = 0; i < whitelistSaleParticipants_; i++) {
            _saleMint(WHITELIST_SALE_ID, addresses[i], amount_, amount_, WHITELIST_SALE_PRICE, merkleProofs[i]);
            whitelistMinted_ += amount_;
        }
        assertEq(mezzanote.nextToMint(), whitelistMinted_ + STARTING_ID);

        // go to public sale
        vm.warp(PUBLIC_SALE_START);
        uint256 publicSaleParticipants_ = mezzanote.maxMint() - mezzanote.nextToMint() - 1;
        for (uint256 i = 0; i <= publicSaleParticipants_; i++) {
            _saleMint(PUBLIC_SALE_ID, vm.addr(999_999 + i), 0, 1, PUBLIC_SALE_PRICE, new bytes32[](0));
        }
        assertEq(mezzanote.nextToMint(), mezzanote.maxMint());

        // try to mint one more (reverts)
        vm.expectRevert(MezzanotteSale.MaximumTotalMintSupplyReachedError.selector);
        mezzanote.publicSaleMint{ value: PUBLIC_SALE_PRICE }(PUBLIC_SALE_ID, vm.addr(1234), 1);

        // withdraw sale proceedings
        address saleRecipient_ = vm.addr(8888);
        uint256 mezzanoteBalance_ = address(mezzanote).balance;
        vm.prank(getOwner());
        mezzanote.withdrawEther(saleRecipient_, mezzanoteBalance_);
        // perform withdraw assertions
        assertEq(address(mezzanote).balance, 0);
        assertEq(saleRecipient_.balance, mezzanoteBalance_);
    }
}
