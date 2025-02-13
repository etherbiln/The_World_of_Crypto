// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "./master/GameMaster.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WorldOfCrypto {
    GameMaster public gameMaster;
    
    mapping(address => uint256) public lastExplorationTime;
    mapping(uint256 => uint256) public questRewards;
    
    address[] public playersInGame;
    mapping(address => bool) public isInGame;

    constructor(address _gameMasterAddress) {
        gameMaster = GameMaster(_gameMasterAddress);
    }

    function joinGame() public returns(bool) {
        require(msg.sender != address(0), "Invalid player address");        
        require(!isInGame[msg.sender], "You are already in the game.");
        require(
            IERC1155(gameMaster.tieredWorlds()).balanceOf(msg.sender,1) > 0, 
            "You must own at least one Treasure NFT to join the game."
        );

        if (playersInGame.length == 0) {
            playersInGame.push(msg.sender);
            isInGame[msg.sender] = true;
            return true;
        } else {
            playersInGame.push(msg.sender);
            isInGame[msg.sender] = true;
            return true;
        }
    }

    function startGame() public onlyFirst {
        require(
            gameMaster.antiExploit().canExplore(msg.sender), 
            "Game already started"
        );
        
        playersInGame.push(msg.sender);
        isInGame[msg.sender] = true;
    }

    function finishGame() external {
        CountryRegistry(gameMaster.countryRegistry()).resetAll();
        uint256 playersLength = playersInGame.length;
        for (uint256 i = 0; i < playersLength; i++) {
            playersInGame.pop();
        }
    }

    function leaveGame() external onlyPlayer {
        for (uint256 i = 0; i < playersInGame.length; i++) {
            if (playersInGame[i] == msg.sender) {
                playersInGame[i] = playersInGame[playersInGame.length - 1];
                playersInGame.pop();
                break;
            }
        }
        isInGame[msg.sender] = false;
        
        uint256 refund = RewardCalculator(gameMaster.rewardCalculator()).calculateRefund(msg.sender);
        IERC20(gameMaster.woC()).transferFrom(address(this), msg.sender, refund);
    }
    
    function visitCountry(uint256 countryId) public onlyPlayer {
        uint256 visitCost = CountryRegistry(gameMaster.countryRegistry()).getCountry(countryId).visitCost;
        
        require(AntiExploit(gameMaster.antiExploit()).canExplore(msg.sender),"Can not explore for AntiExploit");

        require(
            IERC20(gameMaster.woC()).balanceOf(msg.sender) >= visitCost,
            "Not enough tokens to visit this country"
        );
        
        IERC20(gameMaster.woC()).transferFrom(msg.sender, address(this), visitCost);
        require(
            AntiExploit(gameMaster.antiExploit()).canExplore(msg.sender), 
            "Too many explorations in a short time"
        );
        
        lastExplorationTime[msg.sender] = block.timestamp;
        CountryRegistry(gameMaster.countryRegistry()).recordVisit(msg.sender, countryId);
    }

    function isPlayer(address player) public view returns (bool) {
        return isInGame[player];
    }

    function getPlayers() public view returns (address[] memory) {
        return playersInGame;
    }

    modifier onlyPlayer() {
        require(isInGame[msg.sender], "Only active players can call this");
        _;
    }

    modifier onlyFirst() {
        require(
            playersInGame.length == 0 || playersInGame[0] == msg.sender, 
            "Only first player can call"
        );
        _;
    }

    modifier onlyDuringGame() {
        require(playersInGame.length > 0, "Game not active");
        _;
    }
}