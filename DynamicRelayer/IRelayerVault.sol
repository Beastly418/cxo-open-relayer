// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IRelayerVault is IERC20 {

    event SpreadExcess(uint rewards);
    event CreateRelayer(uint cellPointer);
    event ChangedHarvestor(address newHarvestor);

    function balance() external view returns (uint256);

    function depositAll() external;
    function deposit(uint256 _amt) external;
    function withdrawAll() external;
    function withdraw(uint256 _amt) external;
    function spreadExcess() external;
    function harvest(uint _cellNumber, uint _fee) external;

    function changeHarvestor(address _harvestor) external;
    function changeFeeAddress(address _feeAddress) external;

    function getPricePerFullShare() external view returns (uint256);
    function isCellDormant(uint cell) external view returns(bool);
    function isCellEmpty(uint cell) external view returns(bool);
    function getUserDeposits(address _user) external view returns(uint256);

}