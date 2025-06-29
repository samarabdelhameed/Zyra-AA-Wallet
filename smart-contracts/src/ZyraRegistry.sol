// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {IZyraRegistry} from "./interfaces/IZyraRegistry.sol";
import {Errors} from "./libraries/Errors.sol";

contract ZyraRegistry is Ownable, IZyraRegistry {
    // Account factory contract address
    address factory;

    // Mapping of Zyra accounts
    mapping(address => bool) public isZyra;

    // Constructor function of the contracts
    constructor() Ownable(msg.sender) {}

    /**
     * @notice Registers an account as a Zyra account
     * @dev Can only be called by the factory
     * @param account address - Address of the account to register
     */
    function register(address account) external override {
        if (msg.sender != factory) {
            revert Errors.NOT_FROM_FACTORY();
        }

        isZyra[account] = true;
    }

    /**
     * @notice Sets a new factory contract
     * @dev Can only be called by the owner
     * @param factory_ address - Address of the new factory
     */
    function setFactory(address factory_) external onlyOwner {
        factory = factory_;
    }

    // Stub implementations for IZyraRegistry
    function createAccount(
        address owner,
        uint256 salt
    ) external override returns (address account) {
        revert("Not implemented");
    }

    function getAddress(
        address owner,
        uint256 salt
    ) external view override returns (address) {
        revert("Not implemented");
    }

    function implementation() external view override returns (address) {
        revert("Not implemented");
    }

    function updateImplementation(address newImplementation) external override {
        revert("Not implemented");
    }

    function isValidAccount(
        address account
    ) external view override returns (bool) {
        revert("Not implemented");
    }
}
