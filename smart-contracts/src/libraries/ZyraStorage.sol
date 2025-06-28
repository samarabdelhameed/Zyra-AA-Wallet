// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

/**
 * @title ZyraStorage
 * @notice Storage layout for the Zyra wallet
 * @dev Uses diamond storage pattern for upgradeable contracts
 */
library ZyraStorage {
    //keccak256('zyra.contracts.ZyraStorage') - 1
    bytes32 private constant ZYRA_STORAGE_SLOT =
        0x3248da1aeae8bd923cbf26901dc4bfc6bb48bb0fbc5b6102f1151fe7012884f4;

    struct Layout {
        // ┌───────────────────┐
        // │   Ownership Data  │
        address owner;
        address entryPoint;
        uint256 nonce;
        bool initialized;
        mapping(bytes => bytes) r1Owners;
        mapping(address => address) k1Owners;
        uint256[50] __gap_0;
        // └───────────────────┘

        // ┌───────────────────┐
        // │     Validation    │
        mapping(address => address) r1Validators;
        mapping(address => address) k1Validators;
        uint256[50] __gap_2;
        // └───────────────────┘

        // ┌───────────────────┐
        // │       Module      │
        mapping(address => address) modules;
        uint256[50] __gap_3;
        // └───────────────────┘

        // ┌───────────────────┐
        // │       Hooks       │
        mapping(address => address) validationHooks;
        mapping(address => address) executionHooks;
        mapping(address => mapping(bytes32 => bytes)) hookDataStore;
        uint256[50] __gap_4;
        // └───────────────────┘
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = ZYRA_STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function setOwner(Layout storage l, address _owner) internal {
        l.owner = _owner;
    }

    function getOwner(Layout storage l) internal view returns (address) {
        return l.owner;
    }

    function setEntryPoint(Layout storage l, address _entryPoint) internal {
        l.entryPoint = _entryPoint;
    }

    function getEntryPoint(Layout storage l) internal view returns (address) {
        return l.entryPoint;
    }

    function incrementNonce(Layout storage l) internal {
        l.nonce++;
    }

    function getNonce(Layout storage l) internal view returns (uint256) {
        return l.nonce;
    }

    function setInitialized(Layout storage l, bool _initialized) internal {
        l.initialized = _initialized;
    }

    function isInitialized(Layout storage l) internal view returns (bool) {
        return l.initialized;
    }
}
