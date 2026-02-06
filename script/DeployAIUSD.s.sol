// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {AIUSD} from "../src/AIUSD.sol";

contract DeployAIUSD is Script {
    function run() external returns (address) {
        // ────────────────────────────────────────────────────────────────
        // Load environment variables
        // ────────────────────────────────────────────────────────────────
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // You can also read RPC and API key here if needed, but we pass them via CLI flags

        // Optional: read initial supply from env (fallback to 0 = no premint)
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", uint256(0));
        // Example: export INITIAL_SUPPLY=1000000000000000000000000  (1M tokens)

        // ────────────────────────────────────────────────────────────────
        // Start broadcast
        // ────────────────────────────────────────────────────────────────
        vm.startBroadcast(deployerPrivateKey);

        AIUSD token = new AIUSD(initialSupply);

        vm.stopBroadcast();

        // ────────────────────────────────────────────────────────────────
        // Logging
        // ────────────────────────────────────────────────────────────────
        console.log("AIUSD deployed at ..........: %s", address(token));
        console.log("Deployer / Admin / Pauser ...: %s", msg.sender);
        console.log("Initial supply (tokens) ......: %s", initialSupply / 1e18);

        return address(token);
    }
}