// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IInitializable} from "../interfaces/IInitializable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title IModule
 * @notice Interface for modular functionality in the Zyra wallet
 * @dev Modules provide additional functionality like recovery, session keys, etc.
 */
interface IModule is IInitializable, IERC165 {
    /**
     * @notice Initialize the module
     * @param data Initialization data
     */
    function initialize(bytes calldata data) external;

    /**
     * @notice Check if the module is enabled
     * @return True if the module is enabled
     */
    function isEnabled() external view returns (bool);

    /**
     * @notice Get the module type
     * @return The module type identifier
     */
    function getModuleType() external view returns (bytes32);

    /**
     * @notice Execute module-specific logic
     * @param data Execution data
     * @return success Whether the execution was successful
     */
    function execute(bytes calldata data) external returns (bool success);
}
