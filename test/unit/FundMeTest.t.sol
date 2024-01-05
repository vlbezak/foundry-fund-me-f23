// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER_ADDRESS = makeAddr("user");
    uint256 constant SEND_ETHER = 0.1 ether;
    uint256 constant START_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        console.log("setUp:", msg.sender);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        deal(USER_ADDRESS, START_BALANCE);
    }

    function test_MinimumDollarsIsFive() public {
        //console.log("Test Demo");
        //console.log(fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function test_OwnerIsMsgSender() public {
        //console.log("this address", address(this));
        //console.log("ownerTest:", msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_PriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log("version:", version);
        assertEq(version, 4);
    }

    function testFundsFailWhenNotEnoughDollars() public {
        vm.expectRevert();
        fundMe.fund{value: 1}();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        //vm.startPrank(USER_ADDRESS);
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER_ADDRESS);
        console.log("amountFunded:", amountFunded);
        assertEq(amountFunded, SEND_ETHER);
    }

    function testAddsFunnderToArrayOfFunders() public funded {
        //vm.startPrank(USER_ADDRESS);
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER_ADDRESS);
    }

    function testNonOwnerCannotWithdraw() public funded {
        //vm.startPrank(USER_ADDRESS);
        vm.expectRevert();
        fundMe.withdraw();
    }

    modifier funded() {
        vm.startPrank(USER_ADDRESS);
        fundMe.fund{value: SEND_ETHER}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // Arange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        console.log("startingOwnerBalance:", startingOwnerBalance);
        console.log("startingContractBalance:", startingContractBalance);

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;

        console.log("endingContractBalance:", endingContractBalance);
        console.log("endingOwnerBalance:", endingOwnerBalance);

        assertEq(endingOwnerBalance, startingOwnerBalance + startingContractBalance);
        assertEq(endingContractBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            startHoax(address(i));
            //vm.hoax(address(i), SEND_ETHER);
            fundMe.fund{value: SEND_ETHER}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        console.log("startingOwnerBalance:", startingOwnerBalance);
        console.log("startingContractBalance:", startingContractBalance);

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint256 gasConsumed = gasStart - gasleft();
        console.log("gasConsumed:", gasConsumed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;

        console.log("endingContractBalance:", endingContractBalance);
        console.log("endingOwnerBalance:", endingOwnerBalance);

        assertEq(endingOwnerBalance, startingOwnerBalance + startingContractBalance);
        assertEq(endingContractBalance, 0);
    }

    function testCheaperWithdrawFromMultipleFunders() public funded {
        // Arange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            startHoax(address(i));
            //vm.hoax(address(i), SEND_ETHER);
            fundMe.fund{value: SEND_ETHER}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        console.log("startingOwnerBalance:", startingOwnerBalance);
        console.log("startingContractBalance:", startingContractBalance);

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        uint256 gasConsumed = gasStart - gasleft();
        console.log("gasConsumed:", gasConsumed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;

        console.log("endingContractBalance:", endingContractBalance);
        console.log("endingOwnerBalance:", endingOwnerBalance);

        assertEq(endingOwnerBalance, startingOwnerBalance + startingContractBalance);
        assertEq(endingContractBalance, 0);
    }
}
