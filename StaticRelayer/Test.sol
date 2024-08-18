// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "./RelayerVault.sol";
import "./TestToken.sol";

contract TestLauncher {

    address acc0 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    address acc1 = address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
    address acc2 = address(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
    address acc3 = address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);

    TestToken public token;
    RelayerVault public vault;

    constructor() {
        token = new TestToken(msg.sender);
        vault = new RelayerVault(address(token), acc3);
        vault.transferOwnership(acc3);

        token.ezmint(acc0, 1*10**6);
        token.ezmint(acc1, 1*10**6);
        token.ezmint(acc2, 1*10**6);

        token.ezApprove(acc0, address(vault));
        token.ezApprove(acc1, address(vault));
        token.ezApprove(acc2, address(vault));

    }

    function mintRewards() public {
        address cell = address(vault.holdingCells(0));
        token.ezmint(cell, 1*10**1);
    }

    function getTokenBalances() public view returns (uint ac0, uint ac1, uint ac2, uint ac3) {
        return (token.balanceOf(acc0), token.balanceOf(acc1), token.balanceOf(acc2), token.balanceOf(acc3));
    }
}