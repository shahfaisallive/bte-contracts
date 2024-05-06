// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BTEStaking is ReentrancyGuard {
    IERC20 public bteToken;
    uint256 public constant MAX_APY = 12; 

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 stakingMonths;
        bool isFixed;
    }

    mapping(address => Stake[]) public stakes;

    event Staked(address indexed user, uint256 amount, uint256 stakingMonths, bool isFixed);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);

    constructor(address _bteTokenAddress) {
        bteToken = IERC20(_bteTokenAddress);
    }

    function stake(uint256 _amount, uint256 _stakingMonths, bool _isFixed) external nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");
        require(bteToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        stakes[msg.sender].push(Stake({
            amount: _amount,
            startTime: block.timestamp,
            stakingMonths: _stakingMonths,
            isFixed: _isFixed
        }));

        emit Staked(msg.sender, _amount, _stakingMonths, _isFixed);
    }

    function unstake(uint index) external nonReentrant {
        Stake memory userStake = stakes[msg.sender][index];
        require(userStake.amount > 0, "No stake found");
        require(block.timestamp >= userStake.startTime + userStake.stakingMonths * 30 days || !userStake.isFixed, "Stake is locked");

        uint256 monthsStaked = (block.timestamp - userStake.startTime) / 30 days;
        uint256 reward = calculateReward(userStake.amount, monthsStaked, userStake.isFixed);
        require(bteToken.transfer(msg.sender, userStake.amount + reward), "Transfer failed");

        emit Unstaked(msg.sender, userStake.amount, reward);

        delete stakes[msg.sender][index];
    }

    function calculateReward(uint256 _amount, uint256 _monthsStaked, bool _isFixed) private pure returns (uint256) {
        uint256 rate;
        if (_isFixed) {
            rate = 10 + (30 * (_monthsStaked / 3)); 
        } else {
            rate = (_monthsStaked >= 1) ? MAX_APY : 0; 
        }
        return _amount * rate / 100;
    }

    function getStakes(address _user) public view returns (Stake[] memory) {
        return stakes[_user];
    }
}
