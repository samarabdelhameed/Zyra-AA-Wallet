// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IZyra.sol";
import "../libraries/Errors.sol";

/**
 * @title ZyraProxy
 * @notice Proxy contract for upgradeable Zyra wallet
 * @dev Uses delegatecall to forward calls to implementation
 */
contract ZyraProxy {
    address public implementation;
    address public admin;

    event ImplementationUpdated(
        address indexed oldImplementation,
        address indexed newImplementation
    );
    event AdminUpdated(address indexed oldAdmin, address indexed newAdmin);

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

    /**
     * @notice Update the admin address
     * @param newAdmin The new admin address
     */
    function updateAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert Errors.InvalidAddress();

        address oldAdmin = admin;
        admin = newAdmin;

        emit AdminUpdated(oldAdmin, newAdmin);
    }

    /**
     * @notice Fallback function to delegate calls to implementation
     */
    fallback() external payable {
        address impl = implementation;
        if (impl == address(0)) revert Errors.InvalidAddress();

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @notice Receive function to accept ETH
     */
    receive() external payable {}
}
