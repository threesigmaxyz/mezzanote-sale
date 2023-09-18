// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "src/dependencies/threesigma-contracts/contracts/foundry-test-helpers/MerkleTreeTestHelper.sol";

import "src/DefimonsStarterMonsters.sol";

contract DefimonsFixture is MerkleTreeTest {
    // Constants
    uint256 MOCK_SALE_ID = 0;
    uint64 MOCK_SALE_START = 123;
    uint64 MOCK_SALE_FINISH = 420;
    uint8 MOCK_SALE_LIMIT = 3;
    uint64 MOCK_SALE_PRICE = 0.1337 ether;
    uint40 MOCK_SALE_MAX_MINT = 400;

    uint256 MAX_MINT = 4500;

    // Events
    event LogSetURI(string newURI);
    event LogSaleCreated(
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
    event LogSale(uint256 indexed saleId, address indexed to, uint256 quantity);
    event LogSetMaxMint(uint256 oldMaxMint, uint256 _newMaxMint);

    event LogOwnerMint(address[] users, uint256[] amounts);

    DefimonsStarterMonsters defimons;

    bytes32 public whitelistMerkleRoot;

    function setUp() public virtual {
        /// generate and update merkle root (whitelist)
        updateMerkleTree("snapshot/Data/OwnersSnapshot.csv");

        // deploy DefimonsStarterMonsters.sol
        vm.prank(getOwner());
        defimons = new DefimonsStarterMonsters(
            "DefimonsStarterMonsters",                      // Name
            "DFMSM",                                        // Symbol
            0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706,     // LayerZero endpoint
            "https://defimons.com",                         // Metadata uri
            MAX_MINT
        );
    }

    // === Sale Helpers ===

    function _addSale(
        uint256 saleId_,
        uint64 start_,
        uint64 finish_,
        uint8 limit_,
        uint64 price_,
        bool whitelist_,
        bytes32 root_,
        bool hasMaxMint_,
        uint40 maxMint_
    ) internal {
        // add sale
        vm.expectEmit(true, false, false, true);
        emit LogSaleCreated(saleId_, start_, finish_, limit_, price_, whitelist_, root_, hasMaxMint_, maxMint_);
        vm.prank(getOwner());
        defimons.addSale(start_, finish_, limit_, price_, whitelist_, root_, hasMaxMint_, maxMint_);

        // perform assertions
        DefimonsStarterMonsters.Sale memory sale = defimons.getSale(saleId_);
        assertEq(sale.start, start_);
        assertEq(sale.finish, finish_);
        assertEq(sale.price, price_);
        assertEq(sale.limit, limit_);
        assertEq(sale.whitelist, whitelist_);
        assertEq(sale.root, root_);
        assertEq(sale.maxMint, maxMint_);
    }

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
        uint256 prevMinted = defimons.nextToMint();
        uint256 prevBalance = address(defimons).balance;

        uint256 prevUserMinted_ = defimons.getMintedAmount(saleId_, user_);
        // sale mint
        vm.expectEmit(true, false, false, true);
        emit LogSale(saleId_, user_, quantity_);
        vm.prank(user_);
        userAllowance_ == 0
            ? defimons.publicSaleMint{ value: quantity_ * price_ }(saleId_, user_, quantity_, proof_)
            : defimons.whitelistSaleMint{ value: quantity_ * price_ }(saleId_, user_, userAllowance_, quantity_, proof_);

        // perform assertions
        assertEq(defimons.nextToMint(), prevMinted + quantity_);
        assertEq(defimons.getMintedAmount(saleId_, user_), quantity_ + prevUserMinted_);
        assertEq(defimons.balanceOf(user_), quantity_ + prevUserMinted_);
        for (uint256 i = 0; i < quantity_; i++) {
            assertEq(defimons.ownerOf(prevMinted + i), user_);
        }
        assertEq(user_.balance, 0);
        assertEq(address(defimons).balance, prevBalance + quantity_ * price_);
    }

    function _addMockSale(bool whitelist_, bool hasMaxMint_) internal {
        defimons.addSale(
            MOCK_SALE_START,
            MOCK_SALE_FINISH,
            MOCK_SALE_LIMIT,
            MOCK_SALE_PRICE,
            whitelist_,
            whitelistMerkleRoot,
            hasMaxMint_,
            MOCK_SALE_MAX_MINT
        );
    }

    function _addMockSaleAndValidate(bool whitelist_, bool hasMaxMint_) internal {
        _validateLogMockSaleCreated(whitelist_, hasMaxMint_);
        vm.prank(getOwner());
        _addMockSale(whitelist_, hasMaxMint_);
        _validateMockSale(whitelist_, hasMaxMint_);
    }

    function _editMockSale(bool whitelist_) internal {
        defimons.editSale(
            MOCK_SALE_ID,
            MOCK_SALE_START,
            MOCK_SALE_FINISH,
            MOCK_SALE_LIMIT,
            MOCK_SALE_PRICE,
            whitelist_,
            whitelistMerkleRoot,
            MOCK_SALE_MAX_MINT
        );
    }

    function _editMockSaleAndValidate(bool whitelist_) internal {
        bool hasMaxMint = defimons.getSale(MOCK_SALE_ID).hasMaxMint;
        _validateLogMockSaleEdited(whitelist_, hasMaxMint);
        vm.prank(getOwner());
        _editMockSale(whitelist_);
        _validateMockSale(whitelist_, hasMaxMint);
    }

    function _validateLogMockSaleCreated(bool whitelist_, bool hasMaxMint_) internal {
        vm.expectEmit(true, false, false, true);
        emit LogSaleCreated(
            MOCK_SALE_ID,
            MOCK_SALE_START,
            MOCK_SALE_FINISH,
            MOCK_SALE_LIMIT,
            MOCK_SALE_PRICE,
            whitelist_,
            whitelistMerkleRoot,
            hasMaxMint_,
            MOCK_SALE_MAX_MINT
        );
    }

    function _validateLogMockSaleEdited(bool whitelist_, bool hasMaxMint_) internal {
        vm.expectEmit(true, false, false, true);
        emit LogSaleEdited(
            MOCK_SALE_ID,
            MOCK_SALE_START,
            MOCK_SALE_FINISH,
            MOCK_SALE_LIMIT,
            MOCK_SALE_PRICE,
            whitelist_,
            whitelistMerkleRoot,
            hasMaxMint_,
            MOCK_SALE_MAX_MINT
        );
    }

    function _validateMockSale(bool whitelist_, bool hasMaxMint_) internal {
        DefimonsStarterMonsters.Sale memory sale = defimons.getSale(MOCK_SALE_ID);
        assertEq(sale.start, MOCK_SALE_START);
        assertEq(sale.finish, MOCK_SALE_FINISH);
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
