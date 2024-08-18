// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "./Bottable.sol";
import "./ITokenDistAPI.sol";

contract OpenRelayerTokenDistAPI is Bottable, ITokenDistAPI {

    /*
    *   @dev [distributionID][entry][name, amt]
    */
    uint[][][] public distributions;

    constructor(address _initialBot) Bottable(_initialBot, msg.sender) {
        
    }

    // Setters

    function pushDistribution(uint[][] memory _distribution) external {
        distributions.push(_distribution);
    }

    function updateDistribution(uint _id, uint[][] memory _distribution) external {
        distributions[_id] = _distribution;
    }

    // Getters

    function getDistribution() external view returns (uint[][] memory) {
        return distributions[distributions.length-1];
    }

    function getEntries(uint _id, uint _numEntries) external view returns(uint[][] memory) {
        uint[][] memory retVal = new uint[][](_numEntries);
        uint start = distributions[_id].length - _numEntries;
        uint j = 0;
        for(uint i = start; i < distributions[_id].length; i++){
            retVal[j] = distributions[_id][i];
            j++;
        }
        return retVal;
    }


}