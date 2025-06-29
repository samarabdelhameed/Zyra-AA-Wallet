// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {SignatureDecoder} from "../libraries/SignatureDecoder.sol";
import {ValidationHandler} from "./ValidationHandler.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IZyra} from "../interfaces/IZyra.sol";

/**
 * @title ERC1271Handler
 * @notice Contract which provides ERC1271 signature validation (Zyra architecture)
 */
abstract contract ERC1271Handler is
    ValidationHandler,
    IERC1271,
    EIP712("Zyra1271", "1.0.0")
{
    struct ZyraMessage {
        bytes32 signedHash;
    }

    bytes32 constant _ZYRA_MESSAGE_TYPEHASH =
        keccak256("ZyraMessage(bytes32 signedHash)");
    bytes4 private constant _ERC1271_MAGIC = 0x1626ba7e;

    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param signedHash bytes32                   - Hash of the data that is signed
     * @param signatureAndValidator bytes calldata - Validator address concatenated to signature
     * @return magicValue bytes4 - Magic value if the signature is valid, 0 otherwise
     */
    function isValidSignature(
        bytes32 signedHash,
        bytes calldata signatureAndValidator
    )
        public
        view
        virtual
        override(IERC1271, IZyra)
        returns (bytes4 magicValue)
    {
        (bytes memory signature, address validator) = SignatureDecoder
            .decodeSignatureNoHookData(signatureAndValidator);

        bytes32 eip712Hash = _hashTypedDataV4(
            _zyraMessageHash(ZyraMessage(signedHash))
        );
        bool valid = _handleValidation(validator, eip712Hash, signature);
        magicValue = valid ? _ERC1271_MAGIC : bytes4(0);
    }

    /**
     * @notice Returns the EIP-712 hash of the Zyra message
     * @param zyraMessage ZyraMessage calldata - The message containing signedHash
     * @return bytes32 - EIP712 hash of the message
     */
    function getEip712Hash(
        ZyraMessage calldata zyraMessage
    ) external view returns (bytes32) {
        return _hashTypedDataV4(_zyraMessageHash(zyraMessage));
    }

    /**
     * @notice Returns the typehash for the Zyra message struct
     * @return bytes32 - Zyra message typehash
     */
    function zyraMessageTypeHash() external pure returns (bytes32) {
        return _ZYRA_MESSAGE_TYPEHASH;
    }

    function _zyraMessageHash(
        ZyraMessage memory zyraMessage
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(_ZYRA_MESSAGE_TYPEHASH, zyraMessage.signedHash)
            );
    }
}
