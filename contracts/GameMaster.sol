// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "./PlayerNFT.sol";
import "./WoC.sol";
import "./WorldOfCyrpto.sol";
import "./RewardCalculator.sol";

contract GameMaster {
    address public admin;

    WorldOfCyrpto public worldOfCyrpto;
    PlayerNFT public playerNFT;
    WoC public woC;
    RewardCalculator public rewardCalculator;

    constructor(address _nftAddress, address _tokenAddress, address _worldOfCyrpto,address _rewardCalculator) {
        admin = msg.sender;
        playerNFT = PlayerNFT(_nftAddress);
        woC = WoC(_tokenAddress);
        worldOfCyrpto = WorldOfCyrpto(_worldOfCyrpto);
        rewardCalculator = RewardCalculator(_rewardCalculator);
    }

    function updateNFTAddress(address _nftAddress) public onlyAdmin {
        playerNFT = PlayerNFT(_nftAddress);
    }
    
    function updateCalculatorAddress(address _rewardCalculator) public onlyAdmin {
        rewardCalculator = RewardCalculator(_rewardCalculator);
    }

    function updateTokenAddress(address _tokenAddress) public onlyAdmin {
        woC = WoC(_tokenAddress);
    }

    function updateWorldOfCyrptoAddress(address _worldOfCyrpto) public onlyAdmin {
        worldOfCyrpto = WorldOfCyrpto(_worldOfCyrpto);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
}