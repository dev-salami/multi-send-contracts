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

   
}
