// SPDX-License-Identifier: BSL 1.1

pragma solidity ^0.8.0;

import "./IRelayerVault.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DynamicRelayerVault is ReentrancyGuard, Ownable, ERC20, IRelayerVault {
    using SafeERC20 for IERC20;

    IERC20 public depositToken;

    //Internal addresses for payouts
    address public feeAddress;
    address public harvestor;

    //List of addresses that hold the CXO in the pool
    address[] public holdingCells;

    uint256 public balance = 0;

    uint256 public cellPointer = 0;

    //event FeeChanged(uint cellNumber, uint newValue);

    constructor(address _depositToken, address _feeAddress, address _harvestor) ERC20("CXODynamicRelayerReceipt", "CXODRR") Ownable(msg.sender) {
        require(_depositToken != address(0), "Token can't be 0x00");
        require(_feeAddress != address(0), "Fee Address can't be 0x00");
        require(_harvestor != address(0), "Harvestor can't be 0x00");
        depositToken = IERC20(_depositToken);
        feeAddress = _feeAddress;
        harvestor = _harvestor;
        holdingCells.push(address(new HoldingCell(address(this))));
    }

    //=======================================
    //========== Deposit Functions ==========
    //=======================================

    function _deposit(uint256 _amt) internal {
        require(_amt <= 250000*10**18, "Can't Deposit more than 1 relayer at a time"); //Cap it out at 250k tokens deposit
        uint256 pooled = balance;    //balance at the time
        depositToken.safeTransferFrom(msg.sender, address(this), _amt);
        //Deposit the tokens here
        _spread(_amt);
        balance += _amt;
        //Omitting deflationary check since CXO isn't deflationary
        uint256 shares = 0;
        if(totalSupply() == 0) {
            shares = _amt;
        } else {
            shares = (_amt * totalSupply()) / pooled;
        }
        _mint(msg.sender, shares);
    }

    //Sends the CXO to the underlying holding cells
    function _spread(uint256 _amt) internal {
        //At most we can get is 250k cxo
        //Which means that we see how much we can put into the current
            //holding cell and then dump the rest into the next one
            //We will never have a holdingCells[p+1] with more than 0 CXO in it
        HoldingCell currentCell = HoldingCell(holdingCells[cellPointer]);
        uint totalDeposits = currentCell.deposits(); //Get our deposits in this cell
        uint canDeposit = (250000*10**18) - totalDeposits;
        if(canDeposit >= _amt) {
            //Deposit here
            depositToken.safeTransfer(address(currentCell), _amt);
            currentCell.deposit(_amt);
        } else {
            //Deposit what you can
            depositToken.safeTransfer(address(currentCell), canDeposit);
            currentCell.deposit(canDeposit);
            //Increment the pointer
            //Make a new Cell
            cellPointer++;
            emit CreateRelayer(cellPointer);
            if(cellPointer > holdingCells.length - 1) { //Check and see if we already have an old cell here
                holdingCells.push(address(new HoldingCell(address(this))));
            }
            currentCell = HoldingCell(holdingCells[cellPointer]);
            //Deposit the rest into the new cell
            uint rest = _amt - canDeposit;
            depositToken.safeTransfer(address(currentCell), rest);
            currentCell.deposit(rest);
        }
    }


    //=========================================
    //========== Withdrawl Functions ==========
    //=========================================

    function _withdraw(uint256 _shares) internal {
        uint256 r = (balance * _shares) / totalSupply();
        require(r <= 250000*10**18, "Can't withdraw more than 1 relayer at a time");
        _burn(msg.sender, _shares);

        _retract(r);

        depositToken.safeTransfer(msg.sender, r);
    }

    //Pulls CXO back from the holding cells and makes empty ones go dormant
    function _retract(uint256 _amt) internal {
        //At most we're withdrawing 250k cxo
        //Which means we can pull as much as possible from the current holding cell
            //then pull the rest from the next one
            //We will never have a holdingCells[p-1] with less than 0 CXO in it
            //Going to need an extra check for p = 0
        balance -= _amt;
        HoldingCell currentCell = HoldingCell(holdingCells[cellPointer]);
        uint totalDeposits = currentCell.deposits(); //Get our deposits in this cell
        if(_amt <= totalDeposits) {
            //There's enough tokens in this cell to cover the withdraw
            currentCell.withdraw(_amt);
        } else {
            //There's not enough tokens in this cell to cover the withdraw
            //Withdraw what you can
            currentCell.withdraw(totalDeposits);
            //Decrement the pointer (put a 0 check [should never happen!])
            require(cellPointer > 0, "OVERDRAFT ON THE CELLS, CELLPOINTER-- WHEN WE'RE AT CELL 0"); //SHOULD NEVER HAPPEN
            cellPointer--;
            currentCell = HoldingCell(holdingCells[cellPointer]);
            //Withdraw the rest
            uint rest = _amt - totalDeposits;
            currentCell.withdraw(rest);
        }
    }


    //============================================
    //========== Interactable Functions ==========
    //============================================
    //All of these are just nonReentrant wrappers as added security along with some limiters
    
    //Cap deposit all at 250k so we don't throw an error when you have more than 250k cxo
    function depositAll() public nonReentrant {
        uint amt = depositToken.balanceOf(msg.sender);
        if(amt > 250000*10**18) {
            //over 250k deposit so set it to 250k
            amt = 250000*10**18;
        }
        _deposit(amt);
    }

    //Number of tokens to deposit
    function deposit(uint256 _amt) public nonReentrant {
        _deposit(_amt);
    }

    //Cap withdraw all at 250k so we don't throw an error when you have more than 250k cxo 
    function withdrawAll() public nonReentrant {
        uint amt = balanceOf(msg.sender); //Get the total number of shares this user has
        uint256 r = (balance * amt) / totalSupply();
        if(r > 250000*10**18) {
            //over 250k withdraw so set it to 250k
            //x = bal * shares / ts >> (x*ts) = bal * shares >> (x*ts) / bal = shares
            amt = ((250000*10**18) * totalSupply()) / balance;
        }
        _withdraw(amt);
    }

    //Number of shares
    function withdraw(uint256 _amt) public nonReentrant {
        _withdraw(_amt);
    }

    //===========================================
    //========== Compounding Functions ==========
    //===========================================

    //All excess reward CXO that has been collecting in the vault from the cell harvests gets reinvested
    function spreadExcess() public onlyHarvestor {
        uint excessTokens = depositToken.balanceOf(address(this));  //Get the tokens sitting in the vault from harvested cells
        if(excessTokens > 250000*10**18) {
            //We have more than 250k tokens in rewards to spread
            //Spread is capped at 250k tokens
            excessTokens = 250000*10**18;
        }
        _spread(excessTokens);
        balance += excessTokens;    //Add those tokens to our total balance of deposits
        emit SpreadExcess(excessTokens);
    }

    //How we pull fees as the owner and spread out rewards, call each one daily!
    function harvest(uint _cellNumber, uint _fee) public onlyHarvestor {
        //Fee is capped at 1000 (100%) in the holding cell contract
        HoldingCell(holdingCells[_cellNumber]).harvest(_fee);
    }

    //=====================================
    //========== Owner Functions ==========
    //=====================================

    function changeHarvestor(address _harvestor) public onlyOwner {
        require(_harvestor != address(0), "Address can't be 0x00");
        harvestor = _harvestor;
        emit ChangedHarvestor(harvestor);
    }

    modifier onlyHarvestor() {
        require(msg.sender == harvestor);
        _;
    }

    function changeFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), "Address can't be 0x00");
        feeAddress = _feeAddress;
    }

    //===========================
    //========== Views ==========
    //===========================

    function getPricePerFullShare() public view returns (uint256) {
        return totalSupply() == 0 ? 1*10**18 : (balance * 1*10**18) / totalSupply();
    }

    //returns true if the cell has no deposits
    function isCellDormant(uint cell) public view returns(bool) {
        return HoldingCell(holdingCells[cell]).deposits() == 0;
    }

    //returns true if the cell has no CXO in it (counting rewards and deposits)
    function isCellEmpty(uint cell) public view returns(bool) {
        return depositToken.balanceOf(holdingCells[cell]) == 0;
    }

    function getUserDeposits(address _user) public view returns(uint256) {
        uint amt = balanceOf(_user); //Get the total number of shares this user has
        return (balance * amt) / totalSupply();
    }

}

