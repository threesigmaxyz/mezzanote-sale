// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./utils/DefimonsFixture.sol";
import "src/DefimonsStarterMonsters.sol";

contract Defimons_SaleMint is DefimonsFixture {
    function setUp() public override {
        super.setUp();

        // add mock public sale
        _addMockSaleAndValidate(false, true);

        // add mock whitelist sale
        MOCK_SALE_ID += 1;
        _addMockSaleAndValidate(true, false);

        MOCK_SALE_ID += 1;
        // add mock public sale
        _addMockSaleAndValidate(false, false);

        MOCK_SALE_ID -= 2; // MOCK_SALE_ID is first public sale
    }

    function test_saleMint() public {
        // correct flow already tested in FullSale test
    }

    function test_saleMint_saleDoesNotExist() public {
        // === arrange ===
        address user_ = vm.addr(9090);

        // === act ===
        vm.expectRevert(abi.encodeWithSelector(DefimonsStarterMonsters.SaleNotFoundError.selector, MOCK_SALE_ID + 3));
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID + 3, user_, 1, new bytes32[](0));
    }

    function test_saleMint_zeroMintQuantityError() public {
        // === arrange ===
        address user_ = vm.addr(9090);
        vm.warp(MOCK_SALE_START);

        // === act ===
        vm.expectRevert(DefimonsStarterMonsters.ZeroMintQuantityError.selector);
        defimons.publicSaleMint(MOCK_SALE_ID, user_, 0, new bytes32[](0));
    }

    function test_saleMint_notInSalePhaseError() public {
        // === arrange ===
        address user_ = vm.addr(9090);

        // === act ===
        vm.warp(MOCK_SALE_START - 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.NotInSalePhaseError.selector,
                MOCK_SALE_ID,
                MOCK_SALE_START,
                MOCK_SALE_FINISH,
                MOCK_SALE_START - 1
            )
        );
        defimons.publicSaleMint(MOCK_SALE_ID, user_, 1, new bytes32[](0));

        // === act ===
        vm.warp(MOCK_SALE_FINISH + 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.NotInSalePhaseError.selector,
                MOCK_SALE_ID,
                MOCK_SALE_START,
                MOCK_SALE_FINISH,
                MOCK_SALE_FINISH + 1
            )
        );
        defimons.publicSaleMint(MOCK_SALE_ID, user_, 1, new bytes32[](0));
    }

    function test_saleMint_user_NotWhitelistedOrWrongProof() public {
        vm.warp(MOCK_SALE_START);

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.UserNotWhitelistedOrWrongProofError.selector, 1, addresses[0], merkleProofs[1]
            )
        );
        defimons.whitelistSaleMint{ value: MOCK_SALE_PRICE }(
            MOCK_SALE_ID + 1, addresses[0], amounts[0], amounts[0], merkleProofs[1]
        );

        // === act ===
        _saleMint(MOCK_SALE_ID + 1, addresses[0], amounts[0], amounts[0], MOCK_SALE_PRICE, merkleProofs[0]);
    }

    function test_saleMint_wrongValueSentForMintError() public {
        // === arrange ===
        address user_ = vm.addr(9090);
        uint256 value_ = MOCK_SALE_LIMIT * MOCK_SALE_PRICE;
        vm.deal(user_, value_ + 1);
        vm.warp(MOCK_SALE_START);

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.WrongValueSentForMintError.selector,
                MOCK_SALE_ID,
                value_ - 1,
                MOCK_SALE_PRICE,
                MOCK_SALE_LIMIT
            )
        );
        vm.prank(user_);
        defimons.publicSaleMint{ value: value_ - 1 }(MOCK_SALE_ID, user_, MOCK_SALE_LIMIT, new bytes32[](0));

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.WrongValueSentForMintError.selector,
                MOCK_SALE_ID,
                value_ + 1,
                MOCK_SALE_PRICE,
                MOCK_SALE_LIMIT
            )
        );
        vm.prank(user_);
        defimons.publicSaleMint{ value: value_ + 1 }(MOCK_SALE_ID, user_, MOCK_SALE_LIMIT, new bytes32[](0));
    }

    function test_saleMint_maximumSaleLimitReachedError() public {
        // === arrange ===
        address user_ = vm.addr(9090);
        vm.deal(user_, 1337 ether);
        vm.warp(MOCK_SALE_START);

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.MaximumSaleLimitReachedError.selector, MOCK_SALE_ID, user_, MOCK_SALE_LIMIT
            )
        );
        vm.prank(user_);
        defimons.publicSaleMint{ value: (MOCK_SALE_LIMIT + 1) * MOCK_SALE_PRICE }(
            MOCK_SALE_ID, user_, MOCK_SALE_LIMIT + 1, new bytes32[](0)
        );

        // === act ===
        _saleMint(MOCK_SALE_ID, user_, 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        vm.deal(user_, 1337 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.MaximumSaleLimitReachedError.selector, MOCK_SALE_ID, user_, MOCK_SALE_LIMIT
            )
        );
        vm.prank(user_);
        defimons.publicSaleMint{ value: MOCK_SALE_LIMIT * MOCK_SALE_PRICE }(
            MOCK_SALE_ID, user_, MOCK_SALE_LIMIT, new bytes32[](0)
        );
    }

    function test_saleMint_maximumSaleLimitReachedError_userAllowanceFromApartments() public {
        // === arrange ===
        address user_ = addresses[0];
        uint256 userAllowanceFromApartments_ = amounts[0];
        vm.deal(user_, 1337 ether);
        vm.warp(MOCK_SALE_START);

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.MaximumSaleLimitReachedError.selector,
                MOCK_SALE_ID + 1,
                user_,
                userAllowanceFromApartments_
            )
        );
        vm.prank(user_);
        defimons.whitelistSaleMint{ value: (userAllowanceFromApartments_ + 1) * MOCK_SALE_PRICE }(
            MOCK_SALE_ID + 1, user_, userAllowanceFromApartments_, userAllowanceFromApartments_ + 1, merkleProofs[0]
        );

        // === act ===
        _saleMint(
            MOCK_SALE_ID + 1,
            user_,
            userAllowanceFromApartments_,
            userAllowanceFromApartments_,
            MOCK_SALE_PRICE,
            merkleProofs[0]
        );
        vm.deal(user_, 1337 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.MaximumSaleLimitReachedError.selector,
                MOCK_SALE_ID + 1,
                user_,
                userAllowanceFromApartments_
            )
        );
        vm.prank(user_);
        defimons.whitelistSaleMint{ value: userAllowanceFromApartments_ * MOCK_SALE_PRICE }(
            MOCK_SALE_ID + 1, user_, userAllowanceFromApartments_, userAllowanceFromApartments_, merkleProofs[0]
        );
    }

    function test_saleMint_maximumTotalMintSupplyReachedError() public {
        // === arrange ===
        uint256 maxSaleMint_ = defimons.getSale(MOCK_SALE_ID).maxMint;
        address user_ = vm.addr(maxSaleMint_ + 1);
        vm.deal(user_, MOCK_SALE_PRICE);
        vm.warp(MOCK_SALE_START);
        uint256 i = 1;
        for (; i <= maxSaleMint_; i++) {
            _saleMint(MOCK_SALE_ID, vm.addr(i), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }

        vm.expectRevert(
            abi.encodeWithSelector(DefimonsStarterMonsters.MaximumSaleMintSupplyReachedError.selector, MOCK_SALE_ID)
        );
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID, user_, 1, new bytes32[](0));

        for (; i <= defimons.maxMint(); i++) {
            _saleMint(MOCK_SALE_ID + 2, vm.addr(i), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }
        vm.expectRevert(DefimonsStarterMonsters.MaximumTotalMintSupplyReachedError.selector);
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID + 2, user_, 1, new bytes32[](0));
    }

    function test_saleMint_maximumSaleMintSupplyReachedError() public {
        // === arrange ===
        uint256 maxSaleMint_ = defimons.getSale(MOCK_SALE_ID).maxMint;
        address user_ = vm.addr(maxSaleMint_ + 1);
        vm.deal(user_, MOCK_SALE_PRICE);
        vm.warp(MOCK_SALE_START);
        for (uint256 i = 1; i <= maxSaleMint_; i++) {
            _saleMint(MOCK_SALE_ID, vm.addr(i), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }

        // === act ===
        vm.prank(user_);
        vm.expectRevert(
            abi.encodeWithSelector(DefimonsStarterMonsters.MaximumSaleMintSupplyReachedError.selector, MOCK_SALE_ID)
        );
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID, user_, 1, new bytes32[](0));
    }

    function test_saleMint_withRefund() public {
        // === arrange ===
        address user_ = vm.addr(defimons.maxMint());
        vm.deal(user_, MOCK_SALE_PRICE * 2);
        vm.warp(MOCK_SALE_START);
        for (uint256 i = 1; i <= defimons.maxMint() - 1; i++) {
            _saleMint(MOCK_SALE_ID + 2, vm.addr(i), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }
        uint256 prevBalance_ = address(defimons).balance;

        // === act ===
        vm.expectEmit(true, false, false, true);
        emit LogSale(MOCK_SALE_ID + 2, user_, 1);
        vm.prank(user_);
        defimons.publicSaleMint{ value: MOCK_SALE_PRICE * 2 }(MOCK_SALE_ID + 2, user_, 2, new bytes32[](0));

        // === assert ===
        assertEq(defimons.nextToMint(), defimons.maxMint() + 1);
        assertEq(defimons.getMintedAmount(MOCK_SALE_ID + 2, user_), 1);
        assertEq(defimons.balanceOf(user_), 1);
        assertEq(defimons.ownerOf(defimons.maxMint()), user_);
        assertEq(user_.balance, MOCK_SALE_PRICE);
        assertEq(address(defimons).balance, prevBalance_ + MOCK_SALE_PRICE);
    }

    function test_saleMint_ZeroAddressError() public {
        // === arrange ===
        address user_ = address(0);
        vm.warp(MOCK_SALE_START);

        // === act ===
        vm.expectRevert(DefimonsStarterMonsters.ZeroAddressError.selector);
        defimons.publicSaleMint(MOCK_SALE_ID, user_, 1, new bytes32[](0));
    }
}
