// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

interface IRewardCalculator {
    // Events
    event GameMasterUpdated(address indexed newGameMaster);
    event RefundCalculated(
        address indexed player,
        uint256 totalCost,
        uint256 refundAmount
    );

    // Public State Variables
    function gameMaster() external view returns (address);

    // External Functions
    function calculateRefund(address player) external returns (uint256 refundAmount);
}