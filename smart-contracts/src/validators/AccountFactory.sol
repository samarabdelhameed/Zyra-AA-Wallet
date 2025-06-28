// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IZyraRegistry.sol";
import "../libraries/Errors.sol";
import "./ZyraProxy.sol";
import "./ZyraImplementation.sol";

/**
 * @title AccountFactory
 * @notice Factory contract for creating Zyra wallet accounts
 * @dev Handles account creation with deterministic addresses
 */
contract AccountFactory {
    address public implementation;
    address public admin;

    mapping(bytes32 => address) public accounts;

    event AccountCreated(
        address indexed owner,
        uint256 indexed salt,
        address indexed account
    );
    event ImplementationUpdated(
        address indexed oldImplementation,
        address indexed newImplementation
    );

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Errors.Unauthorized();
        _;
    }

    constructor(address _implementation, address _admin) {
        if (_implementation == address(0) || _admin == address(0))
            revert Errors.InvalidAddress();
        implementation = _implementation;
        admin = _admin;
    }

    /**
     * @notice Create a new account
     * @param owner The owner of the account
     * @param salt Salt for deterministic address generation
     * @return account The created account address
     */
    function createAccount(
        address owner,
        uint256 salt
    ) external returns (address payable account) {
        if (owner == address(0)) revert Errors.InvalidOwner();

        bytes32 saltHash = keccak256(abi.encodePacked(owner, salt));

        if (accounts[saltHash] != address(0)) revert Errors.InvalidSalt();

        ZyraProxy proxy = new ZyraProxy{salt: saltHash}(implementation, admin);
        account = payable(address(proxy));

        // Initialize the account
        bytes memory initData = abi.encode(owner, address(0)); // entryPoint will be set later
        ZyraImplementation(account).init(initData);

        accounts[saltHash] = account;

        emit AccountCreated(owner, salt, account);
    }

    /**
     * @notice Create multiple accounts
     * @param owners Array of owners
     * @param salts Array of salts
     * @return createdAccounts Array of created account addresses
     */
    function createAccounts(
        address[] calldata owners,
        uint256[] calldata salts
    ) external returns (address[] memory createdAccounts) {
        require(owners.length == salts.length, "Array length mismatch");

        createdAccounts = new address[](owners.length);

        for (uint256 i = 0; i < owners.length; i++) {
            createdAccounts[i] = this.createAccount(owners[i], salts[i]);
        }
    }

    /**
     * @notice Get the address of an account
     * @param owner The owner of the account
     * @param salt Salt for deterministic address generation
     * @return The computed account address
     */
    function getAddress(
        address owner,
        uint256 salt
    ) external view returns (address) {
        if (owner == address(0)) revert Errors.InvalidOwner();

        bytes32 saltHash = keccak256(abi.encodePacked(owner, salt));

        // Check if account already exists
        address existingAccount = accounts[saltHash];
        if (existingAccount != address(0)) {
            return existingAccount;
        }

        // Compute deterministic address
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                saltHash,
                keccak256(type(ZyraProxy).creationCode)
            )
        );

        return address(uint160(uint256(hash)));
    }

    /**
     * @notice Update the implementation address
     * @param newImplementation The new implementation address
     */
    function updateImplementation(
        address newImplementation
    ) external onlyAdmin {
        if (newImplementation == address(0)) revert Errors.InvalidAddress();

        address oldImplementation = implementation;
        implementation = newImplementation;

        emit ImplementationUpdated(oldImplementation, newImplementation);
    }
}
