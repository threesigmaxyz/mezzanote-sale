// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./utils/DefimonsFixture.sol";
import "src/DefimonsStarterMonsters.sol";

contract Defimons_OwnerMint is DefimonsFixture {
    function setUp() public override {
        super.setUp();

        // add mock public sale
        _addMockSaleAndValidate(false, false);
    }

    function test_ownerMint_ok_usersCanNotMintMore() public {
        address[] memory users_ = new address[](3);
        users_[0] = makeAddr("user1");
        users_[1] = makeAddr("user2");
        users_[2] = makeAddr("user3");

        uint256[] memory amounts_ = new uint256[](3);
        amounts_[0] = 1500;
        amounts_[1] = 1500;
        amounts_[2] = 1600;
        uint256 newMaxMint = amounts_[0] + amounts_[1] + amounts_[2];

        vm.expectEmit(true, true, false, true, address(defimons));
        emit LogOwnerMint(users_, amounts_);

        vm.prank(getOwner());
        defimons.ownerMint(users_, amounts_);
        assertEq(defimons.maxMint(), newMaxMint);
        assertEq(defimons.nextToMint(), newMaxMint + 1);
        assertEq(defimons.balanceOf(users_[0]), amounts_[0]);
        assertEq(defimons.balanceOf(users_[1]), amounts_[1]);
        assertEq(defimons.balanceOf(users_[2]), amounts_[2]);

        vm.prank(users_[0]);
        vm.deal(users_[0], MOCK_SALE_PRICE);

        vm.warp(MOCK_SALE_START);

        vm.expectRevert(DefimonsStarterMonsters.MaximumTotalMintSupplyReachedError.selector);
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID, users_[0], 1, new bytes32[](0));

        // owner can still mint after max mint reached

        vm.expectEmit(true, true, false, true, address(defimons));
        emit LogOwnerMint(users_, amounts_);

        vm.prank(getOwner());
        defimons.ownerMint(users_, amounts_);
        assertEq(defimons.maxMint(), 2 * newMaxMint);
        assertEq(defimons.nextToMint(), 2 * newMaxMint + 1);
        assertEq(defimons.balanceOf(users_[0]), 2 * amounts_[0]);
        assertEq(defimons.balanceOf(users_[1]), 2 * amounts_[1]);
        assertEq(defimons.balanceOf(users_[2]), 2 * amounts_[2]);

        // users can't

        vm.expectRevert(DefimonsStarterMonsters.MaximumTotalMintSupplyReachedError.selector);
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID, users_[0], 1, new bytes32[](0));
    }

    function test_saleMint_ok_usersCanMintMore() public {
        address[] memory users_ = new address[](2);
        users_[0] = makeAddr("user1");
        users_[1] = makeAddr("user2");

        uint256[] memory amounts_ = new uint256[](2);
        amounts_[0] = 1500;
        amounts_[1] = 1500;

        vm.expectEmit(true, true, false, true, address(defimons));
        emit LogOwnerMint(users_, amounts_);

        vm.prank(getOwner());
        defimons.ownerMint(users_, amounts_);
        assertEq(defimons.maxMint(), MAX_MINT);
        assertEq(defimons.nextToMint(), 3000 + 1);
        assertEq(defimons.balanceOf(users_[0]), amounts_[0]);
        assertEq(defimons.balanceOf(users_[1]), amounts_[1]);

        vm.warp(MOCK_SALE_START);

        uint256 saleParticipants_ = defimons.maxMint() - (amounts_[0] + amounts_[1]);
        for (uint256 i_ = 0; i_ < saleParticipants_; i_++) {
            _saleMint(MOCK_SALE_ID, vm.addr(111_111 + i_), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }
        assertEq(defimons.nextToMint(), defimons.maxMint() + 1);

        vm.expectRevert(DefimonsStarterMonsters.MaximumTotalMintSupplyReachedError.selector);
        vm.deal(users_[0], MOCK_SALE_PRICE);
        vm.prank(users_[0]);
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID, users_[0], 1, new bytes32[](0));

        // owner can still mint after max mint reached

        vm.expectEmit(true, true, false, true, address(defimons));
        emit LogOwnerMint(users_, amounts_);

        vm.prank(getOwner());
        defimons.ownerMint(users_, amounts_);
        uint256 newMaxMint_ = MAX_MINT + amounts_[0] + amounts_[1];
        assertEq(defimons.maxMint(), newMaxMint_);
        assertEq(defimons.nextToMint(), newMaxMint_ + 1);
        assertEq(defimons.balanceOf(users_[0]), 2 * amounts_[0]);
        assertEq(defimons.balanceOf(users_[1]), 2 * amounts_[1]);

        // users can't mint more

        vm.expectRevert(DefimonsStarterMonsters.MaximumTotalMintSupplyReachedError.selector);
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID, users_[0], 1, new bytes32[](0));
    }

    function test_ownerMint_NotOwnerError() public {
        address[] memory users_ = new address[](3);
        users_[0] = makeAddr("user1");
        users_[1] = makeAddr("user2");
        users_[2] = makeAddr("user3");

        uint256[] memory amounts_ = new uint256[](3);
        amounts_[0] = 1500;
        amounts_[1] = 1500;
        amounts_[2] = 1600;

        vm.expectRevert("Ownable: caller is not the owner");
        defimons.ownerMint(users_, amounts_);
    }

    function test_ownerMint_ZeroAddressError() public {
        address[] memory users_ = new address[](3);
        users_[0] = makeAddr("user1");
        users_[1] = makeAddr("user2");
        users_[2] = address(0);

        uint256[] memory amounts_ = new uint256[](3);
        amounts_[0] = 1500;
        amounts_[1] = 1500;
        amounts_[2] = 1600;

        vm.prank(getOwner());
        vm.expectRevert(DefimonsStarterMonsters.ZeroAddressError.selector);
        defimons.ownerMint(users_, amounts_);

        users_[0] = makeAddr("user1");
        users_[1] = address(0);
        users_[2] = makeAddr("user3");

        vm.prank(getOwner());
        vm.expectRevert(DefimonsStarterMonsters.ZeroAddressError.selector);
        defimons.ownerMint(users_, amounts_);

        users_[0] = address(0);
        users_[1] = makeAddr("user2");
        users_[2] = makeAddr("user3");

        vm.prank(getOwner());
        vm.expectRevert(DefimonsStarterMonsters.ZeroAddressError.selector);
        defimons.ownerMint(users_, amounts_);
    }

    function test_ownerMint_AddressessAmountsLengthsMismatchError() public {
        address[] memory users_ = new address[](3);
        users_[0] = makeAddr("user1");
        users_[1] = makeAddr("user2");
        users_[2] = makeAddr("user3");

        uint256[] memory amounts_ = new uint256[](2);
        amounts_[0] = 1500;
        amounts_[1] = 1500;

        vm.prank(getOwner());
        vm.expectRevert(DefimonsStarterMonsters.AddressessAmountsLengthsMismatchError.selector);
        defimons.ownerMint(users_, amounts_);
    }

    function test_ownerMint_ZeroUsersToMintError() public {
        address[] memory users_ = new address[](0);
        uint256[] memory amounts_ = new uint256[](0);

        vm.prank(getOwner());
        vm.expectRevert(DefimonsStarterMonsters.ZeroUsersToMintError.selector);
        defimons.ownerMint(users_, amounts_);
    }

    function test_ownerMint_ZeroMintQuantityError() public {
        address[] memory users_ = new address[](3);
        users_[0] = makeAddr("user1");
        users_[1] = makeAddr("user2");
        users_[2] = makeAddr("user3");

        uint256[] memory amounts_ = new uint256[](3);
        amounts_[0] = 1500;
        amounts_[1] = 1500;
        amounts_[2] = 0;

        vm.prank(getOwner());
        vm.expectRevert(DefimonsStarterMonsters.ZeroMintQuantityError.selector);
        defimons.ownerMint(users_, amounts_);

        amounts_[0] = 1500;
        amounts_[1] = 0;
        amounts_[2] = 1600;

        vm.prank(getOwner());
        vm.expectRevert(DefimonsStarterMonsters.ZeroMintQuantityError.selector);
        defimons.ownerMint(users_, amounts_);

        amounts_[0] = 0;
        amounts_[1] = 1500;
        amounts_[2] = 1600;

        vm.prank(getOwner());
        vm.expectRevert(DefimonsStarterMonsters.ZeroMintQuantityError.selector);
        defimons.ownerMint(users_, amounts_);
    }
}
