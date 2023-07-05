// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {IShop} from "./IShop.sol";
import {Order, Product, OrderStatus} from "./Order.sol";

contract Shop is IShop {

    error Unauthorized(address sender);


    // TODO: add events
    // TODO: add natspec


    address public owner;
    Order[] private orders;
    mapping(address => uint256[]) customerOrders;

    // MODIFIERS
    // @notice calling input validators inline to save gas on redundant storage reads

    // EXTERNAL
    function placeOrder(uint256 productId, uint80 quantity, uint256 pricePayed) external returns(uint256 id) {
        //TODO
    }
    function getOrder(uint256 id) external view returns(Order memory) {
        return orders[id];
    }
    function updateOrder(uint256 id, OrderStatus newStatus) external {
        Order memory order = orders[id];
        if (!isAdminOrBuyer(order.buyer)) revert Unauthorized(msg.sender);

        order.update(newStatus);
    }

    // INTERNALS

  
    // HELPERS

    function isAdminOrBuyer(address creator) internal view returns(bool) {
        return msg.sender == owner || msg.sender == creator;
    }

    

}
