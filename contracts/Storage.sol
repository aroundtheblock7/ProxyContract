// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//the idea in this contract is to create genric storage mappings that can each be used multiple times by our functional contract
//for ex. for the _uintStorage we can create... uintStorage["Number"] = 10, or uintStorage"[nrOfCats"] = 5, uintStorage["Version"] = 100, and so on.
contract Storage {
  mapping(string => uint256) _uintStorage;
  mapping(string => address) _addressStorage;
  mapping(string => bool) _boolStorage;
  mapping(string => string) _strStorage;
  mapping(string => bytes4) _bytesStorage;
  address public owner;
  bool public _initialized;

}
