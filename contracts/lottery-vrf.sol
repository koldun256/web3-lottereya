// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Lottery is VRFConsumerBaseV2{
    address public immutable vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    uint64 public immutable subscriptionId = 11514;
    bytes32 public immutable keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 public immutable callbackGasLimit = 40000;
    uint16 public immutable requestConfirmations = 3;
    uint32 public immutable numWords = 1;

    VRFCoordinatorV2Interface COORDINATOR;

    uint prize;
    address public manager;
    address payable[] public players;
    uint public timenow;
    uint public endsAfter;
    bool public lotteryOpen;
    uint public prizePool = 0;

    event LotteryEntered(address indexed player);
    event LotteryWinner(address indexed winner, uint256 prize);

    constructor(uint _endsAfter) VRFConsumerBaseV2(vrfCoordinator) payable  {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        manager = msg.sender;
        prize = msg.value;
        endsAfter = _endsAfter;
        timenow = block.timestamp;
        lotteryOpen = false;
    }

    fallback() external payable {
        requestRandomWords();
    }
    receive() external payable {
        requestRandomWords();
    }

    modifier onlyOwner(){
        require(msg.sender == manager);
        _;
    }

    function enter() public payable {
        require(msg.value >= 1 wei, "Incorrect ammount");
        players.push(payable(msg.sender));
        prizePool += msg.value;
        emit LotteryEntered(msg.sender);
    }

    function startLottery() public {
        require(!lotteryOpen, "Lottery is already open");
        lotteryOpen = true;
    }

    function fulfillRandomWords(uint256 requestId, uint[] memory randomWords) internal override {
        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        winner.transfer(prizePool * 9 / 10);
        emit LotteryWinner(winner, prize);
        lotteryOpen = false;
        players = new address payable[](0);
        timenow = block.timestamp;
        prizePool = 0;
    }

    function requestRandomWords() public onlyOwner returns(uint requestId){
        require(lotteryOpen, "Lottery is not open");
        require(players.length > 0, "No players in the lottery");
        require(block.timestamp-timenow>=endsAfter, "Lottery is still running");
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }
}
