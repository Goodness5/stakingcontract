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
        _mint(msg.sender, 1000000000);
    }

    function withdrawEther() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "insufficient ether");
        payable(owner()).transfer(balance);
    }

    
  function withdrawToken(address tokenAddress) public onlyOwner {
    require(tokenAddress != address(this), "Cannot withdraw this token");
    IERC20 token = IERC20(tokenAddress);
    uint256 balance = token.balanceOf(address(this));
    require(balance > 0, "Contract has no token balance");
    bool transfered = token.transfer(owner(), balance);
    require(transfered, "Token transfer to owner failed");
}


    
    receive() external payable {
        require(msg.sender != tx.origin, "Token transfer from contract not allowed");
    }
}
