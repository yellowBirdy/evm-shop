// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IShop} from "./IShop.sol";
import {Order, Product, OrderStatus} from "./Order.sol";

contract Shop is IShop, Ownable2Step{

    error Unauthorized(address sender);
    error UnknownProduct(uint256 id);
    error InsufficientPayment(uint256 required, uint256 payed);
    error ZeroQuantity();


    event OrderCreated(
        address indexed buyer, 
        uint256 indexed productId, 
        uint256 amountPayed, 
        uint256 orderId
    );

    event OrderUpdated(uint256 indexed orderId, OrderStatus fromStatus, OrderStatus indexed toStatus);


    Order[] private orders;
    mapping(address => uint256[]) customerOrders;
    Product[] public products;

    // MODIFIERS
    // @dev moved input validators accessing storage inline to save gas on redundant storage reads

    /**
    * @dev validates existence of of product id
    * @param id requested product id
    */
    modifier productExists(uint256 id) {
        if (!_productExists(id)) revert UnknownProduct(id);
        _;
    }

    //@dev provisonaly hardcoded product examples
    constructor() {
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

    /**
    * @dev allows any user to place an order 
    * @param productId id of the order product
    * @param quantity amount of units of the product orders
    * @param pricePayed total amount of currency payed by the user 
    * @return id orderId of the newly created order
    */
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

        emit OrderCreated(msg.sender, productId, pricePayed, id);
    }

    /**
    * @dev access controled getter for order data, only usable by creator and admin
    * @param id unique id of the order 
    * @return order found Order structure
    */
    function getOrder(uint256 id) external view returns(Order memory order) {
        order = orders[id];
        if (!isAdminOrBuyer(order.buyer)) revert Unauthorized(msg.sender);
    }
    /**
    * @dev access controled setter for order status
    * @notice will revert if called by unauthorized account
    * @notice will revert if invalid status update requested
    * @param id  id of the order 
    * @param newStatus desired value of the status
    */
    function updateOrder(uint256 id, OrderStatus newStatus) external {
        Order storage order = orders[id];
        if (!isAdminOrBuyer(order.buyer)) revert Unauthorized(msg.sender);
        // BUYER CAN ONLY CANCEL
        if (msg.sender == order.buyer && newStatus != OrderStatus.cancelled) revert Unauthorized(msg.sender);
        OrderStatus oldStatus = order.status;
        order.update(newStatus);
        emit OrderUpdated(id, oldStatus, newStatus);
    }

  
    // HELPERS

    /**
    * @dev validtes if message sender is the admin or passed buyer
    * @param buyer address of buyer to compare with 
    * @return boolean true if msg.sender is one of the addresses
    */
    function isAdminOrBuyer(address buyer) internal view returns(bool) {
        return msg.sender == owner() || msg.sender == buyer;
    }

    /**
    * @dev validtes if product with passed id exsits
    * @param id id in question
    * @return boolean true if product with passed id exists
    */    
    function _productExists(uint256 id) public view returns(bool) {
        return id < products.length;
    }
    /**
    * @dev cheks if amount payed is equal or bigger than required
    * @notice will revert if insufficent amount passed
    * @param unitPrice price of a unit quantity
    * @param quantity how many products have been ordered
    * @param pricePayed amount payed by the customer
    */  
    function assertPayedEnough(uint256 unitPrice, uint80 quantity, uint256 pricePayed) internal pure {
        if (pricePayed < unitPrice * quantity) 
            revert InsufficientPayment(unitPrice * quantity, pricePayed);
    }

}
