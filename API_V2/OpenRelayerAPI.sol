// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "./Bottable.sol";
import "./IRelayerAPI.sol";

contract OpenRelayerAPI is Bottable, IRelayerAPI {

    /*
    *   @dev The default IDs are 
    *   0 = Day
    *   1 = Week
    *   2 = Month
    *   3 = Year
    *   4 = Total
    *   pushEntry assumes these values are correct, careful about adding more because pushEntry will push data down to them all
    */
    uint[][] public data;


    constructor(address _initialBot, uint _initialDataSlots) Bottable(_initialBot, msg.sender) {
        for(uint i = 0; i < _initialDataSlots; i++) {
            data.push([0]);
        }
    }


    // Setters

    function addEntry(uint _id, uint _amt) external onlyBot {
        data[_id].push(_amt);
    }

    function pushEntry(uint _amt) external onlyBot {
        for(uint i = 0; i < data.length; i++) {
            data[i][data[i].length - 1] += _amt;
        }
    }

    function addSlot() public onlyBot {
        uint[] memory tmp;
        data.push(tmp);
    }

    // Bulk updates

    function bulkUpdateEntries(uint _id, uint[] memory _entries) external onlyBot {
        for(uint i = 0; i < _entries.length; i++) {
            data[_id].push(_entries[i]);
        }
    }


    // Mutate existing data

    function clearData() external onlyBot {
        delete data;
    }

    function updateEntry(uint _id, uint _index, uint _amt) external onlyBot {
        data[_id][_index] = _amt;
    }


    // Getters

    function getEntries(uint _id, uint _numEntries) public view returns(uint[] memory) {
        uint[] memory retVal = new uint[](_numEntries);
        uint start = data[_id].length - _numEntries;
        uint j = 0;
        for(uint i = start; i < data[_id].length; i++){
            retVal[j] = data[_id][i];
            j++;
        }
        return retVal;
    }

    function getData(uint[] memory _ids, uint[] memory _numEntries) external view returns(uint[][] memory) {
        uint[][] memory retVal = new uint[][](_ids.length);
        for(uint i = 0; i < _ids.length; i++){
            retVal[i] = getEntries(_ids[i], _numEntries[i]);
        }
        return retVal;
    }

    function getAllData(uint[] memory _ids) external view returns(uint[][] memory) {
        uint[][] memory retVal = new uint[][](_ids.length);
        for(uint i = 0; i < _ids.length; i++){
            retVal[i] = data[_ids[i]];
        }
        return retVal;
    }


}