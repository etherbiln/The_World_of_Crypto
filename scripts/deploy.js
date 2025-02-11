const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy WoC Token
    const WoC = await ethers.getContractFactory("WoC");
    const woC = await WoC.deploy();
    await woC.waitForDeployment();
    console.log("WoC Token deployed to:", await woC.getAddress());

    // Deploy PlayerNFT
    const PlayerNFT = await ethers.getContractFactory("Worlds");
    const playerNFT = await PlayerNFT.deploy();
    await playerNFT.waitForDeployment();
    console.log("Worlds deployed to:", await playerNFT.getAddress());

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

    // Deploy RewardCalculator
    const RewardCalculator = await ethers.getContractFactory("RewardCalculator");
    const rewardCalculator = await RewardCalculator.deploy(await countryRegistry.getAddress());
    await rewardCalculator.waitForDeployment();
    console.log("RewardCalculator deployed to:", await rewardCalculator.getAddress());

    // Deploy Randomness
    const Randomness = await ethers.getContractFactory("Randomness");
    const randomness = await Randomness.deploy(500);
    await randomness.waitForDeployment();
    console.log("Randomness deployed to:", await randomness.getAddress());

    // Deploy WorldOfCrypto
    const WorldOfCrypto = await ethers.getContractFactory("WorldOfCrypto");
    const worldOfCrypto = await WorldOfCrypto.deploy(
        await rewardCalculator.getAddress(),
        await countryRegistry.getAddress(),
        await playerNFT.getAddress(),
        await woC.getAddress(),
        await randomness.getAddress(),
        await antiExploit.getAddress()
    );
    await worldOfCrypto.waitForDeployment();
    console.log("WorldOfCrypto deployed to:", await worldOfCrypto.getAddress());

    // Deploy GameMaster
    const GameMaster = await ethers.getContractFactory("GameMaster");
    const gameMaster = await GameMaster.deploy(
        await playerNFT.getAddress(),
        await woC.getAddress(),
        await worldOfCrypto.getAddress(),
        await countryRegistry.getAddress()
    );
    await gameMaster.waitForDeployment();
    console.log("GameMaster deployed to:", await gameMaster.getAddress());

    // Execute GameMaster setup functions
    await gameMaster.updateNFTAddress(await playerNFT.getAddress());
    console.log("GameMaster NFT Address updated");

    await gameMaster.updateCalculatorAddress(await rewardCalculator.getAddress());
    console.log("GameMaster Calculator Address updated");

    await gameMaster.updateTokenAddress(await woC.getAddress());
    console.log("GameMaster Token Address updated");

    await gameMaster.updateWorldOfCyrptoAddress(await worldOfCrypto.getAddress());
    console.log("GameMaster WorldOfCyrpto Address updated");

    console.log("All contracts deployed and configured successfully!");
}

main()
    .then(() => console.log("Deployment script executed successfully."))
    .catch((error) => {
        console.error("Deployment failed:", error);
        process.exit(1);
    });
