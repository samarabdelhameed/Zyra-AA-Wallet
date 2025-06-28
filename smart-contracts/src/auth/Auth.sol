// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {EntrypointAuth} from "./EntrypointAuth.sol";
import {ModuleAuth} from "./ModuleAuth.sol";
import {SelfAuth} from "./SelfAuth.sol";
import {HookAuth} from "./HookAuth.sol";
import {Errors} from "../libraries/Errors.sol";
import {IValidator} from "../interfaces/IValidator.sol";

/**
 * @title Auth
 * @notice Abstract contract that organizes authentification logic for the contract
 * @author https://getclave.io
 */
abstract contract Auth is EntrypointAuth, SelfAuth, ModuleAuth, HookAuth {
    mapping(address => bool) public authorized;
    mapping(bytes32 => address) public validators;
    mapping(bytes32 => bool) public enabledValidators;

    event ValidatorAdded(
        bytes32 indexed validatorType,
        address indexed validator
    );
    event ValidatorRemoved(bytes32 indexed validatorType);
    event ValidatorEnabled(bytes32 indexed validatorType, bool enabled);
    event Authorized(address indexed account, bool authorized);

    modifier onlyAuthorized() {
        if (!authorized[msg.sender]) revert Errors.Unauthorized();
        _;
    }

    modifier onlySelfOrModule() {
        if (msg.sender != address(this) && !_isModule(msg.sender)) {
            revert Errors.NOT_FROM_SELF_OR_MODULE();
        }
        _;
    }

    /**
     * @notice Add a validator
     * @param validatorType The type of validator
     * @param validator The validator contract address
     */
    function addValidator(
        bytes32 validatorType,
        address validator
    ) external virtual onlyAuthorized {
        if (validator == address(0)) revert Errors.InvalidAddress();
        validators[validatorType] = validator;
        emit ValidatorAdded(validatorType, validator);
    }

    /**
     * @notice Remove a validator
     * @param validatorType The type of validator to remove
     */
    function removeValidator(
        bytes32 validatorType
    ) external virtual onlyAuthorized {
        delete validators[validatorType];
        enabledValidators[validatorType] = false;
        emit ValidatorRemoved(validatorType);
    }

    /**
     * @notice Enable or disable a validator
     * @param validatorType The type of validator
     * @param enabled Whether to enable the validator
     */
    function setValidatorEnabled(
        bytes32 validatorType,
        bool enabled
    ) external virtual onlyAuthorized {
        if (validators[validatorType] == address(0))
            revert Errors.ValidatorNotEnabled();
        enabledValidators[validatorType] = enabled;
        emit ValidatorEnabled(validatorType, enabled);
    }

    /**
     * @notice Set authorization for an account
     * @param account The account to authorize
     * @param isAuthorized Whether the account is authorized
     */
    function setAuthorized(
        address account,
        bool isAuthorized
    ) external virtual onlyAuthorized {
        authorized[account] = isAuthorized;
        emit Authorized(account, isAuthorized);
    }

    /**
     * @notice Validate a signature using enabled validators
     * @param hash Hash of the data that was signed
     * @param signature Signature to validate
     * @return True if the signature is valid
     */
    function validateSignature(
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool) {
        for (uint256 i = 0; i < signature.length; i += 65) {
            bytes32 validatorType = bytes32(signature[i:i + 32]);

            if (!enabledValidators[validatorType]) continue;

            address validator = validators[validatorType];
            if (validator == address(0)) continue;

            bytes memory validatorSignature = signature[i + 32:i + 97];

            try
                IValidator(validator).validateSignature(
                    hash,
                    validatorSignature
                )
            returns (bool isValid) {
                if (isValid) return true;
            } catch {
                continue;
            }
        }

        return false;
    }

    /**
     * @notice Check if a validator is enabled
     * @param validatorType The type of validator
     * @return True if the validator is enabled
     */
    function isValidatorEnabled(
        bytes32 validatorType
    ) internal view returns (bool) {
        return
            enabledValidators[validatorType] &&
            validators[validatorType] != address(0);
    }
}
