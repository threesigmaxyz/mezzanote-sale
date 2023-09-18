// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import "./utils/DefimonsFixture.sol";

contract Defimons_FullSale is DefimonsFixture {
    uint256 private constant WHITELIST_SALE_ID = 0;
    uint64 private constant WHITELIST_SALE_START = 421;
    uint64 private constant WHITELIST_SALE_FINISH = 8888;
    uint8 private constant WHITELIST_SALE_LIMIT = 0;
    uint64 private constant WHITELIST_SALE_PRICE = 0.06 ether;
    bool private constant WHITELIST_SALE_WHITELIST = true;

    uint256 private constant PUBLIC_SALE_ID = 1;
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
        uint256 whitelistSaleParticipants_ = 50;
        uint256 whitelistMinted_;
        for (uint256 i = 0; i < whitelistSaleParticipants_; i++) {
            _saleMint(WHITELIST_SALE_ID, addresses[i], amounts[i], amounts[i], WHITELIST_SALE_PRICE, merkleProofs[i]);
            whitelistMinted_ += amounts[i];
        }
        assertEq(defimons.nextToMint(), whitelistMinted_ + 1);

        // go to public sale
        vm.warp(PUBLIC_SALE_START);
        uint256 publicSaleParticipants_ = defimons.maxMint() - defimons.nextToMint();
        for (uint256 i = 0; i <= publicSaleParticipants_; i++) {
            _saleMint(PUBLIC_SALE_ID, vm.addr(999_999 + i), 0, 1, PUBLIC_SALE_PRICE, new bytes32[](0));
        }
        assertEq(defimons.nextToMint(), defimons.maxMint() + 1);

        // try to mint one more (reverts)
        vm.expectRevert(DefimonsStarterMonsters.MaximumTotalMintSupplyReachedError.selector);
        defimons.publicSaleMint{ value: PUBLIC_SALE_PRICE }(PUBLIC_SALE_ID, vm.addr(1234), 1, new bytes32[](0));

        // withdraw sale proceedings
        address saleRecipient_ = vm.addr(8888);
        uint256 defimonsBalance_ = address(defimons).balance;
        vm.prank(getOwner());
        defimons.withdrawEther(saleRecipient_, defimonsBalance_);
        // perform withdraw assertions
        assertEq(address(defimons).balance, 0);
        assertEq(saleRecipient_.balance, defimonsBalance_);
    }

    function test_sale_withMaxMint() public {
        // add whitelist sale
        _addSale(
            WHITELIST_SALE_ID,
            WHITELIST_SALE_START,
            WHITELIST_SALE_FINISH,
            WHITELIST_SALE_LIMIT,
            WHITELIST_SALE_PRICE,
            WHITELIST_SALE_WHITELIST,
            whitelistMerkleRoot,
            true,
            50
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
            true,
            3000
        );

        // add public sale
        _addSale(
            PUBLIC_SALE_ID + 1,
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
        uint256 saleParticipants_ = 50;
        uint256 whitelistMinted_;
        uint256 lastWhitelistedUserMint_;
        uint256 lastWhitelistedUserMintAmount_;
        for (uint256 i = 0; i < saleParticipants_; i++) {
            if (whitelistMinted_ < 50) {
                _saleMint(
                    WHITELIST_SALE_ID,
                    addresses[i],
                    amounts[i],
                    Math.min(amounts[i], 50 - whitelistMinted_),
                    WHITELIST_SALE_PRICE,
                    merkleProofs[i]
                );
                lastWhitelistedUserMintAmount_ = Math.min(amounts[i], 50 - whitelistMinted_);
                lastWhitelistedUserMint_ = i;
                if (whitelistMinted_ + amounts[i] >= 50) {
                    vm.expectRevert(
                        abi.encodeWithSelector(
                            DefimonsStarterMonsters.MaximumSaleMintSupplyReachedError.selector, WHITELIST_SALE_ID
                        )
                    );
                    defimons.whitelistSaleMint{ value: (amounts[i] - (50 - whitelistMinted_)) * WHITELIST_SALE_PRICE }(
                        WHITELIST_SALE_ID,
                        addresses[i],
                        amounts[i],
                        amounts[i] - (50 - whitelistMinted_),
                        merkleProofs[i]
                    );
                }
                whitelistMinted_ += Math.min(amounts[i], 50 - whitelistMinted_);
            } else {
                vm.expectRevert(
                    abi.encodeWithSelector(
                        DefimonsStarterMonsters.MaximumSaleMintSupplyReachedError.selector, WHITELIST_SALE_ID
                    )
                );
                defimons.whitelistSaleMint{ value: amounts[i] * WHITELIST_SALE_PRICE }(
                    WHITELIST_SALE_ID, addresses[i], amounts[i], amounts[i], merkleProofs[i]
                );
            }
        }
        assertEq(defimons.nextToMint(), whitelistMinted_ + 1);

        // go to public sale
        vm.warp(PUBLIC_SALE_START);
        saleParticipants_ = 3000;
        for (uint256 i = 0; i < saleParticipants_; i++) {
            _saleMint(PUBLIC_SALE_ID, vm.addr(999_999 + i), 0, 1, PUBLIC_SALE_PRICE, new bytes32[](0));
        }
        assertEq(defimons.nextToMint(), 3000 + 50 + 1);
        vm.expectRevert(
            abi.encodeWithSelector(DefimonsStarterMonsters.MaximumSaleMintSupplyReachedError.selector, PUBLIC_SALE_ID)
        );
        defimons.publicSaleMint{ value: PUBLIC_SALE_PRICE }(PUBLIC_SALE_ID, vm.addr(1234), 1, new bytes32[](0));

        saleParticipants_ = defimons.maxMint() - (3000 + 50);
        for (uint256 i = 0; i < saleParticipants_; i++) {
            _saleMint(PUBLIC_SALE_ID + 1, vm.addr(111_111 + i), 0, 1, PUBLIC_SALE_PRICE, new bytes32[](0));
        }
        assertEq(defimons.nextToMint(), defimons.maxMint() + 1);
        vm.expectRevert(DefimonsStarterMonsters.MaximumTotalMintSupplyReachedError.selector);
        defimons.publicSaleMint{ value: PUBLIC_SALE_PRICE }(PUBLIC_SALE_ID + 1, vm.addr(1234), 1, new bytes32[](0));

        // withdraw sale proceedings
        vm.prank(getOwner());
        uint256 expectedBalance = 50 * uint256(WHITELIST_SALE_PRICE) + 4450 * uint256(PUBLIC_SALE_PRICE);
        assertEq(address(defimons).balance, expectedBalance);
        defimons.withdrawEther(vm.addr(8888), expectedBalance);
        // perform withdraw assertions
        assertEq(address(defimons).balance, 0);
        assertEq(vm.addr(8888).balance, expectedBalance);

        vm.prank(getOwner());
        defimons.setMaxMint(MAX_MINT + 1000);
        assertEq(defimons.maxMint(), MAX_MINT + 1000);

        saleParticipants_ = 1000;
        for (uint256 i = 0; i < saleParticipants_; i++) {
            _saleMint(PUBLIC_SALE_ID + 1, vm.addr(222_222 + i), 0, 1, PUBLIC_SALE_PRICE, new bytes32[](0));
        }
        assertEq(defimons.nextToMint(), defimons.maxMint() + 1);
        vm.expectRevert(DefimonsStarterMonsters.MaximumTotalMintSupplyReachedError.selector);
        defimons.publicSaleMint{ value: PUBLIC_SALE_PRICE }(PUBLIC_SALE_ID + 1, vm.addr(1234), 1, new bytes32[](0));

        // withdraw sale proceedings
        vm.prank(getOwner());
        expectedBalance = 1000 * uint256(PUBLIC_SALE_PRICE);
        assertEq(address(defimons).balance, expectedBalance);
        uint256 recipientLastBalance_ = vm.addr(8888).balance;
        defimons.withdrawEther(vm.addr(8888), address(defimons).balance);
        // perform withdraw assertions
        assertEq(address(defimons).balance, 0);
        assertEq(vm.addr(8888).balance, recipientLastBalance_ + expectedBalance);

        vm.prank(getOwner());
        defimons.setMaxMint(MAX_MINT + 2000);
        vm.prank(getOwner());
        defimons.editSale(
            WHITELIST_SALE_ID,
            WHITELIST_SALE_START,
            PUBLIC_SALE_FINISH,
            WHITELIST_SALE_LIMIT,
            WHITELIST_SALE_PRICE,
            WHITELIST_SALE_WHITELIST,
            whitelistMerkleRoot,
            250 // mint more 200 for the whitelist sale
        );

        saleParticipants_ = 10;
        if (lastWhitelistedUserMintAmount_ != amounts[lastWhitelistedUserMint_]) {
            _saleMint(
                WHITELIST_SALE_ID,
                addresses[lastWhitelistedUserMint_],
                amounts[lastWhitelistedUserMint_],
                amounts[lastWhitelistedUserMint_] - lastWhitelistedUserMintAmount_,
                WHITELIST_SALE_PRICE,
                merkleProofs[lastWhitelistedUserMint_]
            );
        }
        vm.expectRevert(
            abi.encodeWithSelector(
                DefimonsStarterMonsters.MaximumSaleLimitReachedError.selector,
                WHITELIST_SALE_ID,
                addresses[lastWhitelistedUserMint_],
                amounts[lastWhitelistedUserMint_]
            )
        );
        vm.prank(addresses[lastWhitelistedUserMint_]);
        vm.deal(addresses[lastWhitelistedUserMint_], WHITELIST_SALE_PRICE);
        defimons.whitelistSaleMint{ value: WHITELIST_SALE_PRICE }(
            WHITELIST_SALE_ID,
            addresses[lastWhitelistedUserMint_],
            amounts[lastWhitelistedUserMint_],
            1,
            merkleProofs[lastWhitelistedUserMint_]
        );

        whitelistMinted_ = amounts[lastWhitelistedUserMint_] - lastWhitelistedUserMintAmount_;
        for (uint256 i = lastWhitelistedUserMint_ + 1; i < saleParticipants_ + lastWhitelistedUserMint_; i++) {
            if (whitelistMinted_ < 200) {
                _saleMint(
                    WHITELIST_SALE_ID,
                    addresses[i],
                    amounts[i],
                    Math.min(amounts[i], 200 - whitelistMinted_),
                    WHITELIST_SALE_PRICE,
                    merkleProofs[i]
                );
                if (whitelistMinted_ + amounts[i] >= 200) {
                    if (whitelistMinted_ + amounts[i] > 200) {
                        vm.expectRevert(
                            abi.encodeWithSelector(
                                DefimonsStarterMonsters.MaximumSaleMintSupplyReachedError.selector, WHITELIST_SALE_ID
                            )
                        );
                    } else {
                        vm.expectRevert(DefimonsStarterMonsters.ZeroMintQuantityError.selector);
                    }
                    defimons.whitelistSaleMint{ value: (amounts[i] - (200 - whitelistMinted_)) * WHITELIST_SALE_PRICE }(
                        WHITELIST_SALE_ID,
                        addresses[i],
                        amounts[i],
                        amounts[i] - (200 - whitelistMinted_),
                        merkleProofs[i]
                    );
                }
                whitelistMinted_ += Math.min(amounts[i], 200 - whitelistMinted_);
            } else {
                vm.expectRevert(
                    abi.encodeWithSelector(
                        DefimonsStarterMonsters.MaximumSaleMintSupplyReachedError.selector, WHITELIST_SALE_ID
                    )
                );
                defimons.whitelistSaleMint{ value: amounts[i] * uint256(WHITELIST_SALE_PRICE) }(
                    WHITELIST_SALE_ID, addresses[i], amounts[i], amounts[i], merkleProofs[i]
                );
            }
        }

        vm.prank(getOwner());
        defimons.editSale(
            WHITELIST_SALE_ID,
            WHITELIST_SALE_START,
            PUBLIC_SALE_FINISH,
            WHITELIST_SALE_LIMIT,
            WHITELIST_SALE_PRICE,
            WHITELIST_SALE_WHITELIST,
            whitelistMerkleRoot,
            1
        );
        assertEq(defimons.getSale(WHITELIST_SALE_ID).maxMint, 250);

        vm.prank(getOwner());
        defimons.setMaxMint(0);
        assertEq(defimons.maxMint(), MAX_MINT + 1000 + 200);
        assertEq(defimons.nextToMint(), defimons.maxMint() + 1);
    }
}
