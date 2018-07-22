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

contract CoomiToken {
  function balanceOf(address owner) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
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

contract Crowdsale is Owned {
  using SafeMath for uint256;

  CoomiToken public coomiToken;
  uint256 public exchangeRate;
  mapping(address => uint256) public etherAmounts;
  mapping(address => uint256) public coomiAmounts;
  uint256 public etherAmountsSum;
  uint256 public coomiAmountsSum;

  constructor(CoomiToken _coomiToken, uint256 _exchangeRate) public {
    coomiToken = _coomiToken;
    exchangeRate = _exchangeRate;
  }

  function () payable public {
    require(exchangeRate > 0);
    uint256 etherAmount = msg.value;
    uint256 coomiAmount = etherAmount.mul(exchangeRate);
    owner.transfer(etherAmount);
    etherAmounts[msg.sender] = etherAmounts[msg.sender].add(etherAmount);
    coomiAmounts[msg.sender] = coomiAmounts[msg.sender].add(coomiAmount);
    etherAmountsSum = etherAmountsSum.add(etherAmount);
    coomiAmountsSum = coomiAmountsSum.add(coomiAmount);
  }

  function withdrow() public returns (bool) {
    require(exchangeRate == 0);
    require(coomiAmounts[msg.sender] > 0);
    coomiToken.transfer(msg.sender, coomiAmounts[msg.sender]);
    coomiAmounts[msg.sender] = 0;
    return true;
  }

  function withdrowTo(address _address) public onlyOwner returns (bool) {
    require(coomiAmounts[_address] > 0);
    coomiToken.transfer(_address, coomiAmounts[_address]);
    coomiAmounts[_address] = 0;
    return true;
  }

  function withdrowToOwner(uint256 _value) public onlyOwner returns (bool) {
    coomiToken.transfer(owner, _value);
    return true;
  }

  function setExchangeRate(uint256 _exchangeRate) public onlyOwner {
    exchangeRate = _exchangeRate;
  }
}
