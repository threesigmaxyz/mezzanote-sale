// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./utils/MezzanoteSaleFixture.sol";
import "src/MezzanoteSale.sol";

contract MezzanoteSale_SaleMint is MezzanoteSaleFixture {
    function setUp() public override {
        super.setUp();
    }

    function test_saleMint() public {
        // go to whitelist sale
        vm.warp(MOCK_SALE_W_START);
        uint256 whitelistSaleParticipants_ = 50;
        uint256 whitelistMinted_;
        for (uint256 i = 0; i < whitelistSaleParticipants_; i++) {
            _saleMint(MOCK_SALE_ID_W, addresses[i], MOCK_SALE_LIMIT, MOCK_SALE_LIMIT, MOCK_SALE_PRICE, merkleProofs[i]);
            whitelistMinted_ += MOCK_SALE_LIMIT;
        }
        assertEq(mezzanote.nextToMint(), whitelistMinted_);

        // go to public sale
        vm.warp(MOCK_SALE_P_START);
        uint256 publicSaleParticipants_ = mezzanote.maxMint() - mezzanote.nextToMint();
        for (uint256 i = 0; i <= publicSaleParticipants_; i++) {
            _saleMint(MOCK_SALE_ID_P, vm.addr(999_999 + i), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }
        assertEq(mezzanote.nextToMint(), mezzanote.maxMint() + 1);
    }

    function test_saleMint_saleDoesNotExist() public {
        // === arrange ===
        address user_ = vm.addr(9090);

        // === act ===
        vm.expectRevert(abi.encodeWithSelector(MezzanoteSale.SaleNotFoundError.selector, MOCK_SALE_ID_P + 3));
        mezzanote.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID_P + 3, user_, 1);
    }

    function test_saleMint_zeroMintQuantityError() public {
        // === arrange ===
        address user_ = vm.addr(9090);
        vm.warp(MOCK_SALE_P_START);

        // === act ===
        vm.expectRevert(MezzanoteSale.ZeroMintQuantityError.selector);
        mezzanote.publicSaleMint(1, user_, 0);
    }

    function test_saleMint_notInSalePhaseError() public {
        // === arrange ===
        address user_ = vm.addr(9090);

        // === act ===
        vm.warp(MOCK_SALE_P_START - 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                MezzanoteSale.NotInSalePhaseError.selector,
                1,
                MOCK_SALE_P_START,
                MOCK_SALE_P_FINISH,
                MOCK_SALE_P_START - 1
            )
        );
        mezzanote.publicSaleMint(1, user_, 1);

        // === act ===
        vm.warp(MOCK_SALE_P_FINISH + 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                MezzanoteSale.NotInSalePhaseError.selector,
                1,
                MOCK_SALE_P_START,
                MOCK_SALE_P_FINISH,
                MOCK_SALE_P_FINISH + 1
            )
        );
        mezzanote.publicSaleMint(1, user_, 1);
    }

    function test_saleMint_user_NotWhitelistedOrWrongProof() public {
        vm.warp(MOCK_SALE_W_START);

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                MezzanoteSale.UserNotWhitelistedOrWrongProofError.selector, 0, addresses[0], merkleProofs[1]
            )
        );
        mezzanote.whitelistSaleMint{ value: MOCK_SALE_PRICE }(0, addresses[0], MOCK_SALE_LIMIT, merkleProofs[1]);

        // === act ===
        _saleMint(0, addresses[0], MOCK_SALE_LIMIT, MOCK_SALE_LIMIT, MOCK_SALE_PRICE, merkleProofs[0]);
    }

    function test_saleMint_wrongValueSentForMintError() public {
        // === arrange ===
        address user_ = vm.addr(9090);
        uint256 value_ = MOCK_SALE_LIMIT * MOCK_SALE_PRICE;
        vm.deal(user_, value_ + 1);
        vm.warp(MOCK_SALE_P_START);

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                MezzanoteSale.WrongValueSentForMintError.selector,
                MOCK_SALE_ID_P,
                value_ - 1,
                MOCK_SALE_PRICE,
                MOCK_SALE_LIMIT
            )
        );
        vm.prank(user_);
        mezzanote.publicSaleMint{ value: value_ - 1 }(MOCK_SALE_ID_P, user_, MOCK_SALE_LIMIT);

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                MezzanoteSale.WrongValueSentForMintError.selector,
                MOCK_SALE_ID_P,
                value_ + 1,
                MOCK_SALE_PRICE,
                MOCK_SALE_LIMIT
            )
        );
        vm.prank(user_);
        mezzanote.publicSaleMint{ value: value_ + 1 }(MOCK_SALE_ID_P, user_, MOCK_SALE_LIMIT);
    }

    function test_saleMint_maximumSaleLimitReachedError() public {
        // === arrange ===
        address user_ = vm.addr(9090);
        vm.deal(user_, 1337 ether);
        vm.warp(MOCK_SALE_P_START);

        // === act ===
        vm.expectRevert(
            abi.encodeWithSelector(
                MezzanoteSale.MaximumSaleLimitReachedError.selector, MOCK_SALE_ID_P, user_, MOCK_SALE_LIMIT
            )
        );
        vm.prank(user_);
        mezzanote.publicSaleMint{ value: (MOCK_SALE_LIMIT + 1) * MOCK_SALE_PRICE }(
            MOCK_SALE_ID_P, user_, MOCK_SALE_LIMIT + 1
        );

        // === act ===
        _saleMint(MOCK_SALE_ID_P, user_, 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        vm.deal(user_, 1337 ether);
        vm.expectRevert(
            abi.encodeWithSelector(
                MezzanoteSale.MaximumSaleLimitReachedError.selector, MOCK_SALE_ID_P, user_, MOCK_SALE_LIMIT
            )
        );
        vm.prank(user_);
        mezzanote.publicSaleMint{ value: MOCK_SALE_LIMIT * MOCK_SALE_PRICE }(MOCK_SALE_ID_P, user_, MOCK_SALE_LIMIT);
    }

    function test_saleMint_maximumTotalMintSupplyReachedError() public {
        // === arrange ===
        uint256 maxSaleMint_ = MOCK_SALE_MAX_MINT;
        address user_ = vm.addr(maxSaleMint_ + 1);
        vm.deal(user_, MOCK_SALE_PRICE);
        vm.warp(MOCK_SALE_P_START);
        uint256 i = 0;
        for (; i <= maxSaleMint_; i++) {
            _saleMint(MOCK_SALE_ID_P, vm.addr(i + 1), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }

        vm.expectRevert(abi.encodeWithSelector(MezzanoteSale.MaximumTotalMintSupplyReachedError.selector));
        mezzanote.publicSaleMint{ value: MOCK_SALE_PRICE }(MOCK_SALE_ID_P, user_, 1);
    }

    function test_saleMint_withRefund() public {
        // === arrange ===
        address user_ = vm.addr(mezzanote.maxMint() + 1);
        vm.deal(user_, MOCK_SALE_PRICE * 2);
        vm.warp(MOCK_SALE_P_START);
        for (uint256 i = 0; i <= mezzanote.maxMint() - 1; i++) {
            _saleMint(MOCK_SALE_ID_P, vm.addr(i + 1), 0, 1, MOCK_SALE_PRICE, new bytes32[](0));
        }
        uint256 prevBalance_ = address(mezzanote).balance;

        // === act ===
        vm.expectEmit(true, false, false, true);
        emit LogSale(MOCK_SALE_ID_P, user_, 1);
        vm.prank(user_);
        mezzanote.publicSaleMint{ value: MOCK_SALE_PRICE * 2 }(MOCK_SALE_ID_P, user_, 2);

        // === assert ===
        assertEq(mezzanote.nextToMint(), mezzanote.maxMint() + 1);
        assertEq(mezzanote.getMintedAmount(MOCK_SALE_ID_P, user_), 1);
        assertEq(NFTToken.balanceOf(user_), 1);
        assertEq(NFTToken.ownerOf(mezzanote.maxMint()), user_);
        assertEq(user_.balance, MOCK_SALE_PRICE);
        assertEq(address(mezzanote).balance, prevBalance_ + MOCK_SALE_PRICE);
    }

    function test_saleMint_ZeroAddressError() public {
        // === arrange ===
        address user_ = address(0);
        vm.warp(MOCK_SALE_ID_P);

        // === act ===
        vm.expectRevert(MezzanoteSale.ZeroAddressError.selector);
        mezzanote.publicSaleMint(MOCK_SALE_ID_P, user_, 1);
    }
}
