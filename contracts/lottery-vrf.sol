// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Lottery is VRFConsumerBaseV2 {
    address public immutable vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 public immutable subscriptionId = 11506;
    bytes32 public immutable keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 public immutable callbackGasLimit = 40000;
    uint16 public immutable requestConfirmations = 3;
    uint32 public immutable numWords = 1;

    VRFCoordinatorV2Interface COORDINATOR;
    uint256 public lotteryFee;
    uint256 public lotteryPrize;
    address payable[] public players;
    bool public lotteryOpen;
    uint256 public lastRequestId;

    event LotteryEntered(address indexed player);
    event LotteryWinner(address indexed winner, uint256 prize);

    constructor(uint256 _lotteryFee) VRFConsumerBaseV2(vrfCoordinator) payable {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        lotteryFee = _lotteryFee;
        lotteryPrize = msg.value;
        lotteryOpen = false;
    }

    function enterLottery() public payable {
        require(lotteryOpen, "Lottery is not open");
        require(msg.value >= lotteryFee, "Insufficient lottery fee");
        players.push(payable(msg.sender));
        emit LotteryEntered(msg.sender);
    }

    function startLottery() public {
        require(!lotteryOpen, "Lottery is already open");
        lotteryOpen = true;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        require(requestId == lastRequestId, "Request ID does not match");
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        winner.transfer(lotteryPrize);
        emit LotteryWinner(winner, lotteryPrize);
        lotteryOpen = false;
        players = new address payable[](0);
        lotteryPrize = 0;
    }

    function requestRandomWords() public {
        require(lotteryOpen, "Lottery is not open");
        require(players.length > 0, "No players in the lottery");
        lastRequestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }
}
