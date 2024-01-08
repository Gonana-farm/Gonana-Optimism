// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {
    enum ProductState { Listed, Escrowed, Confirmed, Cancelled }

    struct Product {
        string productID;
        uint256 amount;
        address payable seller;
        ProductState state;
    }

    struct Order {
        string productID;
        uint256 amount;
        address payable buyer;
        bool paid;
    }

    mapping(string => Product) public products;
    mapping(string => Order) public orders;

    event ProductListed(string productID, uint256 amount, address seller);
    event OrderPlaced(string productID, uint256 amount, address buyer);
    event OrderConfirmed(string productID, address buyer);

    modifier onlySeller(string memory _productID) {
        require(products[_productID].seller == msg.sender, "Only the seller can call this function");
        _;
    }

    modifier onlyBuyer(string memory _productID) {
        require(orders[_productID].buyer == msg.sender, "Only the buyer can call this function");
        _;
    }

    // function createProduct(string memory _productID, uint256 _amount) external {
    //     require(products[_productID].seller == address(0), "Product already exists");
    //     products[_productID] = Product(_productID, _amount, payable(msg.sender), ProductState.Listed);
    // }

    // function listProduct(string memory _productID) external onlySeller(_productID) {
    //     require(products[_productID].state == ProductState.Listed, "Product is not listed");
    //     products[_productID].state = ProductState.Escrowed;
    //     emit ProductListed(_productID, products[_productID].amount, msg.sender);
    // }

    // function orderProduct(string memory _productID) external payable {
    //     require(products[_productID].state == ProductState.Escrowed, "Product not available");
    //     require(msg.value == products[_productID].amount, "Incorrect amount sent");
    //     require(!orders[_productID].paid, "Order already placed");

    //     orders[_productID] = Order(_productID, msg.value, payable(msg.sender), true);
    //     products[_productID].seller.transfer(msg.value); // Send amount to the seller
    //     emit OrderPlaced(_productID, msg.value, msg.sender);
    // }

    // function confirmOrder(string memory _productID) external onlySeller(_productID) {
    //     require(products[_productID].state == ProductState.Escrowed, "Product not in escrow");
    //     require(orders[_productID].paid, "No order placed");

    //     products[_productID].state = ProductState.Confirmed;
    //     emit OrderConfirmed(_productID, orders[_productID].buyer);
    // }

    // function cancelOrder(string memory _productID) external onlyBuyer(_productID) {
    //     require(products[_productID].state == ProductState.Escrowed, "Product not in escrow");
    //     require(orders[_productID].paid, "No order placed");

    //     payable(msg.sender).transfer(orders[_productID].amount); // Refund the buyer
    //     delete orders[_productID];
    //     products[_productID].state = ProductState.Cancelled;
    // }
}