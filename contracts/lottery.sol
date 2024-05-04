// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Lottery{
    address payable  public manager;
    address payable[] public players;
    uint public timenow;
    uint public endsAfter;
    uint public prizePool = 0;
    uint public ticketPrice;

    event LotteryEntered(address indexed player);

    constructor(uint _endsAfter, uint _ticketPrice) payable  {
        manager = payable(msg.sender);
        endsAfter = _endsAfter;
        timenow = block.timestamp;
        ticketPrice = _ticketPrice;
    }

    fallback() external payable {
        pickWinner();
    }
    receive() external payable {
        pickWinner();
    }

    modifier onlyOwner(){
        require(msg.sender == manager);
        _;
    }

    function enter() public payable {
        require(msg.value >= ticketPrice, "Incorrect ammount");
        players.push(payable(msg.sender));
        prizePool += msg.value;
        emit LotteryEntered(msg.sender);
    }

    function random() private view returns (uint){
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number)));
    }

    function pickWinner() public onlyOwner {
        require(players.length>0, "Not enough players");
        require(block.timestamp - timenow >=endsAfter, "Lottery is still running");
        uint256 winnerIndex = random() % players.length;
        address payable winner = players[winnerIndex];
        winner.transfer(prizePool);
        players = new address payable[](0);
        timenow = block.timestamp;
        prizePool = 0;
    }
}
