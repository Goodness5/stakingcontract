// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IUSDT {
    function approve(address _spender, uint256 _value) external;

    function balanceOf(address who) external view returns (uint256);

    function allowance(address _owner, address _spender)
        external
        returns (uint256 remaining);

 function symbol() external view returns (string memory);
    
}