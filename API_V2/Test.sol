// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "./OpenRelayerAPI.sol";
import "./OpenRelayerTokenDistAPI.sol";

contract Test {

    address acc0 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    address acc1 = address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
    address acc2 = address(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
    address acc3 = address(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);

    OpenRelayerAPI public api;

    OpenRelayerTokenDistAPI public tokenAPI;

    constructor() {

        api = new OpenRelayerAPI(acc0, 5);
        api.addBot(acc1);

        api.addBot(address(this));

        api.pushEntry(100);

        tokenAPI = new OpenRelayerTokenDistAPI(acc0);

    }


}