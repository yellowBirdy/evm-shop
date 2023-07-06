// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Shop.sol";
import {Order, OrderStatus, Product, InvalidTransition} from "../src/Order.sol";

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

    function testCreateOrder0QuantityFail() public {
        uint256 productId = 1;
        uint80 quantity = 0;
        vm.expectRevert(Shop.ZeroQuantity.selector);
        vm.prank(customer);
        shop.placeOrder(productId, quantity, 0);
    }

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
    function testUpdateOrderBuyer() public {
        vm.startPrank(customer);
        uint256 id = shop.placeOrder(0, 3, 75 ether);
        
        shop.updateOrder(id, OrderStatus.cancelled); 

        Order memory order = shop.getOrder(id);  

        assertEq(uint8(order.status), uint8(OrderStatus.cancelled));   
    }

    function testUpdateOrderBuyerFail() public {
        vm.startPrank(customer);
        uint256 id = shop.placeOrder(0, 3, 75 ether);
        
        vm.expectRevert(abi.encodeWithSelector(Shop.Unauthorized.selector, customer));
        shop.updateOrder(id, OrderStatus.placed);  
        vm.expectRevert(abi.encodeWithSelector(Shop.Unauthorized.selector, customer));
        shop.updateOrder(id, OrderStatus.processing);  
        vm.expectRevert(abi.encodeWithSelector(Shop.Unauthorized.selector, customer));
        shop.updateOrder(id, OrderStatus.fullfilled);  
        vm.expectRevert(abi.encodeWithSelector(Shop.Unauthorized.selector, customer));
        shop.updateOrder(id, OrderStatus.failed);   
        vm.expectRevert(abi.encodeWithSelector(Shop.Unauthorized.selector, customer));
        shop.updateOrder(id, OrderStatus.invalid);          
    }


    function testUpdateOrderFullfilledAdmin() public {
        vm.prank(customer);
        uint256 id = shop.placeOrder(0, 3, 75 ether);

        shop.updateOrder(id, OrderStatus.processing); 
        assertEq(uint8(shop.getOrder(id).status), uint8(OrderStatus.processing));
        shop.updateOrder(id, OrderStatus.fullfilled); 
        assertEq(uint8(shop.getOrder(id).status), uint8(OrderStatus.fullfilled));

    }
    function testUpdateOrderFailedAdmin() public {
        vm.prank(customer);
        uint256 id = shop.placeOrder(0, 3, 75 ether);

        shop.updateOrder(id, OrderStatus.processing); 
        assertEq(uint8(shop.getOrder(id).status), uint8(OrderStatus.processing));
        shop.updateOrder(id, OrderStatus.failed); 
        assertEq(uint8(shop.getOrder(id).status), uint8(OrderStatus.failed));

    }
    function testUpdateOrderInvalidCancelledAdmin() public {
        vm.prank(customer);
        uint256 id0 = shop.placeOrder(0, 3, 75 ether);

        shop.updateOrder(id0, OrderStatus.invalid); 
        assertEq(uint8(shop.getOrder(id0).status), uint8(OrderStatus.invalid));

        vm.prank(customer);
        uint256 id1 = shop.placeOrder(0, 3, 75 ether);

        shop.updateOrder(id1, OrderStatus.cancelled); 
        assertEq(uint8(shop.getOrder(id1).status), uint8(OrderStatus.cancelled));
    }

    function testUpdateOrderAdminFail() public {
        vm.prank(customer);
        uint256 id = shop.placeOrder(0, 3, 75 ether);

        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.placed, OrderStatus.fullfilled));
        shop.updateOrder(id, OrderStatus.fullfilled); 


        shop.updateOrder(id, OrderStatus.processing); 

        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.processing, OrderStatus.placed));
        shop.updateOrder(id, OrderStatus.placed); 
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.processing, OrderStatus.cancelled));
        shop.updateOrder(id, OrderStatus.cancelled);     
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.processing, OrderStatus.invalid));
        shop.updateOrder(id, OrderStatus.invalid);      

        shop.updateOrder(id, OrderStatus.fullfilled); 

        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.fullfilled, OrderStatus.processing));
        shop.updateOrder(id, OrderStatus.processing); 
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.fullfilled, OrderStatus.cancelled));
        shop.updateOrder(id, OrderStatus.cancelled);     
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.fullfilled, OrderStatus.invalid));
        shop.updateOrder(id, OrderStatus.invalid);   
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.fullfilled, OrderStatus.placed));
        shop.updateOrder(id, OrderStatus.placed);
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.fullfilled, OrderStatus.failed));
        shop.updateOrder(id, OrderStatus.failed);    

        vm.prank(customer);
        uint256 id1 = shop.placeOrder(0, 3, 75 ether);
        shop.updateOrder(id1, OrderStatus.processing); 
        shop.updateOrder(id1, OrderStatus.failed); 

        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.failed, OrderStatus.processing));
        shop.updateOrder(id1, OrderStatus.processing); 
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.failed, OrderStatus.cancelled));
        shop.updateOrder(id1, OrderStatus.cancelled);     
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.failed, OrderStatus.invalid));
        shop.updateOrder(id1, OrderStatus.invalid);   
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.failed, OrderStatus.placed));
        shop.updateOrder(id1, OrderStatus.placed);
        vm.expectRevert(abi.encodeWithSelector(InvalidTransition.selector, OrderStatus.failed, OrderStatus.fullfilled));
        shop.updateOrder(id1, OrderStatus.fullfilled);     
    }
 

    function testUpdateNonexistingOrderFails() public {
        vm.expectRevert(stdError.indexOOBError);
        shop.updateOrder(78, OrderStatus.fullfilled);
    }

}
