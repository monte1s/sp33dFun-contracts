// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC20Upgradeable} from "./ERC20Upgradeable.sol";

contract Sp33dFunToken is ERC20Upgradeable {
    string public uri;
  
    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address tokenOwner,
        uint256 initialSupply,
        uint256 initialAmount
    ) external {
        require(initialSupply > 0, "Initial supply must be greater than 0");
        require(initialSupply >= initialAmount, "Invalid initial Amount!");
        __ERC20_init(_name, _symbol);

        uri = _uri;
        _mint(msg.sender, initialAmount);
        _mint(tokenOwner, initialSupply - initialAmount);
    }
}
