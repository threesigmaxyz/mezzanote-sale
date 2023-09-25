// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/MezzanoteSaleFixture.sol";
import "./utils/MockToken.sol";
import "./utils/strings.sol";

contract MezzanoteSale_Other is MezzanoteSaleFixture {
    using strings for *;

    function test_constructor() public {
        // === assert ===
        assertEq(mezzanote.owner(), getOwner());
        assertEq(mezzanote.nextToMint(), 0);
        assertEq(mezzanote.maxMint(), MAX_MINT);

        // Check added sales
        // Whitelist sale
        MezzanoteSale.Sale memory sale = mezzanote.getSale(0);
        assertEq(sale.start, MOCK_SALE_W_START);
        assertEq(sale.finish, MOCK_SALE_W_FINISH);
        assertEq(sale.price, MOCK_SALE_PRICE);
        assertEq(sale.limit, MOCK_SALE_LIMIT);
        assertEq(sale.whitelist, true);
        assertEq(sale.root, whitelistMerkleRoot);
        assertEq(sale.maxMint, 0);

        // Public sale
        MezzanoteSale.Sale memory sale2 = mezzanote.getSale(1);
        assertEq(sale2.start, MOCK_SALE_P_START);
        assertEq(sale2.finish, MOCK_SALE_P_FINISH);
        assertEq(sale2.price, MOCK_SALE_PRICE);
        assertEq(sale2.limit, MOCK_SALE_LIMIT);
        assertEq(sale2.whitelist, false);
        assertEq(sale2.root, 0);
        assertEq(sale2.maxMint, 0);
    }

    function test_withdrawEther() public {
        // === arrange ===
        vm.deal(address(mezzanote), 1337 ether);
        // and
        address owner_ = getOwner();
        address recipient_ = vm.addr(42);

        // === act ===
        vm.prank(owner_);
        mezzanote.withdrawEther(recipient_, 337 ether);

        // === assert ===
        assertEq(address(mezzanote).balance, 1000 ether);
        assertEq(recipient_.balance, 337 ether);
    }

    function test_withdrawEther_onlyOwner() public {
        // === act ===
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, vm.addr(1)));
        vm.prank(vm.addr(1));
        mezzanote.withdrawEther(vm.addr(1), 1337 ether);
    }

    function test_withdrawERC20() public {
        // === arrange ===
        MockToken token_ = new MockToken("USD Coin", "USDC", 1337);
        token_.transfer(address(mezzanote), 337);
        assertEq(token_.balanceOf(address(mezzanote)), 337);
        // and
        address owner_ = getOwner();
        address recipient_ = vm.addr(42);

        // === act ===
        vm.prank(owner_);
        mezzanote.withdrawERC20(address(token_), recipient_, 100);

        // === assert ===
        assertEq(token_.balanceOf(address(this)), 1000);
        assertEq(token_.balanceOf(address(mezzanote)), 237);
        assertEq(token_.balanceOf(address(recipient_)), 100);
    }

    function test_withdrawERC20_onlyOwner() public {
        // === act ===
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, vm.addr(1)));
        vm.prank(vm.addr(1));
        mezzanote.withdrawERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, vm.addr(1), 1337);
    }

    function test_isSaleActive() public {
        // === act ===
        vm.warp(MOCK_SALE_W_START);
        // === assert ===
        assertTrue(mezzanote.isSaleActive(0));
        assertFalse(mezzanote.isSaleActive(1));

        // === act ===
        vm.warp(MOCK_SALE_W_FINISH);
        // === assert ===
        assertTrue(mezzanote.isSaleActive(0));
        assertFalse(mezzanote.isSaleActive(1));

        // === act ===
        vm.warp(MOCK_SALE_W_FINISH + 1);
        // === assert ===
        assertFalse(mezzanote.isSaleActive(0));
        assertTrue(mezzanote.isSaleActive(1));
    }

    function test_getSalesCount() public {
        // === act ===
        uint256 salesCount_ = mezzanote.getSalesCount();

        // === assert ===
        assertEq(salesCount_, 2);
    }

    function test_setMaxMint_ok() public {
        // === arrange ===
        address owner_ = getOwner();

        uint256 newMaxMint_ = MAX_MINT + 1;

        vm.expectEmit(true, true, false, true, address(mezzanote));
        emit LogSetMaxMint(MAX_MINT, newMaxMint_);

        // === act ===
        vm.prank(owner_);
        mezzanote.setMaxMint(newMaxMint_);

        // === assert ===
        assertEq(mezzanote.maxMint(), newMaxMint_);
    }

    function test_setMaxMint_StaleMaxMintUpdateError() public {
        // === arrange ===
        address owner_ = getOwner();

        uint256 newMaxMint_ = MAX_MINT;

        // === act ===
        vm.expectRevert(abi.encodeWithSelector(MezzanoteSale.StaleMaxMintUpdateError.selector));

        vm.prank(owner_);
        mezzanote.setMaxMint(newMaxMint_);
    }

    function test_setMaxMint_ok_reduceMaxMint_stillBiggerThan_nextMintId() public {
        // === arrange ===
        address owner_ = getOwner();

        uint256 newMaxMint_ = MAX_MINT - 1;

        // === act ===
        vm.expectEmit(true, true, false, true, address(mezzanote));
        emit LogSetMaxMint(MAX_MINT, newMaxMint_);

        vm.prank(owner_);
        mezzanote.setMaxMint(newMaxMint_);
    }

    function test_setMaxMint_onlyOwner() public {
        // === act ===
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, vm.addr(1)));
        vm.prank(vm.addr(1));
        mezzanote.setMaxMint(1);
    }

    function testSetMerkleTreeLog() public {
        merkleTreeSetup();
        strings.slice memory data_ = vm.readLine("snapshot/Data/OwnersSnapshot.csv").toSlice();

        uint256 i;
        while (data_.compare("".toSlice()) != 0) {
            assertEq(vm.parseAddress(data_.toString()), addresses[i]);
            data_ = vm.readLine("snapshot/Data/OwnersSnapshot.csv").toSlice();
            i += 1;
        }
    }
}
