// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title TokenCallbackHandler
/// @notice Minimal handler for ERC777/ERC1363 token callbacks (for Account Abstraction wallets)
contract TokenCallbackHandler {
    function tokensReceived(
        address /*operator*/,
        address /*from*/,
        address /*to*/,
        uint256 /*amount*/,
        bytes calldata /*userData*/,
        bytes calldata /*operatorData*/
    ) external pure {}

    function onTransferReceived(
        address /*operator*/,
        address /*from*/,
        uint256 /*amount*/,
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        return this.onTransferReceived.selector;
    }

    function onApprovalReceived(
        address /*owner*/,
        uint256 /*amount*/,
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        return this.onApprovalReceived.selector;
    }
}
