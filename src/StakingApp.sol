// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingApp is Ownable {
    
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public rewardPeriod;
    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public elapsePeriod;

    event ChangesStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address useraddress_, uint256 depositAmount_);
    event WithdrawTokens(address userAddress_, uint256 withdrawAmount_);
    event EtherSent(uint256 amount_);
    
    constructor(address stakingToken_, address Owner_, uint256 stakingPeriod_, uint256 fixedStakingAmount_, uint256 rewardPeriod_) Ownable(Owner_) {
        require(stakingToken_ != address(0) && Owner_ != address(0), "zero address");
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        rewardPeriod = rewardPeriod_;
   }

    //1.DEPOSIT - ARREGLADO CEI
    function depositTokens(uint256 TokenAmountToDeposit_) external {
    require(TokenAmountToDeposit_ == fixedStakingAmount, "Incorrect Amount");
    require(userBalance[msg.sender] == 0,"User already deposited");

    // forge-lint: disable-next-line(missing-events-access-control)
    userBalance[msg.sender] += TokenAmountToDeposit_;
    elapsePeriod[msg.sender] = block.timestamp;
    emit DepositTokens(msg.sender, TokenAmountToDeposit_);

    bool ok = IERC20(stakingToken).transferFrom(msg.sender, address(this), TokenAmountToDeposit_);
    require(ok, "transferFrom failed");
}
    //2.WIthdraw - ARREGLADO CEI
    function withdrawTokens() external {
        uint256 userBalance_ = userBalance[msg.sender];
        require(userBalance_ > 0, "no balance");

        userBalance[msg.sender] = 0;
        emit WithdrawTokens(msg.sender, userBalance_);

        bool ok = IERC20(stakingToken).transfer(msg.sender, userBalance_);
        require(ok, "transfer failed");
    }

    //3.claim Rewards
    function claimRewards() external {
        require(userBalance[msg.sender] == fixedStakingAmount, "Not staking");

        uint256 elapsePeriod_ = block.timestamp - elapsePeriod[msg.sender];
        // forge-lint: disable-next-line(block-timestamp)
        require(elapsePeriod_ >= stakingPeriod, "need to wait");

        elapsePeriod[msg.sender] = block.timestamp;

        (bool success,) = msg.sender.call{value: rewardPeriod}("");
        require(success, "Transfer failed");
    }    

    receive() external payable onlyOwner {
    emit EtherSent(msg.value);
}
  
    function changesStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;
        emit ChangesStakingPeriod(newStakingPeriod_);
    }
}




