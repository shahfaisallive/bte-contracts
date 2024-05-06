// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlogToEarnReward is ERC20, ERC20Burnable, Ownable(msg.sender) {
    bool public paused;

    constructor() ERC20("BlogToEarnReward", "BRT") {}

    function claimReward(uint256 amount) public {
        require(!paused, "Minting is paused");
        _mint(msg.sender, amount);
    }

    function togglePause() public onlyOwner {
        paused = !paused;
    }
}
