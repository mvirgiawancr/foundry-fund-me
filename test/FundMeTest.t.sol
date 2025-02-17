// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address public constant USER = address(1);
    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testMinimumDollarIsOne() public view {
        assertEq(fundMe.minimumUSD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFail() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        uint256 amountFunded = fundMe.getAddressToFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        assertEq(fundMe.getFunders(0), USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.startPrank(USER);
        vm.expectRevert();
        fundMe.withdraw();
        vm.stopPrank();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingBalanceOwner = fundMe.getOwner().balance;
        uint256 startingBalanceFundMe = address(fundMe).balance;
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // Assert
        uint256 endingBalanceOwner = fundMe.getOwner().balance;
        uint256 endingBalanceFundMe = address(fundMe).balance;
        assertEq(
            endingBalanceOwner,
            startingBalanceOwner + startingBalanceFundMe
        );
        assertEq(endingBalanceFundMe, 0);
        assert(address(fundMe).balance == 0);
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;
        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingBalanceOwner = fundMe.getOwner().balance;
        uint256 startingBalanceFundMe = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingBalanceOwner = fundMe.getOwner().balance;
        uint256 endingBalanceFundMe = address(fundMe).balance;
        assert(address(fundMe).balance == 0);
        assertEq(
            endingBalanceOwner,
            startingBalanceOwner + startingBalanceFundMe
        );
        assertEq(endingBalanceFundMe, 0);
    }
}
