// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

interface IWorldOfCrypto {
    // Public State Variables
    function gameMaster() external view returns (address);
    function lastExplorationTime(address) external view returns (uint256);
    function questRewards(uint256) external view returns (uint256);
    function playersInGame(uint256) external view returns (address);
    function isInGame(address) external view returns (bool);

    // Public Functions
    function joinGame() external returns (bool);
    function startGame() external;
    function finishGame() external;
    function leaveGame() external;
    function visitCountry(uint256 countryId) external;
    function isPlayer(address player) external view returns (bool);
    function getPlayers() external view returns (address[] memory);
}