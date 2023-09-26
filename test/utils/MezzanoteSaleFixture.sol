// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "src/dependencies/threesigma-contracts/contracts/foundry-test-helpers/MerkleTreeTestHelper.sol";
import "./MockERC721Token.sol";
import "src/MezzanoteSale.sol";

contract MezzanoteSaleFixture is MerkleTreeTest {
    // Constants
    uint256 MOCK_SALE_ID_W = 0; // Whitelist sale
    uint256 MOCK_SALE_ID_P = 1; // Public sale
    uint64 MOCK_SALE_W_START = 1; // Whitelist sale
    uint64 MOCK_SALE_W_FINISH = 2 hours; // Whitelist sale
    uint64 MOCK_SALE_P_START = 1 + 2 hours; // Public sale
    uint64 MOCK_SALE_P_FINISH = 1 + 4 hours; // Public sale
    uint8 MOCK_SALE_LIMIT = 10;
    uint64 MOCK_SALE_PRICE = 0.069 ether;
    uint40 MOCK_SALE_MAX_MINT = 530;
    uint256 STARTING_ID = 25;

    uint256 MAX_MINT = 530;

    // Events
    event LogSetURI(string newURI);
    event LogSale(uint256 indexed saleId, address indexed to, uint256 quantity);
    event LogSetMaxMint(uint256 oldMaxMint, uint256 _newMaxMint);
    event LogSaleEdited(
        uint256 indexed saleId,
        uint64 start,
        uint64 finish,
        uint8 limit,
        uint64 price,
        bool whitelist,
        bytes32 root,
        bool hasMaxMint,
        uint40 maxMint
    );

    MezzanoteSale mezzanote;

    bytes32 public whitelistMerkleRoot;

    MockERC721Token NFTToken;

    function setUp() public virtual {
        /// generate and update merkle root (whitelist)
        updateMerkleTree("snapshot/Data/OwnersSnapshot.csv");

        NFTToken = new MockERC721Token("MezzanoteSale", "MS");

        // deploy MezzanoteSale.sol
        vm.prank(getOwner());
        mezzanote = new MezzanoteSale(
            address(NFTToken),                              // address of NFT
            uint64(block.timestamp),                        // Start date
            whitelistMerkleRoot                             // Root for whitelist sale
        );
    }

    // === Sale Helpers ===

    function _saleMint(
        uint256 saleId_,
        address user_,
        uint256 userAllowance_,
        uint256 quantity_,
        uint64 price_,
        bytes32[] memory proof_
    ) internal {
        // setup
        vm.deal(user_, quantity_ * price_);
        uint256 prevMinted = mezzanote.nextToMint();
        uint256 prevBalance = address(mezzanote).balance;

        uint256 prevUserMinted_ = mezzanote.getMintedAmount(saleId_, user_);
        // sale mint
        vm.expectEmit(true, false, false, true);
        emit LogSale(saleId_, user_, quantity_);
        vm.prank(user_);
        userAllowance_ == 0
            ? mezzanote.publicSaleMint{ value: quantity_ * price_ }(saleId_, user_, quantity_)
            : mezzanote.whitelistSaleMint{ value: quantity_ * price_ }(saleId_, user_, quantity_, proof_);

        // perform assertions
        assertEq(mezzanote.nextToMint(), prevMinted + quantity_);
        assertEq(mezzanote.getMintedAmount(saleId_, user_), quantity_ + prevUserMinted_);
        assertEq(NFTToken.balanceOf(user_), quantity_ + prevUserMinted_);
        for (uint256 i = 0; i < quantity_; i++) {
            assertEq(NFTToken.ownerOf(prevMinted + i), user_);
        }
        assertEq(user_.balance, 0);
        assertEq(address(mezzanote).balance, prevBalance + quantity_ * price_);
    }

    function _editMockSale(bool whitelist_) internal {
        mezzanote.editSale(
            MOCK_SALE_ID_W,
            MOCK_SALE_W_START,
            MOCK_SALE_W_FINISH,
            MOCK_SALE_LIMIT,
            MOCK_SALE_PRICE,
            whitelist_,
            whitelistMerkleRoot,
            MOCK_SALE_MAX_MINT
        );
    }

    function _editMockSaleAndValidate(bool whitelist_) internal {
        bool hasMaxMint = mezzanote.getSale(MOCK_SALE_ID_W).hasMaxMint;
        _validateLogMockSaleEdited(whitelist_, hasMaxMint);
        vm.prank(getOwner());
        _editMockSale(whitelist_);
        _validateMockSale(whitelist_, hasMaxMint);
    }

    function _validateLogMockSaleEdited(bool whitelist_, bool hasMaxMint_) internal {
        vm.expectEmit(true, false, false, true);
        emit LogSaleEdited(
            MOCK_SALE_ID_W,
            MOCK_SALE_W_START,
            MOCK_SALE_W_FINISH,
            MOCK_SALE_LIMIT,
            MOCK_SALE_PRICE,
            whitelist_,
            whitelistMerkleRoot,
            hasMaxMint_,
            MOCK_SALE_MAX_MINT
        );
    }

    function _validateMockSale(bool whitelist_, bool hasMaxMint_) internal {
        MezzanoteSale.Sale memory sale = mezzanote.getSale(MOCK_SALE_ID_W);
        assertEq(sale.start, MOCK_SALE_W_START);
        assertEq(sale.finish, MOCK_SALE_W_FINISH);
        assertEq(sale.limit, MOCK_SALE_LIMIT);
        assertEq(sale.price, MOCK_SALE_PRICE);
        assertEq(sale.whitelist, whitelist_);
        assertEq(sale.root, whitelistMerkleRoot);
        assertEq(sale.hasMaxMint, hasMaxMint_);
        assertEq(sale.maxMint, MOCK_SALE_MAX_MINT);
    }

    // === Other ===

    function getOwner() public pure returns (address) {
        return vm.addr(1337);
    }

    function updateMerkleTree(string memory whitelistFilename_) public {
        setMerkleTree(whitelistFilename_);
        whitelistMerkleRoot = root;
    }
}
