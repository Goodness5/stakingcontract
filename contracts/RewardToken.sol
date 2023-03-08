// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
contract Superman is ERC20 {

    string  _name;
    
    string  _symbol;
    constructor(string memory name, string memory symbol) ERC20(name, symbol){
        _mint(msg.sender, 10000000);
    }

    
}