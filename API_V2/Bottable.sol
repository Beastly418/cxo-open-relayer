// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Bottable is Ownable {

    mapping(address => bool) public approvedBots;

    constructor(address _initialBot, address _owner) Ownable(_owner) {
        approvedBots[_initialBot] = true;
    }

    function addBot(address _bot) public onlyOwner {
        require(_bot != address(0));
        approvedBots[_bot] = true;
    }

    function removeBot(address _bot) public onlyOwner {
        require(_bot != address(0));
        approvedBots[_bot] = false;
    }

    modifier onlyBot() {
        require(approvedBots[msg.sender]);
        _;
    }
}