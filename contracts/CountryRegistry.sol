// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

/// @title CountryRegistry Contract
/// @notice Manages a registry of countries and tracks player visits.
/// @dev Only the admin can add countries or reset the registry.
contract CountryRegistry {
    /// @notice Address of the contract administrator.
    address public admin;
    
    /// @notice Struct representing a country.
    struct Country {
        uint256 id;         // Unique identifier for the country.
        string name;        // Human-readable name of the country.
        uint256 visitCost;  // Cost required to visit the country.
        bool treasure;      // Flag indicating if the country contains a treasure.
        bool package;       // Flag indicating if the country has a package available.
    }
    
    /// @notice Dynamic array storing all countries added to the registry.
    Country[] public countries;
    
    /// @notice Total number of countries added.
    uint256 public countryCount;

    /// @notice Array of player addresses that have recorded visits.
    address[] public players;
    
    /// @notice Mapping of player addresses to an array of country IDs they've visited.
    mapping(address => uint256[]) public playerVisits;
    
    /// @notice Constructor sets the deployer as the admin.
    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Adds a new country to the registry.
     * @dev Only the admin can call this function.
     * @param id The unique identifier for the country.
     * @param name The name of the country.
     * @param visitCost The cost required to visit the country.
     */
    function addCountry(uint256 id, string memory name, uint256 visitCost) public onlyAdmin {
        // Add a new country with default false values for treasure and package.
        countries.push(Country(id, name, visitCost, false, false));
        // Increment the counter to reflect the new total number of countries.
        countryCount++;
    }
    
    /**
     * @notice Records a visit by a player to a specified country.
     * @dev If it's the player's first visit, adds the player to the players array.
     * @param player The address of the visiting player.
     * @param countryId The identifier of the country being visited.
     * @return success True if the visit was recorded successfully.
     */
    function recordVisit(address player, uint256 countryId) public returns(bool) {
        // Ensure the country exists in the registry.
        require(countryId < countries.length, "Country does not exist");
        
        // If the player has no recorded visits, register them in the players array.
        if (playerVisits[player].length == 0) {
            players.push(player);
        }
        // Record the visit by adding the countryId to the player's visit history.
        playerVisits[player].push(countryId);
        return true;
    }

    /**
     * @notice Retrieves the list of country IDs visited by a specific player.
     * @param player The address of the player.
     * @return An array of country IDs.
     */
    function getPlayerVisits(address player) public view returns (uint256[] memory) {
        return playerVisits[player];
    }

    /**
     * @notice Fetches the details of a specific country.
     * @param countryId The identifier of the country.
     * @return A Country struct containing the country's details.
     */
    function getCountry(uint256 countryId) public view returns (Country memory) {
        require(countryId < countries.length, "Country does not exist");
        return countries[countryId];
    }
 
    /**
     * @notice Returns all countries in the registry.
     * @return An array of all Country structs.
     */
    function getAllCountries() public view returns (Country[] memory) {
        // Create an in-memory array to store the countries.
        Country[] memory allCountries = new Country[](countryCount);
        for (uint256 i = 0; i < countryCount; i++) {
            // Copy each country from storage to the in-memory array.
            allCountries[i] = countries[i];
        }
        return allCountries;
    }

    /**
     * @notice Calculates the total visit cost incurred by a player.
     * @param player The address of the player.
     * @return totalCost The sum of visit costs for all visited countries.
     */
    function getTotalVisitCost(address player) public view returns (uint256 totalCost) {
        uint256[] memory visits = playerVisits[player];
        // Iterate through all visits to sum up the visit costs.
        for (uint256 i = 0; i < visits.length; i++) {
            uint256 countryId = visits[i];
            require(countryId < countries.length, "Invalid country id in visits");
            totalCost += countries[countryId].visitCost;
        }
        return totalCost;
    }

    /**
     * @notice Resets the registry by clearing all country data and player visit histories.
     * @dev Only the admin can execute this function. This action is irreversible.
     */
    function resetAll() public onlyAdmin {
        // Clear the countries array and reset the country count.
        delete countries;
        countryCount = 0;
        uint256 len = players.length;
        // For each player, delete their recorded visits.
        for (uint256 i = 0; i < len; i++) {
            delete playerVisits[players[i]];
        }
        // Clear the players array.
        delete players;
    }

    /**
     * @dev Modifier that restricts access to functions only callable by the admin.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
}
