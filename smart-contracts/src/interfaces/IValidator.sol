// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title IValidator
 * @notice Interface for signature validation in the Zyra wallet
 * @dev Validators handle different types of signature verification
 */
interface IValidator {
    /**
     * @notice Validate a signature
     * @param hash Hash of the data that was signed
     * @param signature Signature to validate
     * @return True if the signature is valid
     */
    function validateSignature(
        bytes32 hash,
        bytes calldata signature
    ) external view returns (bool);

    /**
     * @notice Get the validator type
     * @return The validator type identifier
     */
    function getValidatorType() external view returns (bytes32);

    /**
     * @notice Check if the validator is enabled
     * @return True if the validator is enabled
     */
    function isEnabled() external view returns (bool);
}

/**
 * @title secp256r1 ec keys' signature validator interface
 * @author https://getclave.io
 */
interface IR1Validator is IERC165 {
    /**
     * @notice Allows to validate secp256r1 ec signatures
     * @param signedHash bytes32          - hash of the data that is signed by the key
     * @param signature bytes             - signature
     * @param pubKey bytes32[2]           - public key coordinates array for the x and y values
     * @return valid bool                 - validation result
     */
    function validateSignature(
        bytes32 signedHash,
        bytes calldata signature,
        bytes32[2] calldata pubKey
    ) external view returns (bool valid);
}

/**
 * @title secp256k1 ec keys' signature validator interface
 * @author https://getclave.io
 */
interface IK1Validator is IERC165 {
    /**
     * @notice Allows to validate secp256k1 ec signatures
     * @param signedHash bytes32          - hash of the transaction signed by the key
     * @param signature bytes             - signature
     * @return signer address             - recovered signer address
     */
    function validateSignature(
        bytes32 signedHash,
        bytes calldata signature
    ) external view returns (address signer);
}
