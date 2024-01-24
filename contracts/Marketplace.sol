// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {  Errors } from "./utils/Errors.sol";
import {IBlast} from "./utils/Iblast.sol";

contract Marketplace {

    address private owner;
    IBlast immutable blast = IBlast(0x4300000000000000000000000000000000000002);

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

    struct Redeem {
        address id;
        uint256 gas;
    }

    mapping(string => Product) public products;
    mapping(string => Order) public orders;
    mapping(address => uint256) public gasSpent;

    Redeem[] claims ;

    event ProductCreated(string productID, uint256 amount, address indexed seller);
    // event ProductListed(string productID, uint256 amount, address seller);
    event ProductListed(string productID, uint256 amount);
    event ProductUnlisted(string productID);
    event OrderPlaced(string productID, uint256 amount, address buyer);
    event OrderConfirmed(string productID, address buyer);
    event GasClaimed(uint256 indexed time, uint256 indexed amount);

   

    // modifier onlyProductState(string memory _productID, ProductState _requiredState) {
    //     require(products[_productID].state == _requiredState, InvalidProductState());
    //     _;
    // }

    //***** */ */

    constructor(){
        owner = msg.sender;
        IBlast(0x4300000000000000000000000000000000000002).configureClaimableGas();
        IBlast(0x4300000000000000000000000000000000000002).configureGovernor(owner);

    }

    modifier onlySeller(string memory _productID) {
        if (products[_productID].wallet == msg.sender){ 
            revert Errors.WrongSignature();
        }
        _;
    }

    modifier onlyBuyer(string memory _productID) {
        if(orders[_productID].buyerAddress == msg.sender){ 
            revert Errors.WrongSignature();
        }
        _;
    }

    modifier onlyOwner() {
        if(msg.sender != owner){
            revert Errors.NotOwner();
        }
        _;
    }


    function createProduct(
        string memory _productID, 
        uint256 _amount,
        string memory _merchantID,
        address creator
    ) external onlyOwner {
        if(products[_productID].wallet == address(0)){ revert Errors.ProductAlreadyExists();}
        products[_productID] = Product(_productID, _amount, payable(creator), "", _merchantID, ProductState.Listed);
        _listProduct(_productID,"");
    }

    function _listProduct(string memory _productID, string memory _hash) internal {
        //require(products[_productID].state == ProductState.Listed, InvalidProductState());
        products[_productID].hash = _hash;
        products[_productID].state = ProductState.Listed;
        // emit ProductListed(_productID, products[_productID].amount, msg.sender);
        emit ProductListed(_productID, products[_productID].amount);
    }

    function unlistProduct(string memory _productID) external onlyOwner {
        if(products[_productID].state == ProductState.Listed){ revert Errors.InvalidProductState();}
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
        //require(products[_productID], Errors.ProductNotFound());
        if(products[_productID].state == ProductState.Listed) {revert Errors.InvalidProductState();}
        // ensure the value inputed is same as the product amount listed
        if(products[_productID].amount == _amount){ revert Errors.InvalidPrice();}
        // ensure the value sent is the amount listed
        if(msg.value == _amount){ revert Errors.InsufficientFunds();}

        orders[_productID] = Order(_productID, _amount, msg.sender, _buyerID);
        products[_productID].state = ProductState.Escrowed;
        // escrow logic to hold funds until confirmed 
        //(transfer funds from the buyer to escrow account)
        gasSpent[msg.sender] = tx.gasprice;
        emit OrderPlaced(_productID, _amount, msg.sender);
        uint amount = claimAllGas();
        emit GasClaimed(block.timestamp, amount);
    } 

    function confirmOrder(string memory _productID) external onlyOwner {
        //require(orders[_productID], Errors.OrderNotFound());
        if(products[_productID].state == ProductState.Escrowed) {revert Errors.InvalidProductState();}
        //require(orders[_productID].paid, "No order placed");

        // logic to release funds in escrow account to seller

        products[_productID].state = ProductState.Confirmed;
        uint256 amount = products[_productID].amount;
        (bool success,) = products[_productID].wallet.call{value:amount}("");
        if (!success) {
            revert Errors.TransacationWasNotSuccessful();
        }
        emit OrderConfirmed(_productID, orders[_productID].buyerAddress);
    }

    function cancelOrder(string memory _productID) external onlyBuyer(_productID) {
        //require(orders[_productID],  Errors.OrderNotFound);
        if(products[_productID].state == ProductState.Escrowed) {revert Errors.InvalidProductState();}

        // ensure funds are in escrow account
        // require(orders[_productID].paid, "No order placed");

        // Refund the buyer from escrow account
        payable(msg.sender).transfer(orders[_productID].amount); 
        delete orders[_productID];
        products[_productID].state = ProductState.Cancelled;
    }

    function changeOwner(address _owner) public onlyOwner {
        assembly {
            sstore(0x00, _owner)
        }
    }

    function viewOrder(string memory _productID) external view returns (Order memory) {
        return orders[_productID];
    }

    function viewProduct(string memory _productID) external view returns (Product memory) {
        return products[_productID];
    }

    function claimAllGas() public returns(uint amount) {
	    // This function is public meaning anyone can claim the gas
		amount = blast.claimAllGas(address(this), address(this));

    }
    
    function redeemGas(address caller) external returns(bool sent) {
        if(gasSpent[caller] == 0 ){
            revert Errors.DoNotHaveGasSpent();
        }
        claimAllGas();
        uint256 amountDue = gasSpent[caller];
        gasSpent[caller] = 0;
        (sent,) = caller.call{value:amountDue}("");
        if (!sent){revert Errors.TransacationWasNotSuccessful();}

    }

    function checkGasDue()external view returns (uint amount){
        (,amount,,) = blast.readGasParams(address(this));
    }

}
