// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

// NFT tier management contract
import "../nft/TieredWorlds.sol";
// In-game ERC20 token contract
import "../token/WoC.sol";
// Main game logic contract
import "../WorldOfCrypto.sol";
// Reward calculation algorithms
import "../utils/RewardCalculator.sol";
// Security and exploit prevention mechanisms
import "../utils/AntiExploit.sol";
// Country registry system
import "../CountryRegistry.sol";

/**
 * @title GameMaster - Central Management Contract for Game Ecosystem
 * @dev Central management contract coordinating all game components.
 *      Updates critical parameters with admin privileges and manages systems.
 *      
 *      Features:
 *      - Address management for all subsystems
 *      - Admin privilege control
 *      - Security measures and exploit protection
 *      - Detailed event logging
 *      
 *      Security:
 *      - onlyAdmin modifier on all critical functions
 *      - Zero-address checks
 *      - Gas optimization with custom errors
 */
contract GameMaster {
    /// @dev System administrator address (Recommended to use multi-sig wallet)
    address public admin;

    // Token contracts
    /// @notice NFT tier management contract
    TieredWorlds public tieredWorlds;
    /// @notice In-game ERC20 token contract
    WoC public woC;

    // Subsystems
    /// @notice Anomaly detection and prevention system
    AntiExploit public antiExploit;
    /// @notice Dynamic reward calculation algorithm
    RewardCalculator public rewardCalculator;
    /// @notice Main game logic contract
    WorldOfCrypto public worldOfCrypto;
    /// @notice Country registry contract
    CountryRegistry public countryRegistry;

    // Custom Errors (For gas optimization and clearer error handling)
    error OnlyAdmin();
    error NewAdminIsZeroAddress();
    error ContractUpdateFailed();
    error InvalidAddress();

    // Events (For transparency and traceability)
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);
    event TieredWorldsUpdated(address indexed newAddress);
    event WoCUpdated(address indexed newAddress);
    event AntiExploitUpdated(address indexed newAddress);
    event RewardCalculatorUpdated(address indexed newAddress);
    event WorldOfCryptoUpdated(address indexed newAddress);
    event CountryRegistryUpdated(address indexed newAddress);

    /**
     * @dev Contract initialization - Initial addresses for all system components
     * @param _tieredWorlds TieredWorlds NFT contract address
     * @param _woC WoC ERC20 token contract address
     * @param _rewardCalculator Reward calculation module address
     * @param _antiExploit Security module address
     * @param _worldOfCrypto Main game contract address
     * @param _countryRegistry Country registry contract address 
     * 
     * @notice Zero-address checks required for all addresses
     */
    constructor(
        address _tieredWorlds,
        address _woC,
        address _rewardCalculator,
        address _antiExploit,
        address _worldOfCrypto,
        address _countryRegistry // <-- Yeni parametre
    ) {
        // Initial admin assignment
        admin = msg.sender;
        
        // Contract address assignments
        tieredWorlds = TieredWorlds(_tieredWorlds);
        woC = WoC(_woC);
        rewardCalculator = RewardCalculator(_rewardCalculator);
        antiExploit = AntiExploit(_antiExploit);
        worldOfCrypto = WorldOfCrypto(_worldOfCrypto);
        countryRegistry = CountryRegistry(_countryRegistry); 

        // Initial address validation
        if (
            _tieredWorlds == address(0) ||
            _woC == address(0) ||
            _rewardCalculator == address(0) ||
            _antiExploit == address(0) ||
            _worldOfCrypto == address(0) ||
            _countryRegistry == address(0)
        ) revert InvalidAddress();
    }

    /**
     * @dev Admin transfer function
     * @param newAdmin New admin address
     * 
     * - Callable only by current admin
     * - newAdmin cannot be zero-address
     * - Multi-sig wallet recommended
     * - Emits AdminTransferred event on success
     */
    function transferAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert NewAdminIsZeroAddress();
        emit AdminTransferred(admin, newAdmin);
        admin = newAdmin;
    }

    // ========================= MODIFIERS =========================
    /// @dev Restricts access to admin address only
    modifier onlyAdmin() {
        if (msg.sender != admin) revert OnlyAdmin();
        _;
    }

    // ===================== CONTRACT UPDATERS =====================
    // All contract update functions follow same pattern:
    // 1. onlyAdmin check
    // 2. Zero-address check
    // 3. Contract assignment
    // 4. Relevant event emission

    /**
     * @dev Updates NFT contract address
     * @param _tieredWorlds New TieredWorlds contract address
     */
    function updateNFTAddress(address _tieredWorlds) external onlyAdmin {
        if (_tieredWorlds == address(0)) revert ContractUpdateFailed();
        tieredWorlds = TieredWorlds(_tieredWorlds);
        emit TieredWorldsUpdated(_tieredWorlds);
    }

    /**
     * @dev Updates ERC20 token contract address
     * @param _tokenAddress New WoC token contract address
     */
    function updateTokenAddress(address _tokenAddress) external onlyAdmin {
        if (_tokenAddress == address(0)) revert ContractUpdateFailed();
        woC = WoC(_tokenAddress);
        emit WoCUpdated(_tokenAddress);
    }

    /**
     * @dev Updates Anti-Exploit module address
     * @param _antiExploit New AntiExploit contract address
     */
    function updateAntiExAddress(address _antiExploit) external onlyAdmin {
        if (_antiExploit == address(0)) revert ContractUpdateFailed();
        antiExploit = AntiExploit(_antiExploit);
        emit AntiExploitUpdated(_antiExploit);
    }

    /**
     * @dev Updates reward calculation module
     * @param _rewardCalculator New RewardCalculator contract address
     */
    function updateCalculatorAddress(address _rewardCalculator) external onlyAdmin {
        if (_rewardCalculator == address(0)) revert ContractUpdateFailed();
        rewardCalculator = RewardCalculator(_rewardCalculator);
        emit RewardCalculatorUpdated(_rewardCalculator);
    }
    
    /**
     * @dev Updates country registry contract address
     * @param _countryRegistry New CountryRegistry contract address
     */
    function updateCountryRegistry(address _countryRegistry) external onlyAdmin {
        if (_countryRegistry == address(0)) revert ContractUpdateFailed();
        countryRegistry = CountryRegistry(_countryRegistry);
        emit CountryRegistryUpdated(_countryRegistry);
    }

    /**
     * @dev Updates main game contract address
     * @param _worldOfCrypto New WorldOfCrypto contract address
     */
    function updateWorldOfCryptoAddress(address _worldOfCrypto) external onlyAdmin {
        if (_worldOfCrypto == address(0)) revert ContractUpdateFailed();
        worldOfCrypto = WorldOfCrypto(_worldOfCrypto);
        emit WorldOfCryptoUpdated(_worldOfCrypto);
    }
}