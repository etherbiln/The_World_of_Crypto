# TieredWorlds NFT Ecosystem

![Advanced Tiered NFT Ecosystem](https://img.shields.io/badge/ERC-1155-blue)

A sophisticated multi-tier NFT system built on ERC-1155, featuring time-locked transfers, soulbound entry passes, and upgradeable tiers. Designed for exclusive membership ecosystems with progressive access levels.

## Key Features

- **Multi-Tier NFTs**: Four distinct tiers (Entry Pass + 3 upgradeable tiers)
- **Soulbound Entry Pass**: Non-transferable membership token
- **Time-Locked Transfers**: Tier NFTs locked until configurable unlock time
- **Progressive Upgrades**: Tier upgrading system (Silver → Gold → Platinum)
- **Dynamic Metadata**: On-chain metadata management with rarity tracking
- **Secure Transfers**: Enforcement of transfer lock periods

## Token Ecosystem

| Tier ID | Name          | Type       | Supply       | Transferable | Rarity      |
|---------|---------------|------------|--------------|--------------|-------------|
| 1       | Entry Pass    | Soulbound  | 1 per wallet | ❌ Never     |Common       |
| 2       | Silver Tier   | Upgradeable| Unique       | ✅ Post-lock | Common      |
| 3       | Gold Tier     | Upgradeable| Unique       | ✅ Post-lock | Rare        |
| 4       | Platinum Tier | Upgradeable| Unique       | ✅ Post-lock | Legendary   |