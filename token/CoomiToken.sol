pragma solidity ^0.4.24;

import "./token/ERC20/StandardBurnableToken.sol";

contract CoomiToken is StandardBurnableToken {
    string public constant name = 'Coomi';
    string public constant symbol = 'COOMI';
    uint public constant decimals = 18;

    constructor(uint256 _totalSupply) public {
        totalSupply_ = _totalSupply * 10 ** decimals;
    }
}

