# 🥩 Fixed-Term Staking Smart Contract & Ecosystem

A secure, gas-optimized token staking and reward distribution smart contract suite built with **Solidity 0.8.24** and fully tested using **Foundry**. 

This contract allows users to deposit a fixed amount of ERC-20 tokens for a defined staking period and earn native Ether (ETH) rewards upon successful completion.

---

## 📌 Architecture & Features

- **Fixed-Term Lockup:** Enforces a rigid staking period (`stakingPeriod`) and a fixed deposit amount (`fixedStakingAmount`) to manage protocol liquidity securely.
- **Native Reward Distribution:** Distributes native ETH rewards (`rewardPeriod`) to stakers upon successful completion of the lockup time.
- **Reentrancy & CEI Compliance:** Follows Checks-Effects-Interactions patterns on core deposit and withdrawal paths.
- **Admin Controls:** Utilizes OpenZeppelin's `Ownable` modifier to restrict critical state changes (such as modifying staking periods) to the contract owner.
- **Robust Test Coverage:** Includes unit and integration tests covering positive flows, edge cases, time-warp simulations via Foundry, and failure paths.

---

## 🛠 Tech Stack & Tools

- **Language:** Solidity `0.8.24`
- **Framework:** Foundry (Forge & Cast)
- **Libraries:** OpenZeppelin Contracts (`Ownable`, `IERC20`)
- **Target Network:** EVM Compatible Chains

---

## 🚀 Smart Contract Overview

### Core Functions

1. **`depositTokens(uint256 TokenAmountToDeposit_)`**
   - Validates that the deposited amount matches `fixedStakingAmount`.
   - Ensures the user hasn't already active positions (`userBalance == 0`).
   - Transfers tokens safely from user to contract using `transferFrom`.

2. **`withdrawTokens()`**
   - Permite al usuario retirar la totalidad de sus tokens depositados una vez finalizado el ciclo o si decide salir, reseteando su balance en el contrato.

3. **`claimRewards()`**
   - Verifica que el usuario cumpla con el tiempo de bloqueo (`block.timestamp - elapsePeriod >= stakingPeriod`).
   - Transfiere la recompensa en ETH acumulada al usuario (`msg.sender.call{value: rewardPeriod}`).

---

## ⚡ Quickstart & Testing (Foundry)

### 1. Clone Repository & Install Dependencies
```bash
git clone [https://github.com/mtmoises/staking-app.git](https://github.com/mtmoises/staking-app.git)
cd staking-app
forge install

```shell
$ forge --help
$ anvil --help
$ cast --help
```
