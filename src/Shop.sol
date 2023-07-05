// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {IShop} from "./IShop.sol";
import {Order, Product, OrderStatus} from "./Order.sol";

contract Shop is IShop {

    error Unauthorized(address sender);
    error UnknownProduct(uint256 id);
    error InsufficientPayment(uint256 required, uint256 payed);
    error ZeroQuantity();




    // TODO: add events
    // TODO: add natspec
    uint256 public constant priceMantisa = 1e18;

// use ownable 2 step
    address public owner;
    Order[] private orders;
    mapping(address => uint256[]) customerOrders;
    Product[] public products;

    // MODIFIERS
    // @notice calling input validators inline to save gas on redundant storage reads
    modifier productExists(uint256 id) {
        if (!_productExists(id)) revert UnknownProduct(id);
        _;
    }

    constructor() {
        owner = msg.sender;
        products.push( Product(
            "Mastering Ethereum", 
            "book", 
            25 ether
        ));
        products.push( Product(
            "The Police: Greatest Hits", 
            "music album", 
            10 ether
        ));
    }


    // EXTERNAL
    function placeOrder(uint256 productId, uint80 quantity, uint256 pricePayed) 
        external 
        productExists(productId)
        returns(uint256 id) 
    {
        if (quantity == 0) revert ZeroQuantity();
        Product memory product = products[productId];
        assertPayedEnough(product.price, quantity, pricePayed);  

        id = orders.length;
        orders.push(Order (
            product,
            msg.sender,
            quantity,
            OrderStatus.placed,
            pricePayed
        ));

    }
    function getOrder(uint256 id) external view returns(Order memory order) {
        order = orders[id];
        if (!isAdminOrBuyer(order.buyer)) revert Unauthorized(msg.sender);
    }
    function updateOrder(uint256 id, OrderStatus newStatus) external {
        Order storage order = orders[id];
        if (!isAdminOrBuyer(order.buyer)) revert Unauthorized(msg.sender);

        order.update(newStatus);
    }

    // INTERNALS

  
    // HELPERS

    function isAdminOrBuyer(address creator) internal view returns(bool) {
        return msg.sender == owner || msg.sender == creator;
    }
    
    function _productExists(uint256 id) public view returns(bool) {
        return id < products.length;
    }

    function assertPayedEnough(uint256 unitPrice, uint80 quantity, uint256 pricePayed) internal pure {
        if (pricePayed < unitPrice * quantity) 
            revert InsufficientPayment(unitPrice * quantity, pricePayed);
    }

}
