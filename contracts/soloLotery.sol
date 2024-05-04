// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract Lottery{
    address payable public manager;
    uint public ticketPrice;
    uint public winPersenrage;
    bool public lotteryOpen = false;


    event LotteryEntered(address indexed player);

    constructor(uint _winPersentage, uint _ticketPrice) {
        manager = payable(msg.sender);
        winPersenrage = _winPersentage;
        ticketPrice = _ticketPrice;
    }

    modifier onlyOwner(){
        require(msg.sender == manager);
        _;
    }

    function startLottery() public onlyOwner{
        lotteryOpen = true;
    }

    function enter() public payable returns (bool){
        require(lotteryOpen, "Lottery is not open");
        require(msg.value == ticketPrice, "Incorrect ammount");
        emit LotteryEntered(msg.sender);
        return determineWin(payable(msg.sender));
    }

    function random() private view returns (uint){
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number)));
    }

    function determineWin(address payable player) private returns (bool isWin){
        require(lotteryOpen, "Lottery is not open");
        isWin = random() % 100 <= winPersenrage;
        if (isWin) {
            player.transfer(address(this).balance);
        } else{
            manager.transfer(address(this).balance);
        }       
   }
}
