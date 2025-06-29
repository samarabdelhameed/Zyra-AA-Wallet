// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ZyraImplementation.sol";
import "../src/libraries/ZyraStorage.sol";
import {PackedUserOperation} from "../lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

/**
 * @title ZyraImplementationTest
 * @notice Unit tests for ZyraImplementation contract
 * @dev Tests core wallet functionality
 */
contract ZyraImplementationTest is Test {
    ZyraImplementation public implementation;
    address public owner;
    address public entryPoint;
    address public target;

    event Executed(address indexed target, uint256 value, bytes data);

    function setUp() public {
        owner = address(0x1);
        entryPoint = address(0x2);
        target = address(0x3);

        implementation = new ZyraImplementation(IEntryPoint(entryPoint));

        // Initialize the implementation
        bytes memory initData = abi.encode(owner, entryPoint);
        implementation.init(initData);
    }

    function testInitialization() public {
        assertTrue(implementation.initialized());
        assertEq(implementation.entryPoint(), entryPoint);
        assertEq(implementation.nonce(), 0);
    }

    function testExecute() public {
        vm.prank(entryPoint);

        bytes memory data = abi.encodeWithSignature("test()");
        bool success = implementation.execute(target, 0, data);

        assertTrue(success);
    }

    function testExecuteBatch() public {
        vm.prank(entryPoint);

        address[] memory targets = new address[](2);
        targets[0] = target;
        targets[1] = target;

        uint256[] memory values = new uint256[](2);
        values[0] = 0;
        values[1] = 0;

        bytes[] memory datas = new bytes[](2);
        datas[0] = abi.encodeWithSignature("test1()");
        datas[1] = abi.encodeWithSignature("test2()");

        bool success = implementation.executeBatch(targets, values, datas);

        assertTrue(success);
    }

    function testValidateUserOp() public {
        vm.prank(entryPoint);

        PackedUserOperation memory userOp = PackedUserOperation({
            sender: address(implementation),
            nonce: 0,
            initCode: "",
            callData: "",
            accountGasLimits: bytes32(0),
            preVerificationGas: 0,
            gasFees: bytes32(0),
            paymasterAndData: "",
            signature: ""
        });
        bytes32 userOpHash = keccak256(abi.encode(userOp));

        uint256 validationData = implementation.validateUserOp(
            userOp,
            userOpHash,
            0
        );

        assertEq(validationData, 0);
        assertEq(implementation.nonce(), 1);
    }

    function testIsValidSignature() public {
        bytes32 hash = keccak256("test");
        bytes memory signature = new bytes(65);

        bytes4 magicValue = implementation.isValidSignature(hash, signature);

        assertTrue(magicValue == 0x1626ba7e);
    }

    function testReinitialize() public {
        bytes memory initData = abi.encode(owner, entryPoint);

        vm.expectRevert();
        implementation.init(initData);
    }

    function testExecuteUnauthorized() public {
        vm.prank(address(0x999));

        bytes memory data = abi.encodeWithSignature("test()");

        vm.expectRevert();
        implementation.execute(target, 0, data);
    }

    function testExecuteBatchUnauthorized() public {
        vm.prank(address(0x999));

        address[] memory targets = new address[](1);
        targets[0] = target;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes[] memory datas = new bytes[](1);
        datas[0] = abi.encodeWithSignature("test()");

        vm.expectRevert();
        implementation.executeBatch(targets, values, datas);
    }

    function testValidateUserOpUnauthorized() public {
        vm.prank(address(0x999));

        PackedUserOperation memory userOp = PackedUserOperation({
            sender: address(implementation),
            nonce: 0,
            initCode: "",
            callData: "",
            accountGasLimits: bytes32(0),
            preVerificationGas: 0,
            gasFees: bytes32(0),
            paymasterAndData: "",
            signature: ""
        });
        bytes32 userOpHash = keccak256(abi.encode(userOp));

        vm.expectRevert();
        implementation.validateUserOp(userOp, userOpHash, 0);
    }
}
