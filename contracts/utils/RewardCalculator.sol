// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "../interfaces/IMaster/IGameMaster.sol";
import "../interfaces/ICountryRegistry.sol";

/**
 * @title Reward Calculation Engine
 * @dev Central calculation logic for game economy
 * @notice System managed and audited by the GameMaster contract
 */
contract RewardCalculator {
    // Administrator contract reference
    IGameMaster public immutable gameMaster;
    
    /**
     * @dev Modifier for GameMaster exclusive access
     */
    modifier onlyGameMaster() {
        require(
            msg.sender == address(gameMaster),
            "GameMaster Authorization Required"
        );
        _;
    }

    /**
     * @dev Emitted when GameMaster contract is updated
     */
    event GameMasterUpdated(address indexed newGameMaster);

    /**
     * @dev Emitted on refund calculation
     */
    event RefundCalculated(
        address indexed player,
        uint256 totalCost,
        uint256 refundAmount
    );

    /**
     * @dev Initializes with GameMaster contract
     * @param _gameMaster Address of GameMaster contract
     */
    constructor(address _gameMaster) {
        require(_gameMaster != address(0), "Invalid GM Address");
        require(_isContract(_gameMaster), "GM Must Be Contract");
        
        gameMaster = IGameMaster(_gameMaster);
        emit GameMasterUpdated(_gameMaster);
    }

    /**
     * @dev Calculates early exit penalty refund (GameMaster only)
     * @param player Player address
     * @return refundAmount Calculated refund amount
     */
    function calculateRefund(
        address player
    ) external onlyGameMaster returns (uint256 refundAmount) {
        require(player != address(0), "Invalid player");
    
        // Explicit type conversion added here
        ICountryRegistry countryRegistry = ICountryRegistry(address(gameMaster.countryRegistry()));
    
        uint256 totalVisitCost = countryRegistry.getTotalVisitCost(player);
        refundAmount = _calculatePercentage(totalVisitCost, 20);
    
        emit RefundCalculated(player, totalVisitCost, refundAmount);
    }

    /**
     * @dev Internal percentage calculation (Safe version)
     */
    function _calculatePercentage(
        uint256 amount,
        uint256 percentage
    ) internal pure returns (uint256) {
        require(percentage <= 100, "Invalid percentage");
        return (amount * percentage) / 100;
    }

    /**
     * @dev Contract address verification
     */
    function _isContract(address addr) internal view returns (bool) {
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        bytes32 codeHash;
        assembly {
            codeHash := extcodehash(addr)
        }
        return codeHash != accountHash && codeHash != 0x0;
    }
}