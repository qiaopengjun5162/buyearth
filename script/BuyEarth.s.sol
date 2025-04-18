// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {BuyEarth} from "../src/BuyEarth.sol";

contract BuyEarthScript is Script {
    BuyEarth public buyEarth;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        buyEarth = new BuyEarth();
        console.log("BuyEarth deployed to:", address(buyEarth));

        vm.stopBroadcast();
    }
}
