// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {

    constructor(address user) ERC20("CargoX", "CXO") {
        //_mint(user, 1000000000*10**18);
    }

    /*
    function ezmint(address user, uint256 amt) public {
        _mint(user, amt*10**18);
    }

    function ezApprove(address owner, address spender) public {
        _approve(owner, spender, 1*10**(8+18));
    }*/

}