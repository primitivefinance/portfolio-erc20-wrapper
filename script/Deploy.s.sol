// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import "../src/WrapperFactory.sol";

contract DeployScript is Script {
    function run(address portfolio) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address factory = address(new WrapperFactory(portfolio));
        console.log("WrapperFactory:", factory);

        vm.stopBroadcast();
    }
}
