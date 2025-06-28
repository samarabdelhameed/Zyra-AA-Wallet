// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IZyra.sol";
import "../interfaces/IInitializable.sol";
import "../libraries/ZyraStorage.sol";
import "../libraries/Errors.sol";

/**
 * @title ZyraImplementation
 * @notice Main implementation contract for the Zyra Account Abstraction wallet
 * @dev Follows EIP-4337 for account abstraction
 */
contract ZyraImplementation is IZyra, IInitializable {
    using ZyraStorage for ZyraStorage.Layout;

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
    ) external override returns (bool success) {
        ZyraStorage.Layout storage l = ZyraStorage.layout();

        if (msg.sender != l.entryPoint && msg.sender != l.owner) {
            revert Errors.Unauthorized();
        }

        (success, ) = target.call{value: value}(data);
        if (!success) revert Errors.ExecutionFailed();
    }

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
    ) external override returns (bool success) {
        ZyraStorage.Layout storage l = ZyraStorage.layout();

        if (msg.sender != l.entryPoint && msg.sender != l.owner) {
            revert Errors.Unauthorized();
        }

        require(
            targets.length == values.length && targets.length == datas.length,
            "Array length mismatch"
        );

        for (uint256 i = 0; i < targets.length; i++) {
            (bool callSuccess, ) = targets[i].call{value: values[i]}(datas[i]);
            if (!callSuccess) revert Errors.ExecutionFailed();
        }

        return true;
    }

    /**
     * @notice Validate a user operation according to EIP-4337
     * @param userOp The user operation to validate
     * @param userOpHash Hash of the user operation
     * @param missingAccountFunds Funds needed to be deposited
     * @return validationData Validation data for the operation
     */
    function validateUserOp(
        bytes calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external override returns (uint256 validationData) {
        ZyraStorage.Layout storage l = ZyraStorage.layout();

        if (msg.sender != l.entryPoint) revert Errors.InvalidEntryPoint();

        // Increment nonce
        l.incrementNonce();

        // Handle missing funds
        if (missingAccountFunds > 0) {
            (bool success, ) = l.entryPoint.call{value: missingAccountFunds}(
                ""
            );
            if (!success) revert Errors.ExecutionFailed();
        }

        return 0; // Success
    }

    /**
     * @notice Get the nonce for the wallet
     * @return The current nonce
     */
    function nonce() external view override returns (uint256) {
        return ZyraStorage.layout().getNonce();
    }

    /**
     * @notice Get the entry point address
     * @return The entry point contract address
     */
    function entryPoint() external view override returns (address) {
        return ZyraStorage.layout().getEntryPoint();
    }

    /**
     * @notice Check if a signature is valid according to ERC-1271
     * @return magicValue Magic value indicating valid signature
     */
    function isValidSignature(
        bytes32,
        bytes calldata
    ) external pure override returns (bytes4 magicValue) {
        return 0x1626ba7e; // ERC-1271 magic value
    }

    /**
     * @notice Check if the contract has been initialized
     * @return True if the contract has been initialized
     */
    function initialized() external view returns (bool) {
        return ZyraStorage.layout().isInitialized();
    }

    /**
     * @notice Initialize the contract
     * @param data Initialization data
     */
    function init(bytes calldata data) external override {
        ZyraStorage.Layout storage l = ZyraStorage.layout();

        if (l.isInitialized()) revert Errors.AlreadyInitialized();

        // Decode initialization data
        (address owner, address entryPointAddr) = abi.decode(
            data,
            (address, address)
        );

        if (owner == address(0)) revert Errors.InvalidAddress();
        // Allow entryPoint to be set later, so we don't require it to be non-zero here

        l.setOwner(owner);
        l.setEntryPoint(entryPointAddr);
        l.setInitialized(true);
    }

    /**
     * @notice Disable the contract
     */
    function disable() external override {
        ZyraStorage.Layout storage l = ZyraStorage.layout();
        if (msg.sender != l.owner) revert Errors.Unauthorized();
        l.setInitialized(false);
    }

    /**
     * @notice Reset owners with new public key
     */
    function resetOwners(bytes calldata) external view override {
        // Implementation would decode pubKey and update owners
        // For now, this is a placeholder
    }

    /**
     * @notice Check if an address is a module
     */
    function isModule(address) external pure override returns (bool) {
        // Implementation would check against module list
        // For now, return false as placeholder
        return false;
    }

    /**
     * @notice Check if an address is a hook
     */
    function isHook(address) external pure override returns (bool) {
        // Implementation would check against hook list
        // For now, return false as placeholder
        return false;
    }

    /**
     * @notice Update the entry point address
     * @param newEntryPoint The new entry point address
     */
    function updateEntryPoint(address newEntryPoint) external {
        ZyraStorage.Layout storage l = ZyraStorage.layout();

        if (msg.sender != l.owner) revert Errors.Unauthorized();
        if (newEntryPoint == address(0)) revert Errors.InvalidAddress();

        l.setEntryPoint(newEntryPoint);
    }

    /**
     * @notice Receive function to accept ETH
     */
    receive() external payable {}
}
