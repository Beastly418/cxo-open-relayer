// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../RelayerVault.sol";
import "../TestToken.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {

    RelayerVault vault;
    TestToken token;

    address acc0;
    address acc1;
    address acc2;
    
    /// Initiate accounts variable
    /// #sender: account-1
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        token = new TestToken(acc0);
        vault = new RelayerVault(address(token), acc2);
        vault.transferOwnership(acc0);

        
        token.ezmint(acc0, 1*10**6);
        token.ezmint(acc1, 1*10**6);
        token.ezmint(acc2, 1*10**6);

        /*token.ezApprove(acc0, address(vault));
        token.ezApprove(acc1, address(vault));
        token.ezApprove(acc2, address(vault));*/
    }
    
    
    function checkInitialOwner() public {
        Assert.equal(vault.owner(), acc0, "Owner should be acc0");
    }

    function checkInitialBalances() public {
        Assert.equal(token.balanceOf(acc0), 1*10**(6+18), "Account 0 doesn't have 1 mil");
        Assert.equal(token.balanceOf(acc1), 1*10**(6+18), "Account 1 doesn't have 1 mil");
        Assert.equal(token.balanceOf(acc2), 1*10**(6+18), "Account 2 doesn't have 1 mil");

        /*Assert.equal(token.allowance(acc0, address(vault)), 1*10**(8+18), "Account 0 approval not 100 mill");
        Assert.equal(token.allowance(acc1, address(vault)), 1*10**(8+18), "Account 1 approval not 100 mill");
        Assert.equal(token.allowance(acc2, address(vault)), 1*10**(8+18), "Account 2 approval not 100 mill");*/
    }

    /// #sender: account-1
    function checkDepositAll() public {
        //token.approve(address(vault), 1*10**(6+18));
        token.ezApprove(acc1, address(vault));
        Assert.equal(token.allowance(acc1, address(vault)), 1*10**(8+18), "Account 0 approval not 100 mill");
        vault.depositAll();
        //Assert.equal(token.balanceOf(acc0), 1*10**(6+18) - (250000*10**18), "Account 0 didn't deposit 250k");
        Assert.equal(vault.balance(), 250000*10**18, "Did not deposit 250k");
    }
}
    