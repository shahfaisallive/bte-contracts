// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract BTEAdvisorsVesting {
    IERC20 public bteToken;
    address public advisorsAddress;
    uint256 public constant totalAllocation = 40000000 * 10**18; 
    uint256 public constant vestingAmount = totalAllocation / 10; 
    uint256 public lastVestingTime;
    uint256 public amountVested;
    bool public cliffPeriodPassed = false;

    constructor(address _bteTokenAddress, address _advisorsAddress) {
        bteToken = IERC20(_bteTokenAddress);
        advisorsAddress = _advisorsAddress;
        lastVestingTime = block.timestamp + 182 days; 
    }

    function releaseTokens() public {
        require(block.timestamp >= lastVestingTime, "It is not time for the next vesting yet");
        require(amountVested < totalAllocation, "All tokens have been vested");
        if (!cliffPeriodPassed) {
            cliffPeriodPassed = true;
        } else {
            require(block.timestamp >= lastVestingTime + 182 days, "Less than 6 months since last vesting");
        }

        uint256 vesting = (block.timestamp >= lastVestingTime + 182 days) ? vestingAmount : 0;
        require(vesting > 0, "No tokens to vest at this time");

        amountVested += vesting;
        lastVestingTime = block.timestamp; 
        require(bteToken.transfer(advisorsAddress, vesting), "Token transfer failed");
    }
}
