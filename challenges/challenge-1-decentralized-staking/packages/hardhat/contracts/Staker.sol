// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  
  bool public completed;
  uint256 public constant threshold = 1 ether;

  mapping ( address => uint256 ) public balances;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw = false;
  event Stake(address, uint);


  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted {
    require(!completed, "Completed");
    _;
  }

  function stake() public payable {
        require(!openForWithdraw || !exampleExternalContract.completed() , "Open for withdraw"); 

      balances[msg.sender] = msg.value;
      emit Stake(msg.sender, msg.value);
  }

  function execute() public notCompleted {
    require(block.timestamp >= deadline, "Deadline not reached");
    require(!openForWithdraw || !exampleExternalContract.completed() , "Open for withdraw"); 
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {return 0;}
    else {return deadline - block.timestamp;}
  }

  function withdraw() public notCompleted {
    require(openForWithdraw, "Not open for withdraw");
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
    // You only can withdraw the amount that you deposited
  }

  receive() external payable {
    stake();
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}
