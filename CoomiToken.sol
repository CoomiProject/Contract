pragma solidity ^0.4.23;


import "./SafeMath.sol";


contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}


contract ERC223Token {
    using SafeMath for uint;
    uint256 public totalSupply;
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _totalSupply) public {
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
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

    function transfer(address _to, uint _value) public {
        uint codeLength;
        bytes memory empty;

        assembly {
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
    }

    function transfer(address _to, uint _value, bytes _data) public {
        uint codeLength;

        assembly {
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        uint codeLength;
        bytes memory empty;

        assembly {
            codeLength := extcodesize(_to)
        }

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }

        emit Transfer(msg.sender, _to, _value, empty);
        return true;
    }
}

contract BurnableERC223Token is ERC223Token {
    event Burn(address indexed burner, uint indexed value);

    function burn(uint _value) public {
        require(_value > 0);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
}

contract CoomiToken is BurnableERC223Token {
    string public constant name = 'Coomi';
    string public constant symbol = 'COOMI';
    uint public constant decimals = 18;

    constructor(uint256 _totalSupply) ERC223Token(_totalSupply * 10 ** decimals) public {}
}
