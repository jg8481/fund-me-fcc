// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

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



/*
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
*/
// Moved the above getPrice() and getConversionRate functions to the PriceConverter.sol library.

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;
   
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    // Setting this to constant has a noticeable gas savings.

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    
    address public immutable i_owner;
    // Setting this to immutable has a noticeable gas savings.

    constructor() {
       // A constructor is an optional function declared with the constructor keyword which is executed upon contract creation, and where you can run contract initialization code.
       i_owner = msg.sender;
    }

    function fund() public payable{
        //msg.value.getConversionRate();
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You did not send enough funds in USD.");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value; 
    }

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        return priceFeed.version();
    }

    function withdraw() public onlyOwner {
        // This will use a for-loop.
        // It will use the address[] array and loop through it this way...
        // [a, b, c, d] <-- The values inside the array.
        //  0. 1. 3. 4. <-- The for-loop will iterate over these index postions.

        // Anatomy of the for-loop keyword...
        // for(/* starting index, ending index, step amount */)

        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
          address funder = funders[funderIndex];
          addressToAmountFunded[funder] = 0;
        }

        // The following will reset the array. 
        funders = new address[](0);

        // // The following will actually withdraw the funds. Here are 3 different ways
        // // ... trasfer
        // payable(msg.sender).transfer(address(this).balance);
        // // ... send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send has failed.");
        // // ... call
        (bool callSuccess, )= payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call has failed.");
     }

     modifier onlyOwner {
        // require(msg.sender == i_owner, "Sender is not the owner of this contract.");
        if(msg.sender != i_owner) { revert NotOwner(); }
        _;
     }

     receive() external payable { 
        fund();
     }

     fallback() external payable { 
        fund();
     }

}

