// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "./GameMaster.sol";
import "./Randomness.sol";
import "./RewardCalculator.sol";
import "./CountryRegistry.sol";
import "./AntiExploit.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WorldOfCyrpto {
    GameMaster public gameMaster;
    Randomness public randomness;
    RewardCalculator public rewardCalculator;
    CountryRegistry public countryRegistry;
    AntiExploit public antiExploit;

    IERC721 public treasureNFT;
    IERC20 public woC;

    mapping(address => uint256) public playerEnergy;
    mapping(address => uint256) public lastExplorationTime;

    uint256 public constant ENERGY_COST = 1;
    uint256 public constant ENERGY_RECHARGE_TIME = 3600; // 1 saat

    
    mapping(address => mapping(uint256 => bool)) public completedQuests;
    mapping(uint256 => uint256) public questRewards;

    // Oyuncu verisi
    mapping(address => bool) public isInGame;
    
    address[] public playersInGame;

    constructor(
        address _gameMasterAddress,
        address _randomnessAddress,
        address _rewardCalculatorAddress,
        address _countryRegistryAddress,
        address _antiExploitAddress,
        address _treasureNFTAddress,
        address _woC
    ) {
        gameMaster = GameMaster(_gameMasterAddress);
        randomness = Randomness(_randomnessAddress);
        rewardCalculator = RewardCalculator(_rewardCalculatorAddress);
        countryRegistry = CountryRegistry(_countryRegistryAddress);
        antiExploit = AntiExploit(_antiExploitAddress);
        treasureNFT = IERC721(_treasureNFTAddress);
        woC = IERC20(_woC);
    }

    // Oyuncunun oyuna katılmasını sağlar
    function joinGame() public returns(bool) {
        require(msg.sender != address(0), "Invalid player address");        
        require(!isInGame[msg.sender], "You are already in the game.");
        require(treasureNFT.balanceOf(msg.sender) > 0, "You must own at least one Treasure NFT to join the game.");

        // Eğer oyun başlamadıysa, oyuncuyu ilk katılan olarak ekleyebiliriz
        if (playersInGame.length == 0) {
            // İlk oyuncu oyuna katıldığında, oyunu başlatabilir
            playersInGame.push(msg.sender);
            isInGame[msg.sender] = true;
            return true;
        } else {
            // Diğer oyuncular oyuna katılabilir
            playersInGame.push(msg.sender);
            isInGame[msg.sender] = true;
            return true;
        }
    }

    // Oyun başladığında oyuncu ekleyin
    function startGame() public onlyFirst {
        require(antiExploit.ExplorationTime() == 0, "Game already started");
        playersInGame.push(msg.sender);
        isInGame[msg.sender] = true;
    }

    function finishGame() external { {
        countryRegistry.resetAll();
        uint256 playersLength = playersInGame.length;
        for (uint256 i = 0; i < playersLength; i++) {
                playersInGame.pop();
            }
        }
    }

    // Oyundan çıkma
    function leaveGame() external onlyPlayer {
        // Oyuncuyu oyun listesinden çıkar
        for (uint256 i = 0; i < playersInGame.length; i++) {
            if (playersInGame[i] == msg.sender) {
                playersInGame[i] = playersInGame[playersInGame.length - 1];
                playersInGame.pop();
                break;
            }
        }
        isInGame[msg.sender] = false;
        
        // Payment
        uint256 refund = rewardCalculator.calculateRefund(msg.sender);
        woC.transferFrom(address(this), msg.sender, refund);
    }
    
    // Oyuncu bir ülkeyi ziyaret eder ve keşif yapar
    function visitCountry(uint256 countryId) public onlyPlayer {
        
        uint256 visitCost = countryRegistry.getCountry(countryId).visitCost;
        require(
            woC.balanceOf(msg.sender) >= visitCost,
            "Not enough tokens to visit this country"
        );
        woC.transferFrom(msg.sender, address(this), visitCost);

        require(antiExploit.canExplore(msg.sender), "Too many explorations in a short time");

        lastExplorationTime[msg.sender] = block.timestamp;
        
        countryRegistry.recordVisit(msg.sender, countryId);
    }

    

    // Enerji yenileme
    function rechargeEnergy() public {
        uint256 timeSinceLastExploration = block.timestamp - lastExplorationTime[msg.sender];
        uint256 energyToAdd = timeSinceLastExploration / ENERGY_RECHARGE_TIME;

        if (energyToAdd > 0) {
            playerEnergy[msg.sender] += energyToAdd;
            lastExplorationTime[msg.sender] = block.timestamp;
        }
    }

    // Oyuncunun oyun içerisinde olup olmadığını kontrol et
    function isPlayer(address player) public view returns (bool) {
        return isInGame[player];
    }

    // Aktif oyuncuları getir
    function getPlayers() public view returns (address[] memory) {
        return playersInGame;
    }


    // Oyuncunun aktif olup olmadığını kontrol et
    modifier onlyPlayer() {
        require(isInGame[msg.sender], "Only players in the game can call this function.");
        _;
    }

    // Sadece ilk oyuncunun çağırabileceği fonksiyon
    modifier onlyFirst() {
        require(playersInGame.length == 0 || playersInGame[0] == msg.sender, "Only the first player can call this function.");
        _;
    }

    // Oyun sürecindeyken çalışan fonksiyon
    modifier onlyDuringGame() {
        require(playersInGame.length > 0, "Game has not started yet.");
        _;
    }

}