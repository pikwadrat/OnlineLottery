//SPDX-License-Identifier: MIT

pragma solidity ^0.5;

contract Betting {
    address payable owner;
    uint minWager = 1;
    uint totalWager = 0;
    uint numberOfWagers = 0;
    uint constant MAX_NUMBER_OF_WAGERS = 2;
    uint winningNumber = 999;
    uint constant MAX_WINNING_NUMBER = 3;
    address payable [] playerAddresses;
    mapping (address => bool) playerAddressesMapping;
    struct Player {
        uint amountWagered;
        uint numberWagered;
    }
    mapping(address => Player) playerDetails;
    
    // the constructor for the contract
    constructor(uint _minWager) public {
        owner = msg.sender;
        if (_minWager >0) minWager = _minWager;
    }
    
    function bet(uint number) public payable {
        // you check using the mapping for performance reasons
        require(playerAddressesMapping[msg.sender] == false);
        // check the range of numbers allowed
        require(number >=1 && number <= MAX_WINNING_NUMBER);
        // note that msg.value is in wei; need to convert to
        // ether
        require( (msg.value / (1 ether)) >= minWager);
        // record the number and amount wagered by the player
        playerDetails[msg.sender].amountWagered = msg.value;
        playerDetails[msg.sender].numberWagered = number;
        // add the player address to the array of addresses as
        // well as mapping
        playerAddresses.push(msg.sender);
        playerAddressesMapping[msg.sender] = true;
        numberOfWagers++;
        totalWager += msg.value;
        if (numberOfWagers >= MAX_NUMBER_OF_WAGERS) {
            announceWinners();
        }
    }
    
        function announceWinners() private {
        winningNumber =
          uint(keccak256(abi.encodePacked(block.timestamp))) %
          MAX_WINNING_NUMBER + 1;
        address payable[MAX_NUMBER_OF_WAGERS] memory winners;
        uint winnerCount = 0;
        uint totalWinningWager = 0;
        // find out the winners
        for (uint i=0; i < playerAddresses.length; i++) {
            // get the address of each player
            address payable playerAddress =
                playerAddresses[i];
            // if the player betted number is the winning
            // number
            if (playerDetails[playerAddress].numberWagered ==
                winningNumber) {
                // save the player address into the winners
                // array
                winners[winnerCount] = playerAddress;
                // sum up the total wagered amount for the
                // winning numbers
                totalWinningWager +=
                  playerDetails[playerAddress].amountWagered;
                winnerCount++;
            }
        }
        // make payments to each winning player
        for (uint j=0; j<winnerCount; j++) {
            winners[j].transfer(
                (playerDetails[winners[j]].amountWagered /
                 totalWinningWager) * totalWager);
        }
    }
    
        function getWinningNumber() view public returns (uint) {
        return winningNumber;
    }
    
        function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
    
    
}