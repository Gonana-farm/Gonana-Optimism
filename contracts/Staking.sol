// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "GonaToken";

contract StakingContract is Ownable {
    using SafeMath for uint256;

    GonaToken public gonaToken;
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public lastClaimTime;

    uint256 public rewardRate = 1; // Gona tokens per second

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 amount);

    constructor(GonaToken _gonaToken) {
        gonaToken = _gonaToken;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        updateReward(msg.sender);

        gonaToken.transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender].add(amount);

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(stakingBalance[msg.sender] >= amount, "Insufficient staked balance");

        updateReward(msg.sender);

        gonaToken.transfer(msg.sender, amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender].sub(amount);

        emit Unstaked(msg.sender, amount);
    }

    function claimReward() external {
        updateReward(msg.sender);

        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to claim");

        gonaToken.mint(msg.sender, reward);
        lastClaimTime[msg.sender] = block.timestamp;

        emit RewardClaimed(msg.sender, reward);
    }

    function updateReward(address account) internal {
        uint256 currentTime = block.timestamp;
        uint256 elapsedTime = currentTime - lastClaimTime[account];

        uint256 newReward = elapsedTime.mul(rewardRate);
        stakingBalance[account] = stakingBalance[account].add(newReward);
        lastClaimTime[account] = currentTime;
    }

    function calculateReward(address account) public view returns (uint256) {
        uint256 elapsedTime = block.timestamp - lastClaimTime[account];
        return elapsedTime.mul(rewardRate);
    }

    function setRewardRate(uint256 newRewardRate) external onlyOwner {
        rewardRate = newRewardRate;
    }
}

//improvements to come...
//emergency withdraw...
//custom errors
//safemath
//onlystakers mod
