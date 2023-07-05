// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Order, OrderStatus} from "./Order.sol";

interface IShop {

    function placeOrder(uint256 productId, uint80 quantity, uint256 pricePayed) external returns(uint256 id);
    function getOrder(uint256 id) external view returns(Order memory order);
    function updateOrder(uint256 id, OrderStatus newStatus) external;

}