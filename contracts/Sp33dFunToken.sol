// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import {ERC20Upgradeable} from "./ERC20Upgradeable.sol";

contract Sp33dFunToken is ERC20Upgradeable {
    string public uri;
    bool initialized = false;

    modifier checkInitialize() {
        require(initialized == false, "Already initialized!");
        _;
        initialized = true;
    }
  
    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        uint256 initialSupply
    ) external checkInitialize {
        require(initialSupply > 0, "Initial supply must be greater than 0");
        __ERC20_init(_name, _symbol);

        uri = _uri;
        _mint(msg.sender, initialSupply);
    }
}
    