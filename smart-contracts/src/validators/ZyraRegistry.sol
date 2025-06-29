// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IZyra.sol";
import "../ZyraImplementation.sol";
import "./AccountFactory.sol";

/**
 * @title ZyraRegistry
 * @notice Registry contract for managing Zyra wallet deployments
 * @dev Handles wallet creation and address computation
 */
contract ZyraRegistry {
    address public walletImplementation;
    address public admin;

    mapping(address => bool) public accounts;
    mapping(bytes32 => address) public accountAddresses;

    event AccountCreated(
        address indexed owner,
        uint256 indexed salt,
        address indexed account
    );
    event ImplementationUpdated(
        address indexed oldImplementation,
        address indexed newImplementation
    );
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Unauthorized");
        _;
    }

    constructor(address _implementation, address _admin) {
        require(
            _implementation != address(0) && _admin != address(0),
            "Invalid addresses"
        );
        walletImplementation = _implementation;
        admin = _admin;
    }

    /**
     * @notice Create a new wallet account
     * @param owner The owner of the wallet
     * @param salt Salt for deterministic address generation
     * @return account The deployed wallet address
     */
    function createAccount(
        address owner,
        uint256 salt
    ) external returns (address payable account) {
        require(owner != address(0), "Invalid owner");

        account = payable(getAddress(owner, salt));

        require(account.code.length == 0, "Account already exists");

        bytes32 saltHash = keccak256(abi.encodePacked(owner, salt));

        // Create proxy with deterministic address
        bytes memory creationCode = abi.encodePacked(
            hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
            walletImplementation,
            hex"5af43d82803e903d91602b57fd5bf3"
        );

        // Deploy the proxy
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, creationCode)
            account := create2(0, ptr, 0x37, saltHash)
        }

        require(account != address(0), "Failed to deploy account");

        // Initialize the account
        bytes memory initData = abi.encode(owner, address(0)); // entryPoint will be set later
        (bool success, ) = account.call(
            abi.encodeWithSignature("initialize(bytes)", initData)
        );
        require(success, "Initialization failed");

        accounts[account] = true;
        accountAddresses[saltHash] = account;

        emit AccountCreated(owner, salt, account);
    }

    /**
     * @notice Get the account address for a given owner and salt
     * @param owner The owner of the wallet
     * @param salt Salt for deterministic address generation
     * @return The computed wallet address
     */
    function getAddress(
        address owner,
        uint256 salt
    ) public view returns (address) {
        require(owner != address(0), "Invalid owner");

        bytes32 saltHash = keccak256(abi.encodePacked(owner, salt));

        // Check if account already exists
        address existingAccount = accountAddresses[saltHash];
        if (existingAccount != address(0)) {
            return existingAccount;
        }

        // Compute deterministic address
        bytes memory creationCode = abi.encodePacked(
            hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
            walletImplementation,
            hex"5af43d82803e903d91602b57fd5bf3"
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                saltHash,
                keccak256(creationCode)
            )
        );

        return address(uint160(uint256(hash)));
    }

    /**
     * @notice Get the current implementation address
     * @return The implementation contract address
     */
    function implementation() external view returns (address) {
        return walletImplementation;
    }

    /**
     * @notice Update the implementation address
     * @param newImplementation The new implementation address
     */
    function updateImplementation(
        address newImplementation
    ) external onlyAdmin {
        require(newImplementation != address(0), "Invalid address");

        address oldImplementation = walletImplementation;
        walletImplementation = newImplementation;

        emit ImplementationUpdated(oldImplementation, newImplementation);
    }

    /**
     * @notice Update the admin address
     * @param newAdmin The new admin address
     */
    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");

        address oldAdmin = admin;
        admin = newAdmin;

        emit AdminUpdated(oldAdmin, newAdmin);
    }

    /**
     * @notice Check if an address is a valid account
     * @param account The address to check
     * @return True if the address is a valid account
     */
    function isValidAccount(address account) external view returns (bool) {
        return accounts[account];
    }
}
