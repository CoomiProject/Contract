pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract ERC223Interface {
  uint256 public totalSupply;
  mapping(address => uint256) internal balances;
  mapping(address => mapping(address => uint256)) internal allowed;

  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function transfer(address to, uint256 value, bytes _data) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function approve(address spender, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function burn(uint256 value) public;
  function burnFrom(address from, uint256 value) public;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Burn(address indexed burner, uint256 value);
}

contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

contract ERC223Token is ERC223Interface {
  using SafeMath for uint256;

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint codeLength;
    bytes memory empty;
    assembly {
        codeLength := extcodesize(_to)
    }

    if (codeLength > 0) {
        ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        receiver.tokenFallback(msg.sender, _value, empty);
    }

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);
    return true;
  }

function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(0));

    uint codeLength;
    assembly {
        codeLength := extcodesize(_to)
    }

    if (codeLength > 0) {
        ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
    }

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(_from, _to, _value);
    return true;
  }

  function burn(uint256 _value) public {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(msg.sender, _value);
    emit Transfer(msg.sender, address(0), _value);
  }

  function burnFrom(address _from, uint256 _value) public {
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    balances[_from] = balances[_from].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(_from, _value);
    emit Transfer(_from, address(0), _value);
  }
}

contract CoomiToken is ERC223Token {
    string public constant name = 'Coomi';
    string public constant symbol = 'COOMI';
    uint public constant decimals = 18;

    constructor(uint256 _totalSupply) public {
        totalSupply = _totalSupply * 10 ** decimals;
        balances[msg.sender] = totalSupply;
    }
}
