// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title IZyraRegistry
 * @notice Interface for the Zyra wallet registry
 * @dev Manages wallet implementations and deployments
 */
interface IZyraRegistry {
    /**
     * @notice Create a new wallet account
     * @param owner The owner of the wallet
     * @param salt Salt for deterministic address generation
     * @return account The deployed wallet address
     */
    function createAccount(
        address owner,
        uint256 salt
    ) external returns (address account);

    /**
     * @notice Get the account address for a given owner and salt
     * @param owner The owner of the wallet
     * @param salt Salt for deterministic address generation
     * @return The computed wallet address
     */
    function getAddress(
        address owner,
        uint256 salt
    ) external view returns (address);

    /**
     * @notice Get the current implementation address
     * @return The implementation contract address
     */
    function implementation() external view returns (address);

    /**
     * @notice Update the implementation address
     * @param newImplementation The new implementation address
     */
    function updateImplementation(address newImplementation) external;

    /**
     * @notice Check if an address is a valid account
     * @param account The address to check
     * @return True if the address is a valid account
     */
    function isValidAccount(address account) external view returns (bool);

    function register(address account) external;

    function isZyra(address account) external view returns (bool);
}
