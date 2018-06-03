pragma solidity ^0.4.21;


library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}


// interface ERC223 {
//     function balanceOf(address who) external pure returns (uint256);
//     function allowance(address owner, address spender) external view returns (uint256);
//     function transfer(address to, uint256 value) external;
//     function transfer(address to, uint value, bytes data) external;
//     function transferFrom(address from, address to, uint256 value) external returns (bool);
//     function approve(address spender, uint256 value) external returns (bool);
//     event Transfer(address indexed from, address indexed to, uint256 value);
//     event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
//     event Approval(address indexed owner, address indexed spender, uint256 value);
// }


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

    function ERC223Token(uint256 _totalSupply) public {
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;
    }


    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
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

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        bytes memory empty;

        require(_to != address(0x0));
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value, empty);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract CoomiToken is ERC223Token {
    string public constant name = 'Coomi';
    string public constant symbol = 'COOMI';
    // same as ether. (1ether=1wei * (10 ** 18))
    uint public constant decimals = 18;

    event Burn(address indexed burner, uint indexed value);

    function burn(uint _value) public {
        require(_value > 0);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
}
