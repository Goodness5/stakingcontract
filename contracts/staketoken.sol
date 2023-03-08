// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
contract Undead is ERC20, Ownable {

    string  _name;
    string  _symbol;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _name = "Undead";
        _symbol = "SG";
        _mint(msg.sender, 10000000);
    }

    function withdrawEther() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "insufficient ether");
        payable(owner()).transfer(balance);
    }

    
    function withdrawToken(address tokenAddress, uint256 amount) public onlyOwner {
        require(tokenAddress != address(this), "Cannot withdraw this token");
        require(amount > 0, "Withdraw amount must be greater than zero");
        ERC20 token = ERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "Insufficient token balance in contract");
        require(token.transfer(owner(), amount), "Token transfer failed");
    }

    
    receive() external payable {
        require(msg.sender != tx.origin, "Token transfer from contract not allowed");
    }
}
