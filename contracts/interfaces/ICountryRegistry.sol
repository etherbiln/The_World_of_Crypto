// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

interface ICountryRegistry {
    // ███ Structs █████████████████████████████████████████████████████████████
    struct Country {
        uint256 id;
        string name;
        uint256 visitCost;
        bool treasure;
        bool package;
    }

    // ███ Admin Functions █████████████████████████████████████████████████████
    function addCountry(
        uint256 id,
        string memory name,
        uint256 visitCost
    ) external;

    function resetAll() external;

    // ███ Player Interactions █████████████████████████████████████████████████
    function recordVisit(
        address player,
        uint256 countryId
    ) external returns (bool);

    // ███ View Functions ██████████████████████████████████████████████████████
    function getPlayerVisits(
        address player
    ) external view returns (uint256[] memory);

    function getCountry(
        uint256 countryId
    ) external view returns (Country memory);

    function getAllCountries() external view returns (Country[] memory);

    function getTotalVisitCost(
        address player
    ) external view returns (uint256 totalCost);

    // ███ State Accessors █████████████████████████████████████████████████████
    function countryCount() external view returns (uint256);
    function players(uint256 index) external view returns (address);
    function countries(uint256 index) external view returns (
        uint256 id,
        string memory name,
        uint256 visitCost,
        bool treasure,
        bool package
    );
}