// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {BulkSend} from "../src/BulkSend.sol";

contract DeployBulkSend is Script {
    function run() external returns (BulkSend) {
        vm.startBroadcast();
        BulkSend bulksend = new BulkSend();
        vm.stopBroadcast();
        return bulksend;
    }
}
