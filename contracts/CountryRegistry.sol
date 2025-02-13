// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

contract CountryRegistry {
    address public admin;
    
    struct Country {
        uint256 id;
        string name;
        uint256 visitCost;
        bool treasure;
        bool package;
    }
    Country[] public countries;
    uint256 public countryCount;

    address[] public players;
    mapping(address => uint256[]) public playerVisits;
    
    constructor() {
        admin = msg.sender;
    }

    function addCountry(uint256 id, string memory name, uint256 visitCost) public onlyAdmin {
        countries.push(Country(id, name, visitCost, false, false));
        countryCount++;
    }
    
    function recordVisit(address player, uint256 countryId) public returns(bool) {
        require(countryId < countries.length, "Country does not exist");
        
        if (playerVisits[player].length == 0) {
            players.push(player);
        }
        playerVisits[player].push(countryId);
        return true;
    }

    function getPlayerVisits(address player) public view returns (uint256[] memory) {
        return playerVisits[player];
    }

    function getCountry(uint256 countryId) public view returns (Country memory) {
        require(countryId < countries.length, "Country does not exist");
        return countries[countryId];
    }
 
    function getAllCountries() public view returns (Country[] memory) {
        Country[] memory allCountries = new Country[](countryCount);
        for (uint256 i = 0; i < countryCount; i++) {
            allCountries[i] = countries[i];
        }
        return allCountries;
    }

    function getTotalVisitCost(address player) public view returns (uint256 totalCost) {
        uint256[] memory visits = playerVisits[player];
        for (uint256 i = 0; i < visits.length; i++) {
            uint256 countryId = visits[i];
            require(countryId < countries.length, "Invalid country id in visits");
            totalCost += countries[countryId].visitCost;
        }
        return totalCost;
    }

    function resetAll() public onlyAdmin {
        delete countries;
        countryCount = 0;
        uint256 len = players.length;
        for (uint256 i = 0; i < len; i++) {
            delete playerVisits[players[i]];
        }
        delete players;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
}