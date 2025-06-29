// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";

/**
 * @title IZyra
 * @notice Main interface for the Zyra Account Abstraction wallet
 * @dev Follows EIP-4337 structure for account abstraction
 */
interface IZyra {
    /**
     * @notice Execute a transaction through the wallet
     * @param target Target contract address
     * @param value ETH value to send
     * @param data Calldata for the transaction
     * @return success Whether the transaction was successful
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) external returns (bool success);

    /**
     * @notice Execute multiple transactions in a batch
     * @param targets Array of target contract addresses
     * @param values Array of ETH values to send
     * @param datas Array of calldata for the transactions
     * @return success Whether all transactions were successful
     */
    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external returns (bool success);

    /**
     * @notice Validate a user operation according to EIP-4337
     * @param userOp The user operation to validate
     * @param userOpHash Hash of the user operation
     * @param missingAccountFunds Funds needed to be deposited
     * @return validationData Validation data for the operation
     */
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData);

    /**
     * @notice Get the nonce for the wallet
     * @return The current nonce
     */
    function nonce() external view returns (uint256);

    /**
     * @notice Get the entry point address
     * @return The entry point contract address
     */
    function entryPoint() external view returns (address);

    /**
     * @notice Check if a signature is valid according to ERC-1271
     * @param hash Hash of the data that was signed
     * @param signature Signature to validate
     * @return magicValue Magic value indicating valid signature
     */
    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    ) external view returns (bytes4 magicValue);

    function resetOwners(bytes calldata pubKey) external;

    function isModule(address addr) external view returns (bool);

    function isHook(address addr) external view returns (bool);
}
