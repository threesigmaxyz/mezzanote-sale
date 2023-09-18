// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./utils/DefimonsFixture.sol";
import "./utils/MockToken.sol";
import "./utils/strings.sol";

contract Defimons_Other is DefimonsFixture {
    using strings for *;

    function test_constructor() public {
        // === assert ===
        assertEq(defimons.name(), "DefimonsStarterMonsters");
        assertEq(defimons.symbol(), "DFMSM");
        assertEq(address(defimons.lzEndpoint()), 0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706);
        assertEq(defimons.owner(), getOwner());
        assertEq(defimons.nextToMint(), 1);
        assertEq(defimons.maxMint(), MAX_MINT);
    }

    function test_setURI() public {
        // === arrange ===
        string memory newURI_ = "https://twitter.com/TheDeFimons/";
        address owner_ = getOwner();
        // and
        _addMockSaleAndValidate(false, false);
        vm.warp(MOCK_SALE_START);
        _saleMint(MOCK_SALE_ID, vm.addr(1), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));

        // === act ===
        vm.expectEmit(false, false, false, true);
        emit LogSetURI(newURI_);
        vm.prank(owner_);
        defimons.setURI(newURI_);

        // === assert ===
        assertEq(defimons.tokenURI(1), "https://twitter.com/TheDeFimons/1");
    }

    function test_setURI_onlyOwner() public {
        // === act ===
        vm.expectRevert("Ownable: caller is not the owner");
        defimons.setURI("https://twitter.com/TheDeFimons/");
    }

    function test_withdrawEther() public {
        // === arrange ===
        vm.deal(address(defimons), 1337 ether);
        // and
        address owner_ = getOwner();
        address recipient_ = vm.addr(42);

        // === act ===
        vm.prank(owner_);
        defimons.withdrawEther(recipient_, 337 ether);

        // === assert ===
        assertEq(address(defimons).balance, 1000 ether);
        assertEq(recipient_.balance, 337 ether);
    }

    function test_withdrawEther_onlyOwner() public {
        // === act ===
        vm.expectRevert("Ownable: caller is not the owner");
        defimons.withdrawEther(vm.addr(1), 1337 ether);
    }

    function test_withdrawERC20() public {
        // === arrange ===
        MockToken token_ = new MockToken("USD Coin", "USDC", 1337);
        token_.transfer(address(defimons), 337);
        assertEq(token_.balanceOf(address(defimons)), 337);
        // and
        address owner_ = getOwner();
        address recipient_ = vm.addr(42);

        // === act ===
        vm.prank(owner_);
        defimons.withdrawERC20(address(token_), recipient_, 100);

        // === assert ===
        assertEq(token_.balanceOf(address(this)), 1000);
        assertEq(token_.balanceOf(address(defimons)), 237);
        assertEq(token_.balanceOf(address(recipient_)), 100);
    }

    function test_withdrawERC20_onlyOwner() public {
        // === act ===
        vm.expectRevert("Ownable: caller is not the owner");
        defimons.withdrawERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, vm.addr(1), 1337);
    }

    function test_isSaleActive() public {
        // === arrange ===
        _addMockSaleAndValidate(false, false);

        // === act ===
        vm.warp(MOCK_SALE_START - 1);
        // === assert ===
        assertFalse(defimons.isSaleActive(MOCK_SALE_ID));

        // === act ===
        vm.warp(MOCK_SALE_START);
        // === assert ===
        assertTrue(defimons.isSaleActive(MOCK_SALE_ID));

        // === act ===
        vm.warp(MOCK_SALE_FINISH);
        // === assert ===
        assertTrue(defimons.isSaleActive(MOCK_SALE_ID));

        // === act ===
        vm.warp(MOCK_SALE_FINISH + 1);
        // === assert ===
        assertFalse(defimons.isSaleActive(MOCK_SALE_ID));
    }

    function test_getSalesCount() public {
        for (uint256 i = 0; i < 5; i++) {
            // === arragne ===
            MOCK_SALE_ID = i;
            _addMockSaleAndValidate(false, false);

            // === act ===
            uint256 salesCount_ = defimons.getSalesCount();

            // === assert ===
            assertEq(salesCount_, i + 1);
        }
    }

    function test_setTrustedRemote() public {
        // === arrange ===
        address owner_ = getOwner();

        // === act ===
        vm.prank(owner_);
        defimons.setTrustedRemote(4, abi.encode(address(defimons)));

        // === assert ===
        assertTrue(defimons.isTrustedRemote(4, abi.encode(address(defimons))));
    }

    function test_setTrustedRemote_onlyOwner() public {
        // === act ===
        vm.expectRevert("Ownable: caller is not the owner");
        defimons.setTrustedRemote(4, abi.encode(address(defimons)));
    }

    function test_setMaxMint_ok() public {
        // === arrange ===
        address owner_ = getOwner();

        uint256 newMaxMint_ = MAX_MINT + 1;

        vm.expectEmit(true, true, false, true, address(defimons));
        emit LogSetMaxMint(MAX_MINT, newMaxMint_);

        // === act ===
        vm.prank(owner_);
        defimons.setMaxMint(newMaxMint_);

        // === assert ===
        assertEq(defimons.maxMint(), newMaxMint_);
    }

    function test_setMaxMint_StaleMaxMintUpdateError() public {
        // === arrange ===
        address owner_ = getOwner();

        uint256 newMaxMint_ = MAX_MINT;

        // === act ===
        vm.expectRevert(abi.encodeWithSelector(DefimonsStarterMonsters.StaleMaxMintUpdateError.selector));

        vm.prank(owner_);
        defimons.setMaxMint(newMaxMint_);
    }

    function test_setMaxMint_ok_reduceMaxMint_stillBiggerThan_nextMintId() public {
        // === arrange ===
        address owner_ = getOwner();

        uint256 newMaxMint_ = MAX_MINT - 1;

        // === act ===
        vm.expectEmit(true, true, false, true, address(defimons));
        emit LogSetMaxMint(MAX_MINT, newMaxMint_);

        vm.prank(owner_);
        defimons.setMaxMint(newMaxMint_);
    }

    function test_setMaxMint_ok_reduceMaxMint_smallerThan_nextMintId() public {
        // === arrange ===
        _addMockSaleAndValidate(false, false);

        uint256 newMaxMint = 2;
        uint256 nrSales = 3;

        vm.warp(MOCK_SALE_START);

        for (uint256 i = 0; i < nrSales; i++) {
            _saleMint(MOCK_SALE_ID, vm.addr(i + 1), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }

        // === act ===
        vm.expectEmit(true, true, false, true, address(defimons));
        emit LogSetMaxMint(MAX_MINT, nrSales);

        vm.prank(getOwner());
        defimons.setMaxMint(newMaxMint);
    }

    function test_fuzz_setMaxMint(uint256 newMaxMint_, uint256 numberOfSales_) public {
        if (numberOfSales_ > 30) numberOfSales_ = 30;

        // === arrange ===
        _addMockSaleAndValidate(false, false);

        vm.warp(MOCK_SALE_START);

        for (uint256 i = 0; i < numberOfSales_; i++) {
            _saleMint(MOCK_SALE_ID, vm.addr(i + 1), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }

        // === act ===
        if (newMaxMint_ != MAX_MINT) {
            vm.expectEmit(true, true, false, true, address(defimons));
            uint256 loggedNewMaxMint = newMaxMint_;
            if (newMaxMint_ < numberOfSales_) loggedNewMaxMint = numberOfSales_;
            emit LogSetMaxMint(MAX_MINT, loggedNewMaxMint);
        } else {
            vm.expectRevert(abi.encodeWithSelector(DefimonsStarterMonsters.StaleMaxMintUpdateError.selector));
        }

        vm.prank(getOwner());
        defimons.setMaxMint(newMaxMint_);
    }

    function test_setMaxMint_onlyOwner() public {
        // === act ===
        vm.expectRevert("Ownable: caller is not the owner");
        defimons.setMaxMint(1);
    }

    function testSetMerkleTreeLog() public {
        merkleTreeSetup();
        strings.slice memory data_ = vm.readLine("snapshot/Data/OwnersSnapshot.csv").toSlice();

        uint256 i;
        while (data_.compare("".toSlice()) != 0) {
            strings.slice memory owner_;
            data_.split(",".toSlice(), owner_);
            assertEq(vm.parseAddress(owner_.toString()), addresses[i]);
            assertEq(vm.parseUint(data_.toString()), amounts[i]);
            data_ = vm.readLine("snapshot/Data/OwnersSnapshot.csv").toSlice();
            i += 1;
        }
    }
}
