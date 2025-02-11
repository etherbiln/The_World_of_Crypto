// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "./nft/Worlds.sol";
import "./token/WoC.sol";
import "./WorldOfCrypto.sol";
import "./utils/RewardCalculator.sol";

contract GameMaster {
    address public admin;

    WorldOfCrypto public worldOfCyrpto;
    WoC public woC;
    Worlds public worlds;
    RewardCalculator public rewardCalculator;

    constructor(address _nftAddress, address _tokenAddress, address _worldOfCyrpto,address _rewardCalculator) {
        admin = msg.sender;
        worlds = Worlds(_nftAddress);
        woC = WoC(_tokenAddress);
        worldOfCyrpto = WorldOfCrypto(_worldOfCyrpto);
        rewardCalculator = RewardCalculator(_rewardCalculator);
    }

    function updateNFTAddress(address _nftAddress) public onlyAdmin {
        worlds = Worlds(_nftAddress);
    }
    
    function updateCalculatorAddress(address _rewardCalculator) public onlyAdmin {
        rewardCalculator = RewardCalculator(_rewardCalculator);
    }

    function updateTokenAddress(address _tokenAddress) public onlyAdmin {
        woC = WoC(_tokenAddress);
    }

    function updateWorldOfCyrptoAddress(address _worldOfCyrpto) public onlyAdmin {
        worldOfCyrpto = WorldOfCrypto(_worldOfCyrpto);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
}