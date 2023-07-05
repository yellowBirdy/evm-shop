// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Shop.sol";
import {Order, OrderStatus, Product} from "../src/Order.sol";

contract ShopTest is Test {
    Shop public shop;

    address internal customer = address(0x0007);
    address internal otherCustomer = address(0x00078);

    function setUp() public {
        shop = new Shop();
    }

    function testSmoke() public {
        assertTrue(true);
    }

    function testCreateOrder() public {
        uint256 productId = 0;
        uint80 productQty = 3;
        uint256 pricePayed = 75 ether;
        vm.prank(customer);
        uint256 orderId = shop.placeOrder(productId, productQty, pricePayed);
        assertEq(orderId, 0);
        (string memory expectedName, string memory expectedCategory, uint256 exppectedUnitPrice) = shop.products(productId);
        Order memory expectedOrder = Order(
            Product(expectedName, expectedCategory, exppectedUnitPrice),
            customer,
            productQty,
            OrderStatus.placed,
            pricePayed
        );
        assertEq(abi.encode(expectedOrder), abi.encode(shop.getOrder(orderId)));
    }
            // UNHAPPY PATHS
    function testCreateOrderNonexistignProductFail(uint256 productId) public {
        productId = bound(productId, 2, 1000);
        vm.expectRevert(abi.encodeWithSelector(Shop.UnknownProduct.selector, productId));
        vm.prank(customer);
        shop.placeOrder(productId,10, 1000);
    }

    function testCreateOrderUnderpaidFail(uint256 pricePayed) public {
        uint256 productId = 1;
        uint80 quantity = 111;
        (,, uint256 unitPrice) = shop.products(productId);
        uint256 expectedPrice = quantity * unitPrice;
        pricePayed = bound(pricePayed, 0, expectedPrice - 1);
        vm.expectRevert(abi.encodeWithSelector(Shop.InsufficientPayment.selector, expectedPrice, pricePayed));
        vm.prank(customer);
        shop.placeOrder(productId, quantity, pricePayed);
    }

// ORDER AUTHORIZATION TESTS
    function testGetOrderAuthorisation() public {
        vm.prank(customer);
        uint256 id = shop.placeOrder(0, 3, 75 ether);
        // get by adming
        shop.getOrder(id);      
        // get by customer
        vm.prank(customer);
        shop.getOrder(id);
        // can't get by other customer
        vm.expectRevert(abi.encodeWithSelector(Shop.Unauthorized.selector, otherCustomer));
        vm.prank(otherCustomer);
        shop.getOrder(id);
    }

 




    function testUpdateNonexistingOrderFails() public {
        vm.expectRevert(stdError.indexOOBError);
        shop.updateOrder(78, OrderStatus.fullfiled);
    }

}
