// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

using OrderLib for Order global;




error InvalidTransition(OrderStatus from, OrderStatus to);



enum OrderStatus {
    placed,
    processing,
    fullfiled,
    failed,
    cancelled,
    invalid
}

struct Product {
    string name;
    string category;
    uint256 price;
}

struct Order {
    Product prduct;
    address buyer;
    uint80 quantity;
    OrderStatus status;
    uint256 pricePayed;
    // deliveryType
    // ...
}

library OrderLib {

    modifier onlyValidTransition(OrderStatus oldStatus, OrderStatus newStatus) {
        if (!isTransitionValid(oldStatus, newStatus)) revert InvalidTransition(oldStatus, newStatus);
        _;
    }

    function update(Order memory order, OrderStatus newStatus) public onlyValidTransition(order.status, newStatus) {

    }

}


function isTransitionValid(OrderStatus from, OrderStatus to) pure returns(bool) {
    //TODO
    // placed -> processing
    // placed -> cancelled
    // placed -> invalid
    // processing -> fullfiled
    // processing -> failed

    return false;
}


    // placed,
    // processing,
    // fullfiled,
    // failed,
    // cancelled,
    // invalid