// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Storage.sol";

//This is our funcional contract. Everything from the proxy will be funneled here. Remember this can be upgraded and replaced
//Remember Dogs "is" Storage so all the state vars in Storage.sol exist here. They have to exisst here. Always needs to match up.
contract Dogs is Storage {

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  constructor() {
    owner = msg.sender;
  }

  //Remember we can create a ton more of these (both getter and setter) in a new fuctional contract if we needed to (this is upgradeable), one for cats, turtles, etc.
  function getNumberOfDogs() public view returns(uint256) {
    return _uintStorage["Dogs"];
  }

  function setNumberOfDogs(uint256 toSet) public {
    _uintStorage["Dogs"] = toSet;
  }
}
