// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/// Mock ERC721 Token to be used for testing
contract MockERC721Token is ERC721 {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function mint(address user_, uint256 tokenId_) external{
        _mint(user_, tokenId_);
    }
}
