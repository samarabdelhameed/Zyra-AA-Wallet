// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IValidator.sol";
import "../libraries/SignatureDecoder.sol";

/**
 * @title EOAValidator
 * @notice Validates EOA (Externally Owned Account) signatures
 * @dev Uses ECDSA for signature validation
 */
contract EOAValidator is IValidator {
    mapping(address => bool) public authorizedSigners;

    event SignerAuthorized(address indexed signer, bool authorized);

    modifier onlyAuthorized() {
        require(authorizedSigners[msg.sender], "Unauthorized");
        _;
    }

    /**
     * @notice Set authorization for a signer
     * @param signer The signer to authorize
     * @param authorized Whether the signer is authorized
     */
    function setSignerAuthorized(
        address signer,
        bool authorized
    ) external onlyAuthorized {
        authorizedSigners[signer] = authorized;
        emit SignerAuthorized(signer, authorized);
    }

    /**
     * @notice Validate an EOA signature
     * @param hash Hash of the data that was signed
     * @param signature Signature to validate
     * @return True if the signature is valid
     */
    function validateSignature(
        bytes32 hash,
        bytes calldata signature
    ) external view override returns (bool) {
        if (signature.length != 65) return false;

        address signer = SignatureDecoder.recoverSigner(hash, signature);
        return authorizedSigners[signer];
    }

    /**
     * @notice Get the validator type
     * @return The validator type identifier
     */
    function getValidatorType() external pure override returns (bytes32) {
        return keccak256("EOA_VALIDATOR");
    }

    /**
     * @notice Check if the validator is enabled
     * @return True if the validator is enabled
     */
    function isEnabled() external pure override returns (bool) {
        return true;
    }

    error NotEnabled();
}
