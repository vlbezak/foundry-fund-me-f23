//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Not Real transaction
        HelperConfig helperConfig = new HelperConfig();
        (address priceFeed) = helperConfig.activeNetworkConfig();

        // After start tx -> Real TX
        vm.startBroadcast();

        FundMe fundMe = new FundMe(priceFeed);
        console.log("Deploying fundMe at address: %s", address(fundMe));
        vm.stopBroadcast();
        return fundMe;
    }
}

