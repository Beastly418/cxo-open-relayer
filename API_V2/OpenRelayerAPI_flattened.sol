
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: API_V2/Bottable.sol



pragma solidity ^0.8.0;



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
// File: API_V2/IRelayerAPI.sol



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
// File: API_V2/OpenRelayerAPI.sol



pragma solidity ^0.8.0;



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