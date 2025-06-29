// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/validators/AccountFactory.sol";
import "../src/ZyraImplementation.sol";
import "../src/validators/ZyraProxy.sol";

/**
 * @title AccountFactoryTest
 * @notice Unit tests for AccountFactory contract
 * @dev Tests account creation and address computation
 */
contract AccountFactoryTest is Test {
    AccountFactory public factory;
    ZyraImplementation public implementation;
    address public admin;
    address public owner;

    function setUp() public {
        admin = address(0x1);
        owner = address(0x2);
        address entryPoint = address(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);

        implementation = new ZyraImplementation(IEntryPoint(entryPoint));
        factory = new AccountFactory(address(implementation), admin);
    }

    function testCreateAccount() public {
        uint256 salt = 12345;

        address account = factory.createAccount(owner, salt);

        assertTrue(account != address(0));
        assertEq(factory.getAddress(owner, salt), account);
    }

    function testCreateAccounts() public {
        address[] memory owners = new address[](2);
        owners[0] = owner;
        owners[1] = address(0x3);

        uint256[] memory salts = new uint256[](2);
        salts[0] = 12345;
        salts[1] = 67890;

        address[] memory accounts = factory.createAccounts(owners, salts);

        assertEq(accounts.length, 2);
        assertTrue(accounts[0] != address(0));
        assertTrue(accounts[1] != address(0));
        assertEq(factory.getAddress(owners[0], salts[0]), accounts[0]);
        assertEq(factory.getAddress(owners[1], salts[1]), accounts[1]);
    }

    function testGetAddress() public {
        uint256 salt = 12345;

        address computedAddress = factory.getAddress(owner, salt);

        assertTrue(computedAddress != address(0));
    }

    function testCreateAccountWithZeroOwner() public {
        uint256 salt = 12345;

        vm.expectRevert();
        factory.createAccount(address(0), salt);
    }

    function testCreateAccountWithExistingSalt() public {
        uint256 salt = 12345;

        factory.createAccount(owner, salt);

        vm.expectRevert();
        factory.createAccount(owner, salt);
    }

    function testUpdateImplementation() public {
        address newImplementation = address(0x999);

        vm.prank(admin);
        factory.updateImplementation(newImplementation);

        assertEq(factory.implementation(), newImplementation);
    }

    function testUpdateImplementationUnauthorized() public {
        address newImplementation = address(0x999);

        vm.expectRevert();
        factory.updateImplementation(newImplementation);
    }

    function testUpdateImplementationWithZeroAddress() public {
        vm.prank(admin);

        vm.expectRevert();
        factory.updateImplementation(address(0));
    }

    function testCreateAccountsArrayMismatch() public {
        address[] memory owners = new address[](2);
        owners[0] = owner;
        owners[1] = address(0x3);

        uint256[] memory salts = new uint256[](1);
        salts[0] = 12345;

        vm.expectRevert("Array length mismatch");
        factory.createAccounts(owners, salts);
    }

    function testGetAddressWithZeroOwner() public {
        uint256 salt = 12345;

        vm.expectRevert();
        factory.getAddress(address(0), salt);
    }
}
