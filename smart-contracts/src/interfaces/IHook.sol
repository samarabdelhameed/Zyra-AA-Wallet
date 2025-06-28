// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {PackedUserOperation} from "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {IInitializable} from "./IInitializable.sol";

/**
 * @title IHook
 * @notice Interface for modular hooks in the Zyra wallet
 * @dev Hooks allow for custom logic to be executed before/after transactions
 */
interface IHook {
    /**
     * @notice Execute hook logic before a transaction
     * @param target Target contract address
     * @param value ETH value to send
     * @param data Calldata for the transaction
     * @param hookData Additional data for the hook
     */
    function beforeExecution(
        address target,
        uint256 value,
        bytes calldata data,
        bytes calldata hookData
    ) external;

    /**
     * @notice Execute hook logic after a transaction
     * @param target Target contract address
     * @param value ETH value that was sent
     * @param data Calldata that was used
     * @param hookData Additional data for the hook
     * @param success Whether the transaction was successful
     */
    function afterExecution(
        address target,
        uint256 value,
        bytes calldata data,
        bytes calldata hookData,
        bool success
    ) external;

    /**
     * @notice Check if the hook is enabled for a specific operation
     * @param target Target contract address
     * @param value ETH value to send
     * @param data Calldata for the transaction
     * @return True if the hook should be executed
     */
    function isEnabled(
        address target,
        uint256 value,
        bytes calldata data
    ) external view returns (bool);
}

interface IValidationHook is IInitializable, IERC165 {
    function validationHook(
        bytes32 signedHash,
        PackedUserOperation calldata userOp,
        bytes calldata hookData
    ) external;
}

interface IExecutionHook is IInitializable, IERC165 {
    function preExecutionHook(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bytes memory context);

    function postExecutionHook(bytes memory context) external;
}
