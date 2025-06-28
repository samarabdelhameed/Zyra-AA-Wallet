// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "../libraries/Errors.sol";

/**
 * @title SignatureDecoder
 * @notice Library for decoding and validating signatures
 * @dev Supports ECDSA and other signature types
 */
library SignatureDecoder {
    struct SignatureData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes signature;
    }

    /**
     * @notice Decode ECDSA signature
     * @param signature The signature to decode
     * @return v Recovery byte
     * @return r R component
     * @return s S component
     */
    function decodeSignature(
        bytes memory signature
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }

    /**
     * @notice Recover signer address from signature
     * @param hash Hash that was signed
     * @param signature The signature
     * @return signer The recovered signer address
     */
    function recoverSigner(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address signer) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) v += 27;
        require(v == 27 || v == 28, "Invalid signature 'v' value");

        signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "Invalid signature");
    }

    /**
     * @notice Split signature into components
     * @param signature The signature to split
     * @return SignatureData struct with components
     */
    function splitSignature(
        bytes memory signature
    ) internal pure returns (SignatureData memory) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        return SignatureData({v: v, r: r, s: s, signature: signature});
    }

    // Decode transaction.signature into signature, validator and hook data
    function decodeTransactionSignature(
        bytes calldata txSignature
    )
        internal
        pure
        returns (
            bytes memory signature,
            address validator,
            bytes[] memory hookData
        )
    {
        (signature, validator, hookData) = abi.decode(
            txSignature,
            (bytes, address, bytes[])
        );
    }

    // Decode signature into signature and validator
    function decodeSignatureNoHookData(
        bytes calldata signatureAndValidator
    ) internal pure returns (bytes memory signature, address validator) {
        (signature, validator) = abi.decode(
            signatureAndValidator,
            (bytes, address)
        );
    }
}