contract HoldingCell {
    using SafeERC20 for IERC20;

    DynamicRelayerVault public vault;

    uint256 public deposits = 0;

    event Harvest(uint256 fees, uint256 rewards);

    constructor(address _vault) {
        vault = DynamicRelayerVault(_vault);
    }
    
    function deposit(uint256 _amt) public onlyVault {
        //Tokens are sent here by the vault
        deposits += _amt;
    }

    function withdraw(uint256 _amt) public onlyVault {
        deposits -= _amt;
        vault.depositToken().safeTransfer(address(vault), _amt);
    }

    function harvest(uint256 _fee) public onlyVault {
        require(_fee <= 1000, "Fee can't be more than 100% (1000/1000)");  //Cap the fee at 100% (1000/1000)
        //Get the amount of non deposited cxo and send it to the main contract to be claimed
        uint256 rewards = vault.depositToken().balanceOf(address(this)) - deposits;

        uint256 fees = (rewards * _fee) / 1000;  
        emit Harvest(fees, rewards);

        vault.depositToken().safeTransfer(vault.feeAddress(), fees);

        uint256 userRewards = rewards - fees;

        vault.depositToken().safeTransfer(address(vault), userRewards);
        //vault.spreadExcess();
    }

    modifier onlyVault() {
        require(msg.sender == address(vault));
        _;
    }
}