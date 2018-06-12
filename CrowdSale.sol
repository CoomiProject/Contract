pragma solidity ^0.4.23;


import "./SafeMath.sol";
import "./CoomiToken.sol";


contract Owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract Crowdsale is Owned {
    bool public isOpen = false;
    uint public fundingGoal;
    uint public price;
    CoomiToken public coomiToken;
    uint public amountRaised;
    mapping(address => uint256) public donors;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    constructor(CoomiToken _tokenReward) public {
        tokenReward = _tokenReward;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        require(isOpen);
        uint amount = msg.value;
        owner.transfer(amount);
        tokenReward.transfer(msg.sender, amount / price);
        donors[msg.sender] += amount;
        amountRaised += amount;
        emit FundTransfer(msg.sender, amount, true);
    }

    function checkGoalReached() public {
        if (amountRaised >= fundingGoal) {
            emit GoalReached(owner, amountRaised);
            isOpen = false;
        }
    }
    
    function setFundingGoal(uint _fundingGoal) public onlyOwner {
        fundingGoal = _fundingGoal * 1 ether;
    }
    
    function setPrice(uint _price) public onlyOwner {
        price = _price * 1 ether;
    }
    
    function setIsOpen(bool _isOpen) public onlyOwner {
        isOpen = _isOpen;
    }
}