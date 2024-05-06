// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AirdropLocker {
    using SafeERC20 for IERC20;

    IERC20 public bteToken;
    address public airdropWallet;
    uint256 public unlockTime;
    uint256 public constant LOCK_AMOUNT = 20_000_000 * 10**18; 

    constructor(address _bteTokenAddress, address _airdropWallet) {
        bteToken = IERC20(_bteTokenAddress);
        airdropWallet = _airdropWallet;
        unlockTime = block.timestamp + 182 days;  // 6 months from deployment
    }

    function releaseTokens() external {
        require(block.timestamp >= unlockTime, "Tokens are still locked");
        require(bteToken.balanceOf(address(this)) >= LOCK_AMOUNT, "Not enough tokens to release");

        bteToken.safeTransfer(airdropWallet, LOCK_AMOUNT);
    }

    // Optional: Add function to extend lock in case needed
    function extendLock(uint256 additionalTime) external {
        unlockTime += additionalTime;
    }

    // View function to check contract token balance
    function getLockedTokenBalance() public view returns (uint256) {
        return bteToken.balanceOf(address(this));
    }
}
