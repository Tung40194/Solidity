/**
 * Derived and adjusted from Nguyen Viet Dinh's version
 * Provides bank deposit service to multiple users
 * Each user can deposit many times with different amounts of ETH and terms
 * User is only able to withdraw when period's over
 * data structure example for user A and user B
 **********************************************************
 *      A                    A                  A
 *  3ETH, 2days         0.5ETH, 10days      50ETH, 100days
 *      time1               time2               time3
 *
 *                   B                   B
 *              0.01ETH, 10days     0.1ETH, 40days
 *                  time4               time5
 **********************************************************
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract holdYourEther {
    using SafeMath for uint256;
    
    address payable public service_provider;
    
    // deposit an amount of ETH in a period of time
    struct deposit_st{
        uint256 amount;
        uint256 term;
    }
    // mapping account address => deposit_list
    mapping (address =>deposit_st[]) depositors;
    
    event Deposit(address account,uint256 amount,uint256 term);
    event Withdrawal(address account,uint index);
    event Transfer(address account,address to,uint256 amount,uint256 term);
    
    constructor() public {
        // whoever deploys this contracts is the service provider
        service_provider = msg.sender;
    }

    // fallback function responsible for handling ETH from user
    function () external payable {
        require(msg.sender != address(0x0));
        deposit(now);
    }

    // user may want to deposit in a period
    function deposit_period (uint256 number_of_days) public payable {
        uint256 term =now+number_of_days*86400;
        deposit(term);
    }

    function deposit(uint256 term) public payable {
        uint256 amount=msg.value;
        require(msg.sender != address(0x0));
        require(amount>0);
        uint256 fee=amount.div(200); // fee 0.5% for each deposit :))
        uint256 amount_of_deposit=amount.sub(fee);
        service_provider.transfer(fee); //service provider takes service fee
        deposit_to_address(msg.sender,amount_of_deposit,term);
        emit Deposit (msg.sender,amount_of_deposit,term);
    }

    //index: each time user deposit, an index is assigned
    function withdrawal(uint index) public {
        //validate deposit available
        require(index<depositors[msg.sender].length);
        require(depositors[msg.sender][index].amount > 0);
        require(depositors[msg.sender][index].term < now);
        //return ethereum to depositor
        msg.sender.transfer(depositors[msg.sender][index].amount); // send ETH from smart contract to the function caller
        remove_deposit(msg.sender,index);
        emit Withdrawal(msg.sender,index);
    }
    function transfer(address to,uint index) public{
        //validate deposit available
        require(index<depositors[msg.sender].length);
        require(depositors[msg.sender][index].amount>0);
        require(depositors[msg.sender][index].term<now);
        uint256 _amount=depositors[msg.sender][index].amount;
        uint256 _term=depositors[msg.sender][index].term;
        //remove the deposit from the old account
        remove_deposit(msg.sender,index);
        deposit_to_address(to,_amount,_term);
        emit Transfer(msg.sender,to,_amount,_term);
    }

    function deposit_to_address(address account,uint256 _amount,uint256 _term) private {
        // uint256 currenttime=now;
        // prevent issues in advance
        // when user deposit too quickly, 
        // Insignificant time deviation probably messes up data in depositors
        // while(depositors[account].deposits[currenttime].amount>0) {
        //     currenttime++;
        // }
        uint depositListLength = depositors[account].length;
        depositors[account][depositListLength] = deposit_st({amount:_amount, term:_term});
    }

    function remove_deposit(address account, uint index) private{
        delete depositors[account][index]; // this leaves gaps in the array
    }

    function get_list_deposit(address account) public view returns (deposit_st[] memory){
        return depositors[account];
    }

    function get_deposit_balance(address account, uint index) public view returns (uint256){
        return depositors[account][index].amount;
    }

    function get_deposit_term(address account, uint index) public view returns (uint256){
        return depositors[account][index].term;
    }

    // returns contract's balance
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
