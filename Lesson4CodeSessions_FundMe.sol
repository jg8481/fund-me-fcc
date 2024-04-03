// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;


contract FundMe {
   
    function fund() public payable{
        // Goal is to send ETH to this contract
        // This will set a minimum USD amount, and give an error message when amount is to low
        require(msg.value > 1e18, "You did not send enough ETH."); // 1e18 = 1 ETH in Wei
        // ^ This "require" statement will output an error and revert (or undo the transaction) if the condition is not met
    }


}


