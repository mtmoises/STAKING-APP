// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {

    StakingToken stakingToken;
    StakingApp stakingApp;

    string name_ = "Staking Token";
    string symbol_ = "STK";

    address Owner_ = vm.addr(1);
    uint256 stakingPeriod_ = 100000000000;
    uint256 fixedStakingAmount_ = 10;
    uint256 rewardPeriod_ = 1 ether;

    address randomUser = vm.addr(2);

    function setUp() external {
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp = new StakingApp(address(stakingToken), Owner_, stakingPeriod_, fixedStakingAmount_ , rewardPeriod_);
    }

    function testStakingTokenCorrectlyDeployed() external view {
        assert(address(stakingToken) != address(0));
    }

    function testStakingAppCorrectlyDeployed() external view {
        assert(address(stakingApp) != address(0));
    }


    function testShouldRevertIfNotOwner() external {
        uint256 newStakingPeriod_ = 1;

        vm.expectRevert();
        stakingApp.changesStakingPeriod(newStakingPeriod_);
    }


     function testShouldChangeStakingPeriod() external {
        vm.startPrank(Owner_);
        uint256 newStakingPeriod_ = 1;

        uint256 stakingPeriodBefore = stakingApp.stakingPeriod();
        stakingApp.changesStakingPeriod(newStakingPeriod_);
        uint256 stakingPeriodAfter = stakingApp.stakingPeriod();

        assert(stakingPeriodBefore != newStakingPeriod_);
        assert(stakingPeriodAfter == newStakingPeriod_);

        vm.stopPrank();
    }

function testContractReceivesEtherCorrectly() external {
    vm.startPrank(Owner_);
    vm.deal(Owner_, 1 ether);

    uint256 etherValue = 1 ether;
    uint256 balanceBefore = address(stakingApp).balance;
    (bool success, ) = address(stakingApp).call{value: etherValue}("");
    uint256 balanceAfter = address(stakingApp).balance;
    require(success, "transfer failed");

    assert(balanceAfter - balanceBefore == etherValue);

    vm.stopPrank();
}

function testIncorrectAmountShouldRevert() external {
    vm.startPrank(randomUser);

    uint256 depositAmount = 1;
    vm.expectRevert("Incorrect Amount");
    stakingApp.depositTokens(depositAmount);

    vm.stopPrank();

}

   function testDepositTokensCorrectly() external {
    vm.startPrank(randomUser);

    uint256 tokenAmount = stakingApp.fixedStakingAmount();
    stakingToken.mint(tokenAmount);

    uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
    IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
    stakingApp.depositTokens(tokenAmount);
    uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

    assert(userBalanceAfter - userBalanceBefore == tokenAmount);
    assert(userBalanceBefore == 0);
    assert(elapsePeriodBefore == 0); // <--- ESTA LINEA AGREGALA
    assert(elapsePeriodAfter == block.timestamp);

    vm.stopPrank();
}
    function testUserCannotDepositMoreThanOnce() external {
    vm.startPrank(randomUser);

    uint256 tokenAmount = stakingApp.fixedStakingAmount();
    stakingToken.mint(tokenAmount);

    uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
    IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
    stakingApp.depositTokens(tokenAmount);
    uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

    assert(userBalanceAfter - userBalanceBefore == tokenAmount);
    assert(userBalanceBefore == 0);
    assert(elapsePeriodBefore == 0); 
    assert(elapsePeriodAfter == block.timestamp);

    stakingToken.mint(tokenAmount);
    IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
    vm.expectRevert("User already deposited");
    stakingApp.depositTokens(tokenAmount);

    vm.stopPrank();
}

    function testCanOnlyWithdraw0WithoutDeposit() external {
    vm.startPrank(randomUser);

    uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
    
    vm.expectRevert();
    stakingApp.withdrawTokens();

    uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
    assert(userBalanceAfter == userBalanceBefore);

    vm.stopPrank();
}

    function testWithdrawTokensCorrectly() external {
        vm.startPrank(randomUser);

    uint256 tokenAmount = stakingApp.fixedStakingAmount();
    stakingToken.mint(tokenAmount);


    uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
    IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
    stakingApp.depositTokens(tokenAmount);
    uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

    assert(userBalanceAfter - userBalanceBefore == tokenAmount);
    assert(userBalanceBefore == 0);
    assert(elapsePeriodBefore == 0); 
    assert(elapsePeriodAfter == block.timestamp);

    uint256 userBalanceBefore2 = IERC20(stakingToken).balanceOf(randomUser);
    uint256 userBalanceInMapping = stakingApp.userBalance(randomUser);
    stakingApp.withdrawTokens();
    uint256 userBalanceAfter2 = IERC20(stakingToken).balanceOf(randomUser);
    
    assert(userBalanceAfter2 == userBalanceBefore2 + userBalanceInMapping);

    vm.stopPrank();

}

    // ClaimRewards function Test

    function testCanNotClaimIfNotstaking() external {
        vm.startPrank(randomUser);

        vm.expectRevert("Not staking");
        stakingApp.claimRewards();

        vm.stopPrank();

    }

    function testShouldRevertIfNotEther() external {
        vm.startPrank(randomUser);

         uint256 tokenAmount = stakingApp.fixedStakingAmount();
    stakingToken.mint(tokenAmount);

    uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
    IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
    stakingApp.depositTokens(tokenAmount);
    uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

    assert(userBalanceAfter - userBalanceBefore == tokenAmount);
    assert(userBalanceBefore == 0);
    assert(elapsePeriodBefore == 0); 
    assert(elapsePeriodAfter == block.timestamp);

    vm.warp(block.timestamp + stakingPeriod_);
    vm.expectRevert("Transfer failed");
    stakingApp.claimRewards();

    vm.stopPrank();

    }

    function testCanClaimRewardsCorrectly() external {
        vm.startPrank(randomUser);

         uint256 tokenAmount = stakingApp.fixedStakingAmount();
    stakingToken.mint(tokenAmount);

    uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
    IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
    stakingApp.depositTokens(tokenAmount);
    uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
    uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

    assert(userBalanceAfter - userBalanceBefore == tokenAmount);
    assert(userBalanceBefore == 0);
    assert(elapsePeriodBefore == 0); 
    assert(elapsePeriodAfter == block.timestamp);
    vm.stopPrank();
    
    vm.startPrank(Owner_);
    uint256 etherAmount = 100000 ether;
    vm.deal(Owner_, etherAmount);
    (bool success, ) = address(stakingApp).call{value: etherAmount}("");
    require(success);
    vm.stopPrank();

    vm.startPrank(randomUser);
    vm.warp(block.timestamp + stakingPeriod_);
    uint256 etherAmountBefore = address(randomUser).balance;
    stakingApp.claimRewards();
    uint256 etherAmountafter = address(randomUser).balance;
    uint256 elapsePeriod = stakingApp.elapsePeriod(randomUser);

   assert(etherAmountafter - etherAmountBefore == rewardPeriod_);
    assert(elapsePeriod == block.timestamp);
    
    vm.stopPrank();

    }



}




