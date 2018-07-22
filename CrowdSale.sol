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
  function transferFrom(address from, address to, uint256 value) public returns (bool);
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

  function transferOwnership(address _owner) public onlyOwner {
    require(_owner != address(0));
    owner = _owner;
  }
}

contract Crowdsale is Owned {
  using SafeMath for uint256;

  CoomiToken public coomiToken;
  uint256 public exchangeRate;
  uint256 public withdrowRate0; // Molecular
  uint256 public withdrowRate1; // Denominator
  uint256 public etherAmountsSum;
  uint256 public coomiAmountsSum;
  mapping(address => uint256) public etherAmounts;
  mapping(address => uint256) public coomiAmounts;
  mapping(address => uint256) public withdrowAmounts;

  constructor(CoomiToken _coomiToken) public {
    coomiToken = _coomiToken;
    exchangeRate = 0;
    withdrowRate0 = 0;
    withdrowRate1 = 0;
  }

  function () payable public {
    require(exchangeRate > 0);
    owner.transfer(etherAmount);
    uint256 etherAmount = msg.value;
    uint256 coomiAmount = etherAmount.mul(exchangeRate);
    etherAmounts[msg.sender] = etherAmounts[msg.sender].add(etherAmount);
    coomiAmounts[msg.sender] = coomiAmounts[msg.sender].add(coomiAmount);
    etherAmountsSum = etherAmountsSum.add(etherAmount);
    coomiAmountsSum = coomiAmountsSum.add(coomiAmount);
  }

  function withdrow() public {
    withdrowTo(msg.sender);
  }

  function withdrowByOwner(address _to) public onlyOwner {
    withdrowTo(_to);
  }

  function setExchangeRate(uint256 _exchangeRate) public onlyOwner {
    exchangeRate = _exchangeRate;
  }

  function setWithdrowRate(uint256 _withdrowRate0, uint256 _withdrowRate1) public onlyOwner {
    require(_withdrowRate1 >= _withdrowRate0);
    withdrowRate0 = _withdrowRate0;
    withdrowRate1 = _withdrowRate1;
  }

  function withdrowTo(address to) internal {
    require(withdrowRate0 > 0);
    require(withdrowRate1 >= withdrowRate0);
    uint256 withdrowAmount = coomiAmounts[to].mul(withdrowRate0)
                                             .div(withdrowRate1)
                                             .sub(withdrowAmounts[to]);
    require(withdrowAmount > 0);
    coomiToken.transferFrom(owner, to, withdrowAmount);
    withdrowAmounts[to] = withdrowAmounts[to].add(withdrowAmount);
  }
}
