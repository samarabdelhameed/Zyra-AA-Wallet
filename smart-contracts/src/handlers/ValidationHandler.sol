// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SignatureDecoder} from "../libraries/SignatureDecoder.sol";
import {BytesLinkedList} from "../libraries/LinkedList.sol";
import {OwnerManager} from "../managers/OwnerManager.sol";
import {ValidatorManager} from "../managers/ValidatorManager.sol";
import {IK1Validator, IR1Validator} from "../interfaces/IValidator.sol";

/**
 * @title ValidationHandler
 * @notice Contract which calls validators for signature validation (Zyra architecture)
 */
abstract contract ValidationHandler is OwnerManager, ValidatorManager {
    function _handleValidation(
        address validator,
        bytes32 signedHash,
        bytes memory signature
    ) internal view returns (bool) {
        if (_r1IsValidator(validator)) {
            mapping(bytes => bytes) storage owners = OwnerManager
                ._r1OwnersLinkedList();
            bytes memory cursor = owners[BytesLinkedList.SENTINEL_BYTES];
            while (cursor.length > BytesLinkedList.SENTINEL_LENGTH) {
                bytes32[2] memory pubKey = abi.decode(cursor, (bytes32[2]));

                bool _success = IR1Validator(validator).validateSignature(
                    signedHash,
                    signature,
                    pubKey
                );

                if (_success) {
                    return true;
                }

                cursor = owners[cursor];
            }
        } else if (_k1IsValidator(validator)) {
            address recoveredAddress = IK1Validator(validator)
                .validateSignature(signedHash, signature);

            if (recoveredAddress == address(0)) {
                return false;
            }

            if (OwnerManager._k1IsOwner(recoveredAddress)) {
                return true;
            }
        }

        return false;
    }
}
