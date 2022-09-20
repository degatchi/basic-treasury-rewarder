pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// --------------------------------------------------------------------------------------
//
// (c) TreasuryRewarder 20/09/2022 | SPDX-License-Identifier: AGPL-3.0-only
//  Built by, DeGatchi (https://github.com/DeGatchi).
//
// --------------------------------------------------------------------------------------

interface IRewarder {
    function claimRewards() external;
    function depositEth() external payable;
}

error ZeroAmount();
error DepositsLocked(uint256 currentTime, uint256 openTime);
error Overflow(uint256 given, uint256 limit);
contract Rewarder is IRewarder, Ownable {
    event DepositEth(address indexed user, uint256 indexed amount);
    event ReleaseRewards(uint256 indexed amount);
    event ClaimRewards(address indexed claimee, uint256 indexed eth, uint256 indexed usdc);

    constructor(address _usdc) {
        usdc = IERC20(_usdc);
    }

    IERC20 public usdc;

    uint256 public lockAfterReleaseRewards;
    uint256 public maxDeposit = 20 ether;

    uint256 public totalEth;

    mapping(address => uint256) public user;

    /// Transfers 1000 USDC from <treasury> to this contract.
    function releaseRewards(address treasury) external onlyOwner {
        usdc.transferFrom(treasury, address(this), 1_000e18);
        lockAfterReleaseRewards = block.timestamp + 1 days;
        emit ReleaseRewards(1_000e18);
    }

    /// Allows uers to deposit ETH.
    function depositEth() external override payable {
        if (lockAfterReleaseRewards > block.timestamp) revert DepositsLocked(block.timestamp, lockAfterReleaseRewards);
        if (msg.value == 0) revert ZeroAmount();
        if (user[msg.sender] + msg.value > maxDeposit) revert Overflow(user[msg.sender] + msg.value, maxDeposit);
        unchecked { 
            user[msg.sender] += msg.value; 
            totalEth += msg.value;
        }
        emit DepositEth(msg.sender, msg.value);
    }

    /// Allows users to receive USDC based on their share of the total ETH deposited.
    function claimRewards() external override {
        if (totalEth == 0) revert ZeroAmount();
        uint256 usdcBal = usdc.balanceOf(address(this));
        if (usdcBal == 0) revert ZeroAmount();

        uint256 eth = user[msg.sender];
        uint256 shareAmount = (1_000e18 * eth) / totalEth;

        unchecked { user[msg.sender] -= eth; }
        usdc.transfer(msg.sender, shareAmount);
        payable(msg.sender).transfer(eth);

        emit ClaimRewards(msg.sender, eth, shareAmount);
    }

    // Allow contract to receive ETH.
    receive() external payable {}
}