// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Marketplace {
    enum ProductState { Listed, Escrowed, Confirmed, Cancelled }

    struct Product {
        string productID;
        uint256 amount;
        address wallet;
        string hash;
        string merchantID;
        ProductState state;
    }

    struct Order {
        string productID;
        uint256 amount;
        address buyerAddress;
        string buyerID;
        // bool paid;
    }

    mapping(string => Product) public products;
    mapping(string => Order) public orders;

    event ProductCreated(string productID, uint256 amount, address indexed seller);
    // event ProductListed(string productID, uint256 amount, address seller);
    event ProductListed(string productID, uint256 amount);
    event ProductUnlisted(string productID);
    event OrderPlaced(string productID, uint256 amount, address buyer);
    event OrderConfirmed(string productID, address buyer);

    modifier onlySeller(string memory _productID) {
        require(products[_productID].wallet == msg.sender, "Only the seller can call this function");
        _;
    }

    modifier onlyBuyer(string memory _productID) {
        require(orders[_productID].buyerAddress == msg.sender, "Only the buyer can call this function");
        _;
    }

    function createProduct(
        string memory _productID, 
        uint256 _amount,
        string memory _merchantID
    ) external {
        require(products[_productID].wallet == address(0), "Product already exists");
        products[_productID] = Product(_productID, _amount, payable(msg.sender), "", _merchantID, ProductState.Listed);
    }

    function listProduct(string memory _productID, string memory _hash) external onlySeller(_productID) {
        require(products[_productID].state == ProductState.Listed, "Product cannot be relisted");
        products[_productID].hash = _hash;
        products[_productID].state = ProductState.Listed;
        // emit ProductListed(_productID, products[_productID].amount, msg.sender);
        emit ProductListed(_productID, products[_productID].amount);
    }

    function unlistProduct(string memory _productID) external onlySeller(_productID) {
        require(products[_productID].state == ProductState.Listed, "Product is not listed");
        products[_productID].state = ProductState.Cancelled;
        emit ProductUnlisted(_productID);
    }

    // function orderProduct(string memory _productID) external payable {
    //     require(products[_productID].state == ProductState.Escrowed, "Product not available");
    //     require(msg.value == products[_productID].amount, "Incorrect amount sent");
    //     require(!orders[_productID].paid, "Order already placed");

    //     orders[_productID] = Order(_productID, msg.value, payable(msg.sender), true);
    //     products[_productID].seller.transfer(msg.value); // Send amount to the seller
    //     emit OrderPlaced(_productID, msg.value, msg.sender);
    // }

    function orderProduct(
        string memory _productID,
        uint256 _amount,
        string memory _buyerID
    ) external payable {
        require(products[_productID].state == ProductState.Listed, "Product not available");
        // ensure the value inputed is same as the product amount listed
        require(products[_productID].amount == _amount, "Incorrect amount");
        // ensure the value sent is the amount listed
        require(msg.value == _amount, "Insufficient funds/Incorrect amount");

        orders[_productID] = Order(_productID, _amount, msg.sender, _buyerID);
        products[_productID].state = ProductState.Escrowed;

        // escrow logic to hold funds until confirmed 
        //(transfer funds from the buyer to escrow account)

        emit OrderPlaced(_productID, _amount, msg.sender);
    } 

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