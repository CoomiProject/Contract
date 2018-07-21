pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract ERC20Interface {
  uint256 internal totalSupply;
  mapping(address => uint256) internal balances;
  mapping(address => mapping(address => uint256)) internal allowed;

  function totalSupply() public view returns (uint256);
  function balanceOf(address owner) public view returns (uint256);
  function allowance(address owner, address spender) public view returns (uint256);
  function approve(address spender, uint256 value) public returns (bool);
  function transfer(address to, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function burn(uint256 value) public;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Burn(address indexed burner, uint256 value);
}

contract ERC20Token is ERC20Interface {
  using SafeMath for uint256;

  function totalSupply() public view returns (uint256) {
    return totalSupply;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(_from, _to, _value);
    return true;
  }

  function burn(uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);

    emit Burn(msg.sender, _value);
    return true;
  }
}

contract CoomiToken is ERC20Token {
  string internal constant name = 'Coomi';
  string internal constant symbol = 'COOMI';
  uint8 internal constant decimals = 18;

  function name() public view returns (string) {
    return name;
  }

  function symbol() public view returns (string) {
    return symbol;
  }

  function decimals() public view returns (uint8) {
    return decimals;
  }

  constructor(uint256 _totalSupply) public {
    totalSupply = _totalSupply * 10 ** decimals;
    balances[msg.sender] = totalSupply;
  }
}
