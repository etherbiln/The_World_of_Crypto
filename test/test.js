const { expect } = require("chai");
const {ethers} = require("hardhat");

describe("MyContract", function () {
    let MyContract, myContract, owner;

    before(async function () {
        const [signer] = await ethers.getSigners(); 
        owner = signer;

        MyContract = await ethers.getContractFactory("AntiExploit");
        console.log("its Okeu!");
    });

    after(function () {
        console.log("Tüm testler tamamlandı!");
    });
});
