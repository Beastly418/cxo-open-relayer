// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

contract CXORelayer {
    function relayCall(address from, address recipient, bytes memory encodedFunction, uint256 nonce, bytes memory signature, uint256 reward, address rewardRecipient, bytes memory rewardSignature) external {
        
    }
    event TransactionRelayed(address indexed from, uint256 indexed nonce, bytes32 indexed encodedFunctionHash);
}