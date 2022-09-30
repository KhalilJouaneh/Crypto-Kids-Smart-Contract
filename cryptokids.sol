//SPDX-License-Identifer: Unlicensed

pragma solidity ^0.8.7;

contract CryptoKids {
    //owner: Dad

    address owner;

    constructor() {
        owner = msg.sender;
    }
    
    //define kid 

    struct Kid {
        address payable walletAddress;

        string firstName;

        string lastName;

        uint releaseTime;

        uint amount;

        bool canWithdraw;
    }

    //array of type Kid that has the name "kids"
    Kid[] public kids;

    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can add kids");
        _;
    }

    //add kid to contract

    function addKid(address payable walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner {
        kids.push(Kid(
            walletAddress,
            firstName,
            lastName,
            releaseTime,
            amount,
            false
        ));
    }

    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    //deposit funds to contract, specifically to a kids account


    //view means it can changle the value of global variables. It can only interact locally and not on the blockchain.
    //pure is more strict than view.
    function deposit(address walletAddress) payable public {
        addToKidsBalance(walletAddress);
    }
    function addToKidsBalance(address walletAddress) private onlyOwner {
        
        for(uint i = 0; i <kids.length; i++) {
            if (kids[i].walletAddress == walletAddress){
                kids[i].amount += msg.value;
            }
        }
    }

    function getIndex(address walletAddress) view private returns (uint) {
        for (uint i=0; i< kids.length; i++) {
            if (kids[i].walletAddress == walletAddress){
                return i;
            }
        }

        return 9999;
    }

    //kid checks if able to withdraw
    function availableToWithdraw(address walletAddress) public returns (bool) {
        uint i = getIndex(walletAddress);
        require(block.timestamp > kids[i].releaseTime, "you cannot withdraw yet");
        if (block.timestamp > kids[i].releaseTime) {
            kids[i].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    //withdraw money

    function withdraw(address payable walletAddress) payable public {
        uint i = getIndex(walletAddress); //get index of kid
        require(msg.sender == kids[i].walletAddress, "must be the kid to withdraw");
        require(kids[i].canWithdraw == true, "you're not able to withdraw at this time");
        kids[i].walletAddress.transfer(kids[i].amount);
    }

}