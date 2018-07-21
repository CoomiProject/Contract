pragma solidity ^0.4.24;


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
    uint256 public price = 1;
    CoomiToken public coomiToken;
    uint256 public amountRaised;
    mapping(address => uint256) public donors;

    event GoalReached(address recipient, uint256 totalAmountRaised);
    event FundTransfer(address backer, uint256 amount, bool isContribution);

    function tokenFallback(address _from, uint256 _value, bytes _data) public {
        _from;
        _value;
        _data;
    }

    constructor(CoomiToken _coomiToken) public {
        coomiToken = _coomiToken;
    }

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
        fundingGoal = _fundingGoal;
    }
    
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }
    
    function setIsOpen(bool _isOpen) public onlyOwner {
        isOpen = _isOpen;
    }
}
