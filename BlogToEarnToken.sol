// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract BlogToEarnToken is ERC20, ERC20Burnable {
    // Supply of 1 Billion BTE Tokens
    constructor() ERC20("BlogToEarn", "BTE") {
        _mint(msg.sender, 1000000000 * 10**decimals());
    }
}
