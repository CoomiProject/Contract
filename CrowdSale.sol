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
  uint256 public withdrowRateMolecular;
  uint256 public withdrowRateDenominator;
  uint256 public etherAmountsSum;
  uint256 public coomiAmountsSum;
  mapping(address => uint256) public etherAmounts;
  mapping(address => uint256) public coomiAmounts;
  mapping(address => uint256) public withdrowAmounts;

  constructor(CoomiToken _coomiToken) public {
    coomiToken = _coomiToken;
    exchangeRate = 0;
    withdrowRateMolecular = 0;
    withdrowRateDenominator = 0;
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
    require(withdrowRateMolecular > 0);
    require(withdrowRateDenominator >= withdrowRateMolecular);
    uint256 withdrowAmount = coomiAmounts[msg.sender].mul(withdrowRateMolecular)
                                                     .div(withdrowRateDenominator)
                                                     .sub(withdrowAmounts[msg.sender]);
    require(withdrowAmount > 0);
    coomiToken.transferFrom(owner, msg.sender, withdrowAmount);
    withdrowAmounts[msg.sender] = withdrowAmounts[msg.sender].add(withdrowAmount);
  }

  function withdrowTo(address _to) public onlyOwner {
    require(withdrowRateMolecular > 0);
    require(withdrowRateDenominator >= withdrowRateMolecular);
    uint256 withdrowAmount = coomiAmounts[_to].mul(withdrowRateMolecular)
                                              .div(withdrowRateDenominator)
                                              .sub(withdrowAmounts[_to]);
    require(withdrowAmount > 0);
    coomiToken.transferFrom(owner, _to, withdrowAmount);
    withdrowAmounts[_to] = withdrowAmounts[_to].add(withdrowAmount);
  }

  function setExchangeRate(uint256 _exchangeRate) public onlyOwner {
    exchangeRate = _exchangeRate;
  }

  function setWithdrowRate(uint256 _withdrowRateMolecular, uint256 _withdrowRateDenominator) public onlyOwner {
    require(_withdrowRateDenominator >= _withdrowRateMolecular);
    withdrowRateMolecular = _withdrowRateMolecular;
    withdrowRateDenominator = _withdrowRateDenominator;
  }
}
