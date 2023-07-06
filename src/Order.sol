// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

using OrderLib for Order global;


error InvalidTransition(OrderStatus from, OrderStatus to);


enum OrderStatus {
    placed,
    processing,
    fullfilled,
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

    function update(Order storage order, OrderStatus newStatus) internal  onlyValidTransition(order.status, newStatus) {
        order.status = newStatus;
    }

}


function isTransitionValid(OrderStatus from, OrderStatus to) pure returns(bool) {
    if (from == OrderStatus.placed) {
        // placed -> processing || cancelled || invalid
        if (to == OrderStatus.processing || to == OrderStatus.cancelled || to == OrderStatus.invalid)
            return true;
    }
    if (from == OrderStatus.processing) {
        // processing -> fullfilled || failed
        if (to == OrderStatus.fullfilled || to == OrderStatus.failed)
            return true;
    }
    return false;
}

