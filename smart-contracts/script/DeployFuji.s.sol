// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/validators/ZyraImplementation.sol";
import "../src/validators/ZyraProxy.sol";
import "../src/validators/ZyraRegistry.sol";
import "../src/validators/AccountFactory.sol";

/**
 * @title DeployFuji
 * @notice Deployment script for Avalanche Fuji testnet
 * @dev Deploys Zyra wallet contracts to Fuji
 */
contract DeployFuji is Script {
    address constant FUJI_ENTRYPOINT =
        0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying to Avalanche Fuji testnet...");
        console.log("Deployer:", deployer);
        console.log("EntryPoint:", FUJI_ENTRYPOINT);

        // Deploy implementation
        ZyraImplementation implementation = new ZyraImplementation();
        console.log("ZyraImplementation deployed at:", address(implementation));

        // Deploy proxy
        ZyraProxy proxy = new ZyraProxy(address(implementation), deployer);
        console.log("ZyraProxy deployed at:", address(proxy));

        // Deploy registry
        ZyraRegistry registry = new ZyraRegistry(
            address(implementation),
            deployer
        );
        console.log("ZyraRegistry deployed at:", address(registry));

        // Deploy factory
        AccountFactory factory = new AccountFactory(
            address(implementation),
            deployer
        );
        console.log("AccountFactory deployed at:", address(factory));

        vm.stopBroadcast();

        console.log("\nFuji deployment completed!");
        console.log("\nContract addresses:");
        console.log("Implementation:", address(implementation));
        console.log("Proxy:", address(proxy));
        console.log("Registry:", address(registry));
        console.log("Factory:", address(factory));
    }
}
