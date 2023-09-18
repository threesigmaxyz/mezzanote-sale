// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/// Mock ERC20 Token to be used for testing
contract MockToken is ERC20 {
    constructor(string memory name_, string memory symbol_, uint256 initialAmount_) ERC20(name_, symbol_) {
        _mint(msg.sender, initialAmount_);
    }
}
