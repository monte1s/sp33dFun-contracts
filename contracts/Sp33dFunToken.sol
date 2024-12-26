// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Sp33dFunToken is ERC20 {
    error Bad_Supply();

    string public uri;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address tokenOwner,
        uint256 initialSupply,
        uint256 initialAmount
    ) ERC20(_name, _symbol) {
        require(initialSupply > 0, "Initial supply must be greater than 0");
        require(initialSupply >= initialAmount, "Invalid initial Amount!");
        
        uri = _uri;
        _mint(msg.sender, initialAmount);
        _mint(tokenOwner, initialSupply - initialAmount);
    }
}
