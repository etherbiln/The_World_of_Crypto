// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

// Import the GameMaster contract which acts as a central hub for various game components.
import "./master/GameMaster.sol";

// Import OpenZeppelin interfaces for interacting with ERC1155 and ERC20 tokens.
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title WorldOfCrypto
 * @dev A decentralized game contract allowing players to join, explore, and leave the game,
 * interacting with various components via the GameMaster contract.
 */
contract WorldOfCrypto {
    /// @notice Reference to the GameMaster contract managing game components.
    GameMaster public gameMaster;
    
    /// @notice Records the last exploration timestamp for each player.
    mapping(address => uint256) public lastExplorationTime;
    
    /// @notice Stores rewards for quests identified by their ID.
    mapping(uint256 => uint256) public questRewards;
    
    /// @notice Array of players currently in the game.
    address[] public playersInGame;
    
    /// @notice Mapping to quickly check if an address is an active player.
    mapping(address => bool) public isInGame;

    /**
     * @notice Constructor sets the GameMaster contract address.
     * @param _gameMasterAddress The address of the deployed GameMaster contract.
     */
    constructor(address _gameMasterAddress) {
        gameMaster = GameMaster(_gameMasterAddress);
    }

    /**
     * @notice Allows a user to join the game.
     * @dev The user must have a valid address, not already be in the game, and own at least one Treasure NFT.
     * @return success A boolean indicating the successful join.
     */
    function joinGame() public returns(bool) {
        require(msg.sender != address(0), "Invalid player address");        
        require(!isInGame[msg.sender], "You are already in the game.");
        // Ensure the player holds at least one Treasure NFT (token ID 1) from the TieredWorlds contract.
        require(
            IERC1155(gameMaster.tieredWorlds()).balanceOf(msg.sender, 1) > 0, 
            "You must own at least one Treasure NFT to join the game."
        );

        // Regardless of whether the playersInGame array is empty or not, add the new player.
        playersInGame.push(msg.sender);
        isInGame[msg.sender] = true;
        return true;
    }

    /**
     * @notice Starts the game; restricted to the first player.
     * @dev Uses the onlyFirst modifier to ensure only the first player can trigger this.
     * Additionally, it verifies via the AntiExploit contract that exploration is allowed.
     */
    function startGame() public onlyFirst {
        require(
            gameMaster.antiExploit().canExplore(msg.sender), 
            "Game already started"
        );
        
        // Add the caller to the players list and mark as active.
        playersInGame.push(msg.sender);
        isInGame[msg.sender] = true;
    }

    /**
     * @notice Ends the game by resetting all country states and clearing the players list.
     * @dev Iterates over the playersInGame array to remove all players.
     */
    function finishGame() external {
        // Reset the state of all countries via the CountryRegistry contract.
        CountryRegistry(gameMaster.countryRegistry()).resetAll();
        uint256 playersLength = playersInGame.length;
        for (uint256 i = 0; i < playersLength; i++) {
            // Pop the last element repeatedly until the array is empty.
            playersInGame.pop();
        }
    }

    /**
     * @notice Allows an active player to leave the game.
     * @dev Removes the player from the players list and refunds tokens based on the RewardCalculator.
     */
    function leaveGame() external onlyPlayer {
        // Find and remove the player from the playersInGame array.
        for (uint256 i = 0; i < playersInGame.length; i++) {
            if (playersInGame[i] == msg.sender) {
                // Swap with the last element and then pop to remove the player efficiently.
                playersInGame[i] = playersInGame[playersInGame.length - 1];
                playersInGame.pop();
                break;
            }
        }
        // Mark the player as no longer active.
        isInGame[msg.sender] = false;
        
        // Calculate the refund amount using the RewardCalculator contract.
        uint256 refund = RewardCalculator(gameMaster.rewardCalculator()).calculateRefund(msg.sender);
        // Transfer the refund tokens from this contract to the player.
        IERC20(gameMaster.woC()).transferFrom(address(this), msg.sender, refund);
    }
    
    /**
     * @notice Allows a player to visit a specified country.
     * @param countryId The unique identifier for the country being visited.
     * @dev Requires that the player has enough tokens to cover the visit cost and complies with AntiExploit rules.
     */
    function visitCountry(uint256 countryId) public onlyPlayer {
        // Retrieve the cost to visit the country from the CountryRegistry.
        uint256 visitCost = CountryRegistry(gameMaster.countryRegistry()).getCountry(countryId).visitCost;
        
        // Check that the player is allowed to explore as per AntiExploit rules.
        require(AntiExploit(gameMaster.antiExploit()).canExplore(msg.sender), "Can not explore for AntiExploit");

        // Verify the player has sufficient token balance to cover the visit cost.
        require(
            IERC20(gameMaster.woC()).balanceOf(msg.sender) >= visitCost,
            "Not enough tokens to visit this country"
        );
        
        // Transfer the required tokens from the player to this contract.
        IERC20(gameMaster.woC()).transferFrom(msg.sender, address(this), visitCost);
        
        // Ensure that the AntiExploit check still passes after the token transfer.
        require(
            AntiExploit(gameMaster.antiExploit()).canExplore(msg.sender), 
            "Too many explorations in a short time"
        );
        
        // Record the current timestamp as the last exploration time.
        lastExplorationTime[msg.sender] = block.timestamp;
        // Log the visit to the specified country via the CountryRegistry.
        CountryRegistry(gameMaster.countryRegistry()).recordVisit(msg.sender, countryId);
    }

    /**
     * @notice Checks if an address is currently an active player.
     * @param player The address to be checked.
     * @return True if the address is active in the game, otherwise false.
     */
    function isPlayer(address player) public view returns (bool) {
        return isInGame[player];
    }

    /**
     * @notice Retrieves the list of all players currently in the game.
     * @return An array of player addresses.
     */
    function getPlayers() public view returns (address[] memory) {
        return playersInGame;
    }

    /**
     * @dev Modifier to restrict function access to only active players.
     */
    modifier onlyPlayer() {
        require(isInGame[msg.sender], "Only active players can call this");
        _;
    }

    /**
     * @dev Modifier to restrict certain functions to the first player in the game.
     * The first player is identified by being at index 0 in the playersInGame array.
     */
    modifier onlyFirst() {
        require(
            playersInGame.length == 0 || playersInGame[0] == msg.sender, 
            "Only first player can call"
        );
        _;
    }

    /**
     * @dev Modifier to ensure that certain actions can only be performed while the game is active.
     */
    modifier onlyDuringGame() {
        require(playersInGame.length > 0, "Game not active");
        _;
    }
}
