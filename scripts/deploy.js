const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy WoC Token (ERC-20)
    const WoC = await ethers.getContractFactory("WoC");
    const woC = await WoC.deploy();
    await woC.waitForDeployment();
    console.log("WoC Token deployed to:", await woC.getAddress());

    // Deploy TieredWorlds (ERC-1155)
    const TieredWorlds = await ethers.getContractFactory("TieredWorlds");
    const tieredWorlds = await TieredWorlds.deploy("https://r.resimlink.com/92vTm_.webp");
    await tieredWorlds.waitForDeployment();
    console.log("TieredWorlds deployed to:", await tieredWorlds.getAddress());


    
    // Deploy AntiExploit
    const AntiExploit = await ethers.getContractFactory("AntiExploit");
    const antiExploit = await AntiExploit.deploy(deployer);
    await antiExploit.waitForDeployment();
    console.log("AntiExploit deployed to:", await antiExploit.getAddress());


     // Deploy CountryRegistry
     const CountryRegistry = await ethers.getContractFactory("CountryRegistry");
     const countryRegistry = await CountryRegistry.deploy();
     await countryRegistry.waitForDeployment();
     console.log("CountryRegistry deployed to:", await countryRegistry.getAddress());
 

    // Deploy GameMaster
    const GameMaster = await ethers.getContractFactory("GameMaster");
    const gameMaster = await GameMaster.deploy(
        await tieredWorlds.getAddress(), 
        await woC.getAddress(),          
        "0x0000000000000000000000000000000000000001", 
        await antiExploit.getAddress(),
        "0x0000000000000000000000000000000000000002",
        await countryRegistry.getAddress()
    );
    await gameMaster.waitForDeployment();
    console.log("GameMaster deployed to:", await gameMaster.getAddress());


    // Deploy RewardCalculator
    const RewardCalculator = await ethers.getContractFactory("RewardCalculator");
    const rewardCalculator = await RewardCalculator.deploy(await countryRegistry.getAddress());
    await rewardCalculator.waitForDeployment(gameMaster.address);
    console.log("RewardCalculator deployed to:", await rewardCalculator.getAddress());

    
    // Deploy WorldOfCrypto
    const WorldOfCrypto = await ethers.getContractFactory("WorldOfCrypto");
    const worldOfCrypto = await WorldOfCrypto.deploy(await gameMaster.getAddress());
    await worldOfCrypto.waitForDeployment();
    console.log("WorldOfCrypto deployed to:", await worldOfCrypto.getAddress());
    
    
    // Execute GameMaster setup functions

    await gameMaster.updateCalculatorAddress(await rewardCalculator.getAddress());
    console.log("GameMaster Calculator Address updated");

    await gameMaster.updateWorldOfCryptoAddress(await worldOfCrypto.getAddress());
    console.log("GameMaster WorldOfCyrpto Address updated");

    console.log("All contracts deployed and configured successfully!");
}

main()
    .then(() => console.log("Deployment script executed successfully."))
    .catch((error) => {
        console.error("Deployment failed:", error);
        process.exit(1);
    });
