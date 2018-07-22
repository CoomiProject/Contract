pragma solidity ^0.4.24;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

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

contract CoomiToken {
  function transferFrom(address from, address to, uint256 value) public returns (bool);
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
    coomiToken.transferFrom(owner, msg.sender, coomiAmount);
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
