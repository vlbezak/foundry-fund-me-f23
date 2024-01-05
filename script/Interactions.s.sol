//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.0001 ether;

    function fundFundMe(address _address) public {
        console.log("FundFundMe address:%s", address(this));
        console.log("FundFundMe called: fundMe:%s sender:%s balance:%s", _address,  msg.sender, address(msg.sender).balance);
        //vm.startBroadcast();
        FundMe(payable(_address)).getFunder(0);
        FundMe(payable(_address)).fund{value: SEND_VALUE}();
        //vm.stopBroadcast();
        console.log("FundMe funded with %s ETH", SEND_VALUE);
    }

    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployment) public {
        console.log("WithdrawFundMe called:%s %s", msg.sender, address(msg.sender).balance);
        FundMe(payable(mostRecentDeployment)).withdraw();
        console.log("FundMe withdrawn");
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        //vm.startBroadcast();
        withdrawFundMe(contractAddress);
        //vm.stopBroadcast();
    }
}
