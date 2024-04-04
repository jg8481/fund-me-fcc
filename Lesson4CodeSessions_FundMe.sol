// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/*
contract FundMe {
   
    uint256 public minimumUSD = 50

    function fund() public payable{
        // Goal is to send ETH to this contract
        // This will set a minimum USD amount, and give an error message when amount is too low
        require(msg.value > 1e18, "You did not send enough ETH."); // 1e18 = 1 ETH in Wei
        // ^ This "require" statement will output an error and revert (or undo the transaction) if the condition is not met
    }


}
*/


contract FundMe {
   
    uint256 public minimumUSD = 50 * 1e18;

    function fund() public payable{

        require(msg.value >= minimumUSD, "You did not send enough funds in USD."); 

    }

    // Note to self: Chainlink is capable of sending and receiving API calls. 
    // This is powerful and can be combined with Chainlink Data Feeds, 
    // Chainlink VRF (Random Number Generators, and Chainlink Automation (automated Upkeep/Triggering/Polling).
    function getPrice() public view returns(uint256) {
        // Need 2 things...
        // 1. ABI - for this getPrice function we need to create an interface
        // 2. Address
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        (,int price,,,) = priceFeed.latestRoundData();
        // ETH in USD
        // Roughly 3000.00000000
        return uint256(price * 1e10);
    }
     
    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        return priceFeed.version();
    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();

        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUSD;

    }

    //function withdraw(){ }

}
