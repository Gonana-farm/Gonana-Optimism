// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


// LISK ADDRESS: 0x59738fc55D4286c4aDC9b7CF3Aa0efBa25d22d33

contract GonaToken is ERC20, Ownable {
    constructor() ERC20("Gona", "GNA") {
        _mint(msg.sender, 1000000 * (10**decimals()));
    }

    //event Transfer(address indexed from, address indexed to, uint256 value);
    //event Approval(address indexed owner, address indexed spender, uint256 value);


    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    fallback() external {
        // revert("");
    }
}