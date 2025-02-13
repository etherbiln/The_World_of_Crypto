SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
 
import "@chainlink/contracts/src/v0.8/vrf/VRFCoordinatorV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract VRFConsumer is VRFConsumerBase, OwnableUpgradeable {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords
    );
    
    error InsufficientFunds(uint256 balance, uint256 paid);
    error RequestNotFound(uint256 requestId);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    VRFCoordinator public VrfCoordinator;
    address vrfCoordinator = 0x9492b270EdA7d4046D6aa5e3F15c24deD2c8BD25;

    constructor() VRFConsumerBase(vrfCoordinator){
        VrfCoordinator = VRFCoordinator(vrfCoordinator);
        initialize();
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    function requestRandomWords(
        uint32 _callbackGasLimit,
        uint32 _numWords
    ) external onlyOwner returns (uint256 requestId) {
        (uint16 requestConfirmations, , bytes32[] memory keyHash) = VrfCoordinator.getRequestConfig();
        requestId = VrfCoordinator.requestRandomWords(keyHash[0], requestConfirmations, _callbackGasLimit, _numWords);

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, _numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) override internal {
        RequestStatus storage request = s_requests[_requestId];

        require(!request.fulfilled, "Fulfilled");
        request.fulfilled = true;
        request.randomWords = _randomWords;

        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getNumberOfRequests() external view returns (uint256) {
        return requestIds.length;
    }

    function getRequestStatus(
        uint256 _requestId
    )
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

}