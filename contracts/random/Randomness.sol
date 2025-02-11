// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Randomness is VRFConsumerBase {
    uint256 internal fee;
    bytes32 internal keyHash;
    uint256 public latestRandomNumber; // Her çağrıda güncellenecek
    event RandomNumberRequested(bytes32 requestId);
    event RandomNumberReceived(bytes32 requestId, uint256 randomness);

    // Sepolia Testnet parameters
    address linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 internal defaultKeyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    constructor(uint256 _fee) VRFConsumerBase(vrfCoordinator, linkToken) {
        fee = _fee;
        keyHash = defaultKeyHash;
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        requestId = requestRandomness(keyHash, fee);
        emit RandomNumberRequested(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        latestRandomNumber = randomness; // Her çağrıda güncelleniyor
        emit RandomNumberReceived(requestId, randomness);
    }

    function getLatestRandomNumber() public view returns (uint256) {
        require(latestRandomNumber != 0, "Random number not ready yet");
        return latestRandomNumber;
    }

    function withdrawLink() external {
        require(LINK.transfer(msg.sender, LINK.balanceOf(address(this))), "Transfer failed");
    }
}
