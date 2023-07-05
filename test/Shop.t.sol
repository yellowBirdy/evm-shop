// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Shop.sol";
import {OrderStatus} from "../src/Order.sol";

contract ShopTest is Test {
    Shop public shop;

    function setUp() public {
        shop = new Shop();
    }

    function testSmoke() public {
        assertTrue(true);
    }

    function testUpdateNonexistingOrderFails() public {
        vm.expectRevert(stdError.indexOOBError);
        shop.updateOrder(78, OrderStatus.fullfiled);
    }

}
