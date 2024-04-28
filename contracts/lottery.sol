// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
contract Lottery {
    uint totalPrize;
    uint ticketPrice;
    address public manager;
    address [] public players;

    constructor(uint _ticketPrice) payable  {
        manager = msg.sender;
        totalPrize = msg.value;
        ticketPrice = _ticketPrice;
    }

    event correctpaymentRecieved(uint);

    function enter() public payable {
        require(msg.value == ticketPrice, "Incorrect amount");
        players.push(msg.sender);
    }

    // Random Winner Generation algorithm
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number)));
    }

    // Picking the winner
    function pickWinner() public restricted {
        uint index = random() % players.length;
        payable(players[index]).transfer(totalPrize);
        payable(manager).transfer(address(this).balance);
        players = new address[](0);
    }

    // Restricting  modifier added as sender only calling
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // Return Players Array
    function getPlayers() public view returns (address[] memory){
        return players;
    }

    function getTicketPrice() public view returns (uint){
        return ticketPrice;
    }

    function getTotalPrize() public view returns (uint){
        return totalPrize;
    }
}
