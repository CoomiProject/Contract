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

contract Crowdsale is Owned, ERC223ReceivingContract {
    bool public isOpen = true;
    uint256 public fundingGoal = 1000;
    uint256 public price = 1 ether;
    CoomiToken public coomiToken;
    uint256 public amountRaised;
    mapping(address => uint256) public donors;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    function tokenFallback(address _from, uint _value, bytes _data) public {
        _from;
        _value;
        _data;
    }

    /**
     * Constructor function
     *
     * Setup the owner
     */
    constructor(CoomiToken _coomiToken) public {
        coomiToken = _coomiToken;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        require(isOpen);
        uint256 amount = msg.value;
        owner.transfer(amount);
        coomiToken.transfer(msg.sender, amount / price);
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
    
    function setFundingGoal(uint256 _fundingGoal) public onlyOwner {
        fundingGoal = _fundingGoal * 1 ether;
    }
    
    function setPrice(uint256 _price) public onlyOwner {
        price = _price * 1 ether;
    }
    
    function setIsOpen(bool _isOpen) public onlyOwner {
        isOpen = _isOpen;
    }
}
