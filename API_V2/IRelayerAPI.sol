// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;


interface IRelayerAPI {
    
    // Getters
    /*
    *  @dev returns an array of uint256s which is the last X elements in the array.
    *  @param _id which array are we pulling the data from
    *  @param _numEntries how many data entries are we pulling, going backwards
    */
    function getEntries(uint _id, uint _numEntries) external view returns(uint[] memory);

    /*
    *  @dev returns a 2D array of id -> [len-1 ... len-_numEntries], _ids and _numEntries needs to have the same number of elements or it will fail
    *  @param _ids list of ids you want to pull
    *  @param _numEntries number of entries you want to pull 
    */
    function getData(uint[] memory _ids, uint[] memory _numEntries) external view returns(uint[][] memory);

    /*
    *  @dev returns a 2D array of id -> [...full array]
    *  @param _ids list of ids you want to pull
    */
    function getAllData(uint[] memory _ids) external view returns(uint[][] memory);


    // Bulk updates

    /*
    *  @dev updates one of the data arrays
    *  @warning This function does not overwrite existing day data. 
    *  @param _id data array we want to update
    *  @param _entries data we want to push into the array
    */
    function bulkUpdateEntries(uint _id, uint[] memory _entries) external;


    // Mutate existing data

    /*
    *  @dev Clears out all data from each array.
    *  @warn There is no coming back. Use at your own risk
    */
    function clearData() external;

    /*
    *  @dev updates a single entry in case we push the wrong data
    *  @param _id data array we want to update
    *  @param _amt uint256 we're setting that entry to
    *  @param _index uint256 entry we're updating
    */
    function updateEntry(uint _id, uint _index, uint _amt) external;

    // Add new data
    
    /*
    *  @dev Adds a new entry to the data array and sets it to a given value
    *  @param _id data array we want to update
    *  @param _amt uint256 we're setting that entry to
    */
    function addEntry(uint _id, uint _amt) external;

    /*
    *  @dev Adds a new data slot to the data array
    */
    function addSlot() external;

    /*
    *  @dev pushes a new data entry in and updates other data entries as needed
    *  @example We push in a day count and update week/month/year/total at the same time
    *  @param _amt uint256 we're pushing into this database
    */
    function pushEntry(uint _amt) external;
}