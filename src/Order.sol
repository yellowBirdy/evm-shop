// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

using OrderLib for Order global;


error InvalidTransition(OrderStatus from, OrderStatus to);

// @dev enum listing possible values of order status
enum OrderStatus {
    placed,
    processing,
    fullfilled,
    failed,
    cancelled,
    invalid
}

// @dev provisionaly describes a product
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
}

library OrderLib {
    /**
    * @dev modifier validating correctness of requested OrderStatus transition
    * @param from initial status
    * @param to requested final status
    */
    modifier onlyValidTransition(OrderStatus from, OrderStatus to) {
        if (!isTransitionValid(from, to)) revert InvalidTransition(from, to);
        _;
    }

    /**
     * @notice will only allow for valid changes defined in isTransitionValid
     * @notice operates on storage orders only 
     * @dev changes status of an order
     * @param order reference to the storage order to be modified
     * @param newStatus requested final status
     */
    function update(Order storage order, OrderStatus newStatus) internal  onlyValidTransition(order.status, newStatus) {
        order.status = newStatus;
    }

}

/**
* @dev defines valid order status changes 
    * @param from initial status
    * @param to requested final status
* @return boolean representing validity of requested change
*/
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

