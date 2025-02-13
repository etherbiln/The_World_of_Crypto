# The World of Crypto - Technical Documentation

## Overview
**The World of Crypto** is a decentralized, blockchain-based exploration game where players travel across Earth, solve culturally themed questions, and earn rewards through NFTs and tokens. Built on Ethereum/Polygon, the game integrates smart contracts for secure ownership, transactions, and rewards.

---

## Game Mechanics

### 1. NFT Verification
- NFTs provide access to the game.
- Rarity levels (Common, Rare, Epic) determine potential bonus rewards.
- Players must own an NFT to participate.

### 2. Country Exploration
- Players travel across an interactive world map.
- Each country has a fixed travel fee, paid in WoC tokens.
- Travel fees vary based on country difficulty and exploration cost.

### 3. Question & Answer System
- Each country presents culturally themed questions.
- Answers are validated against an off-chain database.
- Correct answers provide rewards; incorrect answers allow continued play.

### 4. Rewards & Treasures
- Players earn rewards such as WoC tokens or rare NFTs.
- Randomized distribution ensures fairness and engagement.
- Hidden treasures provide additional incentives for exploration.

### 5. Early Exit & Refund
- Players can exit early and receive a partial refund of travel fees.
- Refunds are calculated as a percentage of the initial fee.
- This system provides flexibility for different play styles.

---

## Installation & Setup

### Prerequisites
- **Node.js** v16+
- **Truffle/Hardhat**
- **MetaMask** (sepolia network configured)
- **IPFS node** (for NFT metadata)

### Steps
#### Clone Repository:
```bash
git clone https://github.com/The_World_of_Cyrpto.git
cd WoC
```
#### Install Dependencies:
```bash
npm install
cd contracts && npm install @openzeppelin/contracts @chainlink/contracts
```
#### Deploy Contracts (Hardhat):
```bash
npx hardhat compile
npx hardhat run scripts/deploy.js --network sepolia
```
#### Configure Frontend:
```env
REACT_APP_CONTRACT_ADDRESS=0x...
REACT_APP_INFURA_ID=your_infura_key
```
---

## Configuration
- **Travel Fees**: Update `countryFees` in game logic.
- **Questions**: Modify the off-chain API `/questions/{countryId}`.
- **Refund Percentage**: Adjust refund calculation in the game logic.
- **Gas Optimization**: Use tools gas station to subsidize fees.

---

## Contributing
1. Fork the repository.
2. Write tests for new features (e.g., `test/example.test.js`).
3. Submit a PR with detailed comments.

---

## License
MIT License. See LICENSE for details.

## Contact
- **Dev Team**: yakupbln00@gmail.com