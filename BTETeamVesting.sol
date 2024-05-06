// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract BTETeamVesting {
    IERC20 public bteToken;
    // Placeholder Address
    address[8] public teamMembers = [
        address(0xE6F39fc8f0ed0a2F7Ab9F1Ef0c225E7640F954fD),
        address(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db), 
        address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB),
        address(0x617F2E2fD72FD9D5503197092aC168c91465E7f2),
        address(0x17F6AD8Ef982297579C203069C1DbfFE4348c372), 
        address(0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678),
        address(0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7),
        address(0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C)
    ];

    uint256 public constant totalVestingAmount = 160000000 * 10**18; // 16% of 1 billion tokens
    uint256 public constant biAnnualVestingAmount = totalVestingAmount / 10; // Distribute over 5 Years
    uint256 public lastDistributionTime;
    uint256 public distributionCount;

    constructor(address _bteTokenAddress) {
        bteToken = IERC20(_bteTokenAddress);
        lastDistributionTime = block.timestamp;
    }

    function distributeTokens() public {
        require(block.timestamp >= lastDistributionTime + 182 days, "Too early for next distribution");
        require(distributionCount < 10, "Vesting completed");

        for (uint256 i = 0; i < teamMembers.length; i++) {
            bteToken.transfer(teamMembers[i], biAnnualVestingAmount / teamMembers.length);
        }

        distributionCount++;
        lastDistributionTime = block.timestamp;
    }
}
