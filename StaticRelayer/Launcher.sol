// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "./RelayerVault.sol";

contract Launcher {

    address owner = address(0xab91be9C89Eb7C38b52abd60ce3DE24Ea36a4db0);
    address harvestor = address(0x39043f59D85BD60992eD33f54f4A88e08280326B);
    address token = address(0xf2ae0038696774d65E67892c9D301C5f2CbbDa58);// 0xEfC2Aa829236c0492AB41B994f5cFF078f6beE0c << test cxo, real cxo >>address(0xf2ae0038696774d65E67892c9D301C5f2CbbDa58);


    RelayerVault public vault;

    constructor() {
        vault = new RelayerVault(token, owner, harvestor);
        vault.transferOwnership(owner);

    }

}