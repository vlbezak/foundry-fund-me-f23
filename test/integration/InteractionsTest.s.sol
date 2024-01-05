// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import { StdCheats} from "forge-std/StdCheats.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is StdCheats, Test {
    FundMe fundMe;

    address USER_ADDRESS = makeAddr("user");
    uint256 constant SEND_ETHER = 0.1 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    address constant USER = address(1);

    function setUp() external {
        console.log("setUp:", msg.sender);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, START_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.prank(USER);
        vm.deal(USER, START_BALANCE);
        vm.startPrank(USER);
        fundFundMe.fundFundMe(address(fundMe));
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER_ADDRESS);
    }
}
