// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Advanced Tiered NFT Ecosystem
 * @dev ERC1155 implementation with multi-tier NFTs, time locks, and upgrade functionality
 */
contract TieredWorlds is ERC1155, Ownable {
    // Token ID Definitions
    uint256 public constant ENTRY_PASS = 1;
    uint256 public constant TIER1_NFT = 2;
    uint256 public constant TIER2_NFT = 3;
    uint256 public constant TIER3_NFT = 4;

    // Token Metadata Structure
    struct NFTMetadata {
        string name;
        string description;
        string image;
        string rarity;
        uint256 unlockTime;
    }

    // Storage Mappings
    mapping(address => bool) private _hasEntryPass;
    mapping(uint256 => NFTMetadata) private _tokenMetadata;
    mapping(uint256 => bool) private _tierMintLocks;

    // Events
    event EntryPassMinted(address indexed account);
    event TierNFTMinted(address indexed account, uint256 tier);
    event TierUpgraded(address indexed account, uint256 fromTier, uint256 toTier);
    event MetadataUpdated(uint256 indexed tokenId);

    constructor(string memory baseURI) ERC1155(baseURI) Ownable(msg.sender) {
        _initializeMetadata();
    }

    ////////////////////////////
    //  Public Interactions   //
    ////////////////////////////

    /// @notice Allows public minting of Entry Pass NFT
    function mintEntryPass() external {
        require(!_hasEntryPass[msg.sender], "Already owns Entry Pass");
        _hasEntryPass[msg.sender] = true;
        _mint(msg.sender, ENTRY_PASS, 1, "");
        emit EntryPassMinted(msg.sender);
    }

    /// @notice Allows tier upgrades by burning lower tier NFTs
    function upgradeTier(uint256 fromTier, uint256 toTier) external onlyOwner {
        require(_validUpgradePath(fromTier, toTier), "Invalid upgrade path");
        require(balanceOf(msg.sender, fromTier) > 0, "No NFT to upgrade");
        
        _burn(msg.sender, fromTier, 1);
        _mint(msg.sender, toTier, 1, "");
        emit TierUpgraded(msg.sender, fromTier, toTier);
    }

    ////////////////////////////
    //  Owner Only Functions  //
    ////////////////////////////

    /// @notice Mints tiered NFTs to specified addresses
    function mintTierNFT(address to, uint256 tier) external onlyOwner {
        require(tier >= 2 && tier <= 4, "Invalid tier");
        require(!_tierMintLocks[tier], "Tier already minted");
        
        _tierMintLocks[tier] = true;
        _mint(to, tier, 1, "");
        emit TierNFTMinted(to, tier);
    }

    /// @notice Sets unlock time for tier transfers
    function setUnlockTime(uint256 tier, uint256 timestamp) external onlyOwner {
        _tokenMetadata[tier].unlockTime = timestamp;
        emit MetadataUpdated(tier);
    }

    ////////////////////////////
    //  Metadata Management  //
    ////////////////////////////

    /// @notice Returns complete metadata for token ID
    function getMetadata(uint256 tokenId) public view returns (NFTMetadata memory) {
        return _tokenMetadata[tokenId];
    }

    /// @notice Updates metadata for specific token ID
    function updateMetadata(
        uint256 tokenId,
        string memory name,
        string memory description,
        string memory image,
        string memory rarity
    ) external onlyOwner {
        _tokenMetadata[tokenId] = NFTMetadata(
            name,
            description,
            image,
            rarity,
            _tokenMetadata[tokenId].unlockTime
        );
        emit MetadataUpdated(tokenId);
    }

    ////////////////////////////
    //  Security & Overrides  //
    ////////////////////////////

    /// @dev Enforces transfer time locks
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override {
        super._update(from, to, ids, values);

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 tokenId = ids[i];
            
            if (tokenId == ENTRY_PASS && from != address(0)) {
                revert("EntryPass: Soulbound token");
            }
            
            if (block.timestamp < _tokenMetadata[tokenId].unlockTime) {
                revert("Token transfer locked");
            }
        }
    }

    ////////////////////////////
    //  Internal Functions    //
    ////////////////////////////

    /// @dev Initializes default metadata
    function _initializeMetadata() internal {
        _setTierMetadata(TIER1_NFT, "Silver Tier", "Basic access tier", "ipfs://Qm...1", "Common");
        _setTierMetadata(TIER2_NFT, "Gold Tier", "Premium access tier", "ipfs://Qm...2", "Rare");
        _setTierMetadata(TIER3_NFT, "Platinum Tier", "VIP access tier", "ipfs://Qm...3", "Legendary");
    }

    /// @dev Validates tier upgrade paths
    function _validUpgradePath(uint256 from, uint256 to) internal pure returns (bool) {
        return (from == TIER1_NFT && to == TIER2_NFT) ||
               (from == TIER2_NFT && to == TIER3_NFT);
    }

    /// @dev Sets metadata for tiers
    function _setTierMetadata(
        uint256 tier,
        string memory name,
        string memory description,
        string memory image,
        string memory rarity
    ) internal {
        _tokenMetadata[tier] = NFTMetadata(
            name,
            description,
            image,
            rarity,
            block.timestamp + 30 days // Default 30-day lock
        );
    }
}