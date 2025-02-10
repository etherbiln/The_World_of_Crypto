// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title The World of Cyrpto
 * @dev 
 *
 * ██     ██  ██████   ██████  
 * ██     ██ ██    ██ ██      
 * ██  █  ██ ██    ██ ██      
 * ██ ███ ██ ██    ██ ██      
 *  ███ ███   ██████   █████   
**/


contract  WoC is ERC20 {
    constructor() ERC20("The World of Cyrpto", "WoC") {

    }
    
}