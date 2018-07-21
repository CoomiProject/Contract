pragma solidity ^0.4.24;

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
  using SafeMath for uint256;

  CoomiToken public coomiToken;
  uint256 public exchangeRate;
  bool public isOpen;
  uint256 public amountRaised;
  mapping(address => uint256) public donors;

  constructor(CoomiToken _coomiToken, uint256 _exchangeRate) public {
    coomiToken = _coomiToken;
    exchangeRate = _exchangeRate;
    isOpen = true;
  }

  function () payable public {
    require(isOpen);
    uint256 etherAmount = msg.value;
    uint256 coomiAmount = etherAmount.mul(exchangeRate);
    owner.transfer(etherAmount);
    coomiToken.transfer(msg.sender, coomiAmount);
    donors[msg.sender] = donors[msg.sender].add(etherAmount);
    amountRaised = amountRaised.add(etherAmount);
  }
  
  function setExchangeRate(uint256 _exchangeRate) public onlyOwner {
    exchangeRate = _exchangeRate;
  }
  
  function setIsOpen(bool _isOpen) public onlyOwner {
    isOpen = _isOpen;
  }
}
