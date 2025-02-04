// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

contract CountryRegistry {
    
    struct Country {
        uint256 id;
        string name;
        uint256 visitCost;
    }

    Country[] public countries;
    
    mapping(address => uint256[]) public playerVisits;
    
    address public admin;

    // Oyuncuların adreslerini saklayan liste (mapping’i sıfırlamak için)
    address[] public players;

    constructor() {
        admin = msg.sender;
    }

    function addCountry(uint256 id, string memory name, uint256 visitCost) public onlyAdmin {
        countries.push(Country(id, name, visitCost));
    }

    function recordVisit(address player, uint256 countryId) public {
        require(countryId < countries.length, "Country does not exist");
        
        // Eğer oyuncu daha önce hiç ziyaret kaydetmemişse, adresini listeye ekle
        if (playerVisits[player].length == 0) {
            players.push(player);
        }

        playerVisits[player].push(countryId);
    }

    function getPlayerVisits(address player) public view returns (uint256[] memory) {
        return playerVisits[player];
    }

    function getCountry(uint256 countryId) public view returns (Country memory) {
        require(countryId < countries.length, "Country does not exist");
        return countries[countryId];
    }

    function getVisitCount(address player, uint256 countryId) public view returns (uint256 count) {
        uint256[] memory visits = playerVisits[player];
        for (uint256 i = 0; i < visits.length; i++) {
            if (visits[i] == countryId) {
                count++;
            }
        }
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
