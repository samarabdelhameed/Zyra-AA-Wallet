// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {TokenCallbackHandler} from "./helpers/TokenCallbackHandler.sol";
import {IAccount} from "account-abstraction/interfaces/IAccount.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";

import {OwnerManager} from "./managers/OwnerManager.sol";
import {ModuleManager} from "./managers/ModuleManager.sol";
import {HookManager} from "./managers/HookManager.sol";
import {UpgradeManager} from "./managers/UpgradeManager.sol";

import {Errors} from "./libraries/Errors.sol";
import {SignatureDecoder} from "./libraries/SignatureDecoder.sol";

import {ERC1271Handler} from "./handlers/ERC1271Handler.sol";
import {IZyra} from "./interfaces/IZyra.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";

/**
 * @title Main account contract for the Zyra wallet infrastructure
 */
// Initializable,
contract ZyraImplementation is
    IAccount,
    IZyra,
    OwnerManager,
    ModuleManager,
    HookManager,
    UpgradeManager,
    ERC1271Handler,
    TokenCallbackHandler
{
    uint256 internal constant SIG_OK = 0;
    uint256 internal constant SIG_FAILED = 1;

    IEntryPoint private immutable _ENTRYPOINT;
    bool private _initialized;

    constructor(IEntryPoint entryPoint_) {
        _ENTRYPOINT = entryPoint_;
        // _disableInitializers();
    }

    /**
     * @notice Initializer function for the account contract
     * @param initialR1Owner bytes calldata - The initial r1 owner of the account
     * @param initialR1Validator address    - The initial r1 validator of the account
     * @param modules bytes[] calldata      - The list of modules to enable for the account
     */
    function initialize(
        bytes calldata initialR1Owner,
        address initialR1Validator,
        bytes[] calldata modules
    ) external {
        _r1AddOwner(initialR1Owner);
        _r1AddValidator(initialR1Validator);

        for (uint256 i = 0; i < modules.length; ) {
            _addModule(modules[i]);
            unchecked {
                i++;
            }
        }
    }

    function init(bytes calldata initData) external {
        // Example: decode and call initialize
        // (bytes memory owner, address validator, bytes[] memory modules) = abi.decode(initData, (bytes, address, bytes[]));
        // initialize(owner, validator, modules);
    }

    // Receive function to allow ETHs
    receive() external payable {}

    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external override(IAccount, IZyra) returns (uint256 validationData) {
        validationData = _validateUserOp(userOp, userOpHash);
        _payPrefund(missingAccountFunds);
    }

    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) external override returns (bool success) {
        _execute(target, value, data);
        return true;
    }

    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external override returns (bool success) {
        require(
            targets.length == datas.length && targets.length == values.length,
            "wrong array lengths"
        );
        for (uint256 i = 0; i < targets.length; i++) {
            _execute(targets[i], values[i], datas[i]);
        }
        return true;
    }

    function addDeposit() external payable {
        IEntryPoint(address(_ENTRYPOINT)).depositTo{value: msg.value}(
            address(this)
        );
    }

    function withdrawDepositTo(
        address payable withdrawAddress,
        uint256 amount
    ) external onlyEntrypoint {
        IEntryPoint(address(_ENTRYPOINT)).withdrawTo(withdrawAddress, amount);
    }

    function getDeposit() external view returns (uint256) {
        return IEntryPoint(address(_ENTRYPOINT)).balanceOf(address(this));
    }

    function entryPoint() external view override returns (address) {
        return address(_ENTRYPOINT);
    }

    function entrypoint() public view override returns (IEntryPoint) {
        return _ENTRYPOINT;
    }

    function getNonce() public view returns (uint256) {
        return IEntryPoint(address(_ENTRYPOINT)).getNonce(address(this), 0);
    }

    function _validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash
    ) internal returns (uint256 validationData) {
        // Extract the signature, validator address and hook data from the userOp.signature
        (
            bytes memory signature,
            address validator,
            bytes[] memory hookData
        ) = SignatureDecoder.decodeTransactionSignature(userOp.signature);

        // Run validation hooks
        bool hookSuccess = runValidationHooks(userOpHash, userOp, hookData);

        if (!hookSuccess) {
            return SIG_FAILED;
        }

        bool valid = _handleValidation(validator, userOpHash, signature);

        validationData = valid ? SIG_OK : SIG_FAILED;
    }

    function _execute(
        address to,
        uint256 value,
        bytes calldata data
    ) internal runExecutionHooks(to, value, data) {
        (bool success, bytes memory result) = to.call{value: value}(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success, ) = payable(msg.sender).call{
                value: missingAccountFunds,
                gas: type(uint256).max
            }("");
            (success);
            //ignore failure (its EntryPoint's job to verify, not account.)
        }
    }

    function nonce() external view override returns (uint256) {
        return IEntryPoint(address(_ENTRYPOINT)).getNonce(address(this), 0);
    }

    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    ) public view override(ERC1271Handler, IZyra) returns (bytes4 magicValue) {
        revert("Not implemented");
    }

    function resetOwners(
        bytes calldata pubKey
    ) public override(IZyra, OwnerManager) {
        revert("Not implemented");
    }

    function isModule(
        address addr
    ) public view override(IZyra, ModuleManager) returns (bool) {
        revert("Not implemented");
    }

    function isHook(
        address addr
    ) public view override(IZyra, HookManager) returns (bool) {
        revert("Not implemented");
    }

    function _isHook(address addr) internal view override returns (bool) {
        revert("Not implemented");
    }

    function initialized() public view returns (bool) {
        return _initialized;
    }
}
