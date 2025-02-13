// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

interface IGameMaster {
    // ███ Custom Errors ███████████████████████████████████████████████████████
    error OnlyAdmin();
    error NewAdminIsZeroAddress();
    error ContractUpdateFailed();
    error InvalidAddress();

    // ███ Events █████████████████████████████████████████████████████████████
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);
    event TieredWorldsUpdated(address indexed newAddress);
    event WoCUpdated(address indexed newAddress);
    event AntiExploitUpdated(address indexed newAddress);
    event RewardCalculatorUpdated(address indexed newAddress);
    event WorldOfCryptoUpdated(address indexed newAddress);
    event CountryRegistryUpdated(address indexed newAddress);

    // ███ Administration █████████████████████████████████████████████████████
    function transferAdmin(address newAdmin) external;
    
    // ███ Contract Getters ███████████████████████████████████████████████████
    function admin() external view returns (address);
    function tieredWorlds() external view returns (address);
    function woC() external view returns (address);
    function antiExploit() external view returns (address);
    function rewardCalculator() external view returns (address);
    function worldOfCrypto() external view returns (address);
    function countryRegistry() external view returns (address);

    // ███ Contract Management ████████████████████████████████████████████████
    function updateNFTAddress(address _tieredWorlds) external;
    function updateTokenAddress(address _tokenAddress) external;
    function updateAntiExAddress(address _antiExploit) external;
    function updateCalculatorAddress(address _rewardCalculator) external;
    function updateCountryRegistry(address _countryRegistry) external;
    function updateWorldOfCryptoAddress(address _worldOfCrypto) external;
}