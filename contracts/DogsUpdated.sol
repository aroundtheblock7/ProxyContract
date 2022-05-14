// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Storage.sol";

//This is our udpated Dogs contract (functional contract). The only diff we making is adding and onlyOwner modifer in the setNumberOfDogs contract.
//The other things we need to do... make sure this contract is named DogsUpdated and go to the deploy migrations file to add this contract
//We also need to create the script in the deploy... get an instance of the contract, call whatever functions we want, etc.
//General rule - We can never have any other variables in our functional contracts apart from whats in Storage. It has to match up or it will cause errors.
contract DogsUpdated is Storage {

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  //this calls initialize function upon deployment. Initalize can only be called once because of require so can not be called again.
  constructor() {
    initialize(msg.sender);
  }

  //initalized is bool in our storage. Here we require it hasn't been initialized yet to ensure this can only be run once.
  function initialize(address _owner) public {
    require(!_initialized);
    owner = _owner;
    _initialized = true;
  }

  function getNumberOfDogs() public view returns(uint256) {
    return _uintStorage["Dogs"];
  }

  function setNumberOfDogs(uint256 toSet) public onlyOwner {
    _uintStorage["Dogs"] = toSet;
  }
}
