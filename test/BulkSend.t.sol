// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {BulkSend} from "../src/BulkSend.sol";
import {DeployBulkSend} from "../script/DeployBulkSend.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract TestBulkSend is StdCheats, Test {
    BulkSend bulksend;
    address CREATOR;
    address USER1 = address(1);
    address USER2 = address(2);
    address USER3 = address(3);

    address USER4 = address(4);

    address[] recipient_Addressess = [USER1, USER2, USER3, USER4];
    uint256[] recipient_Amount = [1 ether, 2 ether, 3 ether, 4 ether];
    address[] recipient_Address = [USER1];

    function setUp() public {
        CREATOR = msg.sender;
        bulksend = new DeployBulkSend().run();
    }

    modifier Set_Token_Send_Fee_One_ETH() {
        vm.startPrank(CREATOR);
        bulksend.setToken_Send_Fee(1 ether);
        _;
    }

    modifier Set_Eth_Send_Fee_One_ETH() {
        vm.startPrank(CREATOR);
        bulksend.setETH_Send_Fee(1 ether);
        vm.stopPrank();
        _;
    }

    function test_Set_Eth_Send_Fee() public Set_Eth_Send_Fee_One_ETH {
        assertEq(bulksend.ethSendFee(), 1 ether);
        console.log(bulksend.ethSendFee());
    }

    function test_Set_Token_Send_Fee() public Set_Token_Send_Fee_One_ETH {
        assertEq(bulksend.tokenSendFee(), 1 ether);
        console.log(bulksend.tokenSendFee());
    }

    function test_BulkSendEth() public Set_Eth_Send_Fee_One_ETH {
        vm.deal(CREATOR, 20 ether);
        uint256 previousBalance = CREATOR.balance;
        vm.prank(CREATOR);
        console.log(msg.sender.balance);
        bool sent = bulksend.bulkSendEth{value: 15 ether}(
            recipient_Addressess,
            recipient_Amount
        );
        assertEq(sent, true);
        // checks if balance of address sent to was updated
        // 1 ether was sent to USER1
        assertEq(USER1.balance, 1 ether);
        // 2 ether was sent to USER2
        assertEq(USER2.balance, 2 ether);
        // 3 ether was sent to USER3
        assertEq(USER3.balance, 3 ether);
        // 4 ether was sent to USER4
        assertEq(USER4.balance, 4 ether);
        // Total of 10 ether was sent + Send fee to 4 address make 4 ether
        // Cost of Transaction 14 ether
        assertEq(CREATOR.balance, previousBalance - 14 ether);
        // checks if fee for transaction was deducted and added to contract balance
        assertEq(
            address(bulksend).balance,
            recipient_Addressess.length * bulksend.ethSendFee()
        );
    }

    function test_AddressAmount_Mismatch() public {
        vm.prank(CREATOR);
        vm.expectRevert("Number of addresses do not match amounts");
        bulksend.bulkSendEth{value: 10 ether}(
            recipient_Address,
            recipient_Amount
        );
    }

    function test_Not_Enough_ETH_Sent() public {
        vm.prank(CREATOR);
        vm.expectRevert("Not enough eth sent");
        bulksend.bulkSendEth(recipient_Addressess, recipient_Amount);
    }
}
