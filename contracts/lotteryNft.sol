
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract Lottery is ERC721{
    address payable  public manager;
    address payable[] public players;
    uint public timenow;
    uint public endsAfterInSeconds;
    uint public prizePool;
    uint public nftId = 0;
    bool public isOpen = false;

    event LotteryEntered(address indexed player);
    event LotteryWinner(address indexed winner);

    string public baseUri;
    string public baseExtension = ".json";

    constructor() ERC721("Name", "Symbol"){
        manager = payable(msg.sender);
    }

    fallback() external payable {
        chooseWinner();
    }
    receive() external payable {
        chooseWinner();
    }

    modifier onlyOwner(){
        require(msg.sender == manager);
        _;
    }

    function enter() public payable {
        require(msg.value >= 1 wei, "Incorrect ammount");
        require(isOpen, "Lottery is not open");
        players.push(payable(msg.sender));
        prizePool += msg.value;
        emit LotteryEntered(msg.sender);
    }

    // Owner Only

    function chooseWinner() public onlyOwner {
        require(isOpen, "Lottery is not open");
        require(players.length>0, "Lottery has no players");
        require(block.timestamp-timenow>=endsAfterInSeconds, "Lottery is still running");
        uint256 winnerIndex = random() % players.length;
        address payable winner = players[winnerIndex];
        mint(msg.sender);
        emit LotteryWinner(winner);
        players = new address payable[](0);
        prizePool = 0;
        isOpen = false;
    }

    function startLottery(uint _endsAfterInSeconds) public onlyOwner{
        require(!isOpen, "Lottery is running");
        timenow = block.timestamp;
        endsAfterInSeconds = _endsAfterInSeconds;
    }

    function random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number)));
    }

    function setPrize(uint _prizePool) public onlyOwner payable {
        prizePool = _prizePool;
    }

    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function mint(address sender) private {
        _safeMint(sender, nftId);
        nftId+=1;
    }
}
