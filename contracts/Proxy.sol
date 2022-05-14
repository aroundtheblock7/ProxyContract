// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Storage.sol";

//Remember we can add more functions to the proxy here but ALL the vars that are in storage must be here

contract Proxy is Storage {

  //Proxy always need to take in the functional contract address, so we need a stat var for it and set it in constructor
  address currentAddress;

  constructor(address _currentAddress) {
    owner = msg.sender;
    currentAddress = _currentAddress;
  }

  //We need the upgrade function
  function upgrade(address _newAddress) public {
    require(msg.sender == owner);
    currentAddress = _newAddress;
  }

  //Fallback function. This is how we can redirect everything from our Proxy here to the functional contract. Redirects to currentAddress
  //If a user calls a function that is not in the contract it triggers fallback which is set up to call functional (Dogs) contract
  fallback() payable external {
    address implementation = currentAddress;
    require(currentAddress != address(0));
    //msg.data is all the information about the function call that we are transmitting. It contains all the parameters that we are sending to the function
    bytes memory data = msg.data;

    //add and delegate call are part of assembly functions. Add (data, 0x20) helps us translate the delegatecall to somethign we can read
    //assembly allows us to send the function call forward to where it needs to go and returns the data to the user including if its successful/unsuccessful
    assembly {
      let result := delegatecall(gas(), implementation, add(data, 0x20), mload(data), 0, 0)
      let size := returndatasize()
      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)
      //result is our function call. So here we say if it is 0 the call was unsuccessful and if its 1 (default) its successful
      switch result
      case 0 {revert(ptr, size)} //this is revert if the call fails
      default {return(ptr, size)} //defaul is if call is succesful, we want to retrn ptr and size
    }
  }
}
