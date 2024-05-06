// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlogToEarnICO is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Stage {
        uint256 price;
        uint256 cliffDuration;
        uint256 tokensAllocated;
    }

    // Token and payment details
    IERC20 public token;
    IERC20 public usdt;

    // Administration
    address payable public ICOWallet;
    uint256 public raisedAmount;
    uint256 public minInvestment = 200000000; // in USDT (6 decimals)
    uint256 public maxInvestment = 5000000000000; // in USDT (6 decimals)
    uint256 public icoStartTime;
    uint256 public icoEndTime;
    Stage[4] public stages;

    // Investors' data
    mapping(address => mapping(uint256 => uint256)) public investedAmountOf;
    mapping(address => mapping(uint256 => uint256)) public vestedTokens;
    mapping(address => mapping(uint256 => uint256)) public cliffEndTime;

    // ICO State
    enum State {
        BEFORE,
        RUNNING,
        END,
        HALTED
    }
    State public ICOState;

    // Events
    event Invest(address indexed from, uint256 value, uint256 tokens, uint256 stage);
    event TokensClaimed(address indexed investor, uint256 amount, uint256 stage);
    event TokenWithdrawn(address to, uint256 amount, uint256 time);

    constructor(address payable _icoWallet, address _token, address _usdt) Ownable(msg.sender) {        ICOWallet = _icoWallet;
        token = IERC20(_token);
        usdt = IERC20(_usdt);

        stages[0] = Stage({price: 100000, cliffDuration: 182 days, tokensAllocated: 0}); // Stage 1: 0.1 USDT
        stages[1] = Stage({price: 150000, cliffDuration: 122 days, tokensAllocated: 0}); // Stage 2: 0.15 USDT
        stages[2] = Stage({price: 200000, cliffDuration: 61 days, tokensAllocated: 0});  // Stage 3: 0.2 USDT
        stages[3] = Stage({price: 250000, cliffDuration: 30 days, tokensAllocated: 0}); // Stage 4: 0.25 USDT
    }

    //Get ICO State
    function getICOState() external view returns (string memory) {
        if (ICOState == State.BEFORE) {
            return "Not Started";
        } else if (ICOState == State.RUNNING) {
            return "Running";
        } else if (ICOState == State.END) {
            return "End";
        } else {
            return "Halted";
        }
    }

    function invest(uint256 _usdtAmount, uint256 _stage) public returns (bool) {
        require(ICOState == State.RUNNING, "ICO isn't running");
        require(_stage < stages.length, "Invalid stage");
        Stage storage stage = stages[_stage];

        uint256 tokenAmount = _usdtAmount.mul(1e18).div(stage.price);
        require(tokenAmount >= minInvestment && tokenAmount <= maxInvestment, "Check Min and Max Investment");

        uint256 invested = investedAmountOf[msg.sender][_stage];
        require(invested.add(_usdtAmount) <= maxInvestment, "Investment limit exceeded");

        require(tokenAmount <= token.balanceOf(address(this)), "Insufficient tokens available");

        raisedAmount = raisedAmount.add(_usdtAmount);
        investedAmountOf[msg.sender][_stage] = invested.add(_usdtAmount);
        vestedTokens[msg.sender][_stage] = vestedTokens[msg.sender][_stage].add(tokenAmount);
        cliffEndTime[msg.sender][_stage] = block.timestamp.add(stage.cliffDuration);

        usdt.safeTransferFrom(msg.sender, ICOWallet, _usdtAmount);
        emit Invest(msg.sender, _usdtAmount, tokenAmount, _stage);
        return true;
    }

    function claimTokens(uint256 _stage) public {
        require(block.timestamp > cliffEndTime[msg.sender][_stage], "Cliff period is not over");
        uint256 amount = vestedTokens[msg.sender][_stage];
        require(amount > 0, "No tokens to claim");

        vestedTokens[msg.sender][_stage] = 0;
        token.safeTransfer(msg.sender, amount);
        emit TokensClaimed(msg.sender, amount, _stage);
    }

     // ADMIN FUNCTIONS

    //Start, Halt and End ICO
    function startICO() external onlyOwner {
        require(
            ICOState == State.BEFORE || ICOState == State.END,
            "ICO isn't in before state"
        );

        icoStartTime = block.timestamp;
        icoEndTime = icoStartTime + (86400 * 60);
        ICOState = State.RUNNING;
    }

    function haltICO() external onlyOwner {
        require(ICOState == State.RUNNING, "ICO isn't running yet");
        ICOState = State.HALTED;
    }

    function resumeICO() external onlyOwner {
        require(ICOState == State.HALTED, "ICO State isn't halted yet");
        ICOState = State.RUNNING;
    }

    //Change ICO Wallet
    function changeICOWallet(address payable _newICOWallet) external onlyOwner {
        ICOWallet = _newICOWallet;
    }

    //End ICO After reaching ICO Timelimit
    function endIco() public {
        require(ICOState == State.RUNNING, "ICO Should be in Running State");
        require(block.timestamp > icoEndTime, "ICO timelimit not reached");
        ICOState = State.END;
    }

    //Change ICO End time
    function changeIcoEndTime(uint256 _newTimestamp) external onlyOwner {
        require(ICOState == State.RUNNING, "ICO isn't running yet");
        icoEndTime = _newTimestamp;
    }

    //Withdraw remaining Tokens
    function withdrawTokens() external onlyOwner {
        require(ICOState == State.END, "ICO isn't over yet");

        uint256 remainingTokens = token.balanceOf(address(this));
        token.safeTransfer(owner(), remainingTokens);

        emit TokenWithdrawn(owner(), remainingTokens, block.timestamp);
    }

    //Usefull Getter Methods

    //Check ICO Contract Token Balance
    function getICOTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    //Check ICO Contract Investor Token Balance
    function investorBalanceOf(address _investor)
        external
        view
        returns (uint256)
    {
        return token.balanceOf(_investor);
    }
}
