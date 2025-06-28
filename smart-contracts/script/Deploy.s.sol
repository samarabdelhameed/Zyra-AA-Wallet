// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/validators/ZyraImplementation.sol";
import "../src/validators/ZyraProxy.sol";
import "../src/validators/ZyraRegistry.sol";
import "../src/validators/AccountFactory.sol";
import "../src/validators/EOAValidator.sol";

/**
 * @title Deploy
 * @notice Main deployment script for Zyra wallet contracts
 * @dev Deploys all core contracts and sets up initial configuration
 */
contract Deploy is Script {
    // EntryPoint addresses for different networks
    address constant SEPOLIA_ENTRYPOINT =
        0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    address constant FUJI_ENTRYPOINT =
        0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    address constant MUMBAI_ENTRYPOINT =
        0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        console.log("Deploying Zyra wallet contracts...");
        console.log("Deployer:", deployer);

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

        // Deploy validators
        EOAValidator eoaValidator = new EOAValidator();
        console.log("EOAValidator deployed at:", address(eoaValidator));

        vm.stopBroadcast();

        console.log("\nDeployment completed successfully!");
        console.log("\nContract addresses:");
        console.log("Implementation:", address(implementation));
        console.log("Proxy:", address(proxy));
        console.log("Registry:", address(registry));
        console.log("Factory:", address(factory));
        console.log("EOAValidator:", address(eoaValidator));
    }
}
