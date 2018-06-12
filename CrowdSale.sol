pragma solidity ^0.4.23;


import "./SafeMath.sol";
import "./CoomiToken.sol";


interface token {
    function transfer(address receiver, uint amount) external;
}

contract Crowdsale {
    using SafeMath for uint;
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    constructor(
        uint fundingGoalInEthers,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = msg.sender;
        fundingGoal = fundingGoalInEthers * 1 ether;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        beneficiary.send(amount)
        tokenReward.transfer(msg.sender, amount / price);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        emit FundTransfer(msg.sender, amount, true);
    }

    function checkGoalReached() public {
        if (amountRaised >= fundingGoal) {
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
    }

    function setPrice(uint price) {

    }
}
