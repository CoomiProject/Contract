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
    uint256 public price = 1;
    CoomiToken public coomiToken;
    uint256 public amountRaised;
    mapping(address => uint256) public donors;

    event FundTransfer(address backer, uint256 amount, bool isContribution);

    function tokenFallback(address _from, uint256 _value) public {
        _from;
        _value;
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
    
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }
    
    function setIsOpen(bool _isOpen) public onlyOwner {
        isOpen = _isOpen;
    }
}
