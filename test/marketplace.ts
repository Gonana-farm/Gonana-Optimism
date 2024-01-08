import { ethers } from 'hardhat';
import { Contract, Signer } from 'ethers';
import { expect } from 'chai';

describe('Marketplace Contract', function () {
  let marketplace: Contract;
  let owner: Signer;
  let seller: Signer;
  let buyer: Signer;

  beforeEach(async () => {
    [owner, seller, buyer] = await ethers.getSigners();

    const Marketplace = await ethers.getContractFactory('Marketplace');
    marketplace = await Marketplace.connect(owner).deploy();
    await marketplace.deployed();
  });

  it('Should create a product', async function () {
    const productID = '1';
    const amount = ethers.parseEther('1');
    const merchantID = 'seller1';

    await marketplace.connect(seller).createProduct(productID, amount, merchantID);

    const product = await marketplace.products(productID);
    expect(product.wallet).to.equal(await seller.getAddress());
    expect(product.amount).to.equal(amount);
  });

  it('Should list and unlist a product', async function () {
    const productID = '1';
    const amount = ethers.parseEther('1');
    const hash = 'QmHash';

    await marketplace.connect(seller).createProduct(productID, amount, 'seller1');
    await marketplace.connect(seller).listProduct(productID, hash);

    let product = await marketplace.products(productID);
    expect(product.state).to.equal(0); // Listed

    await marketplace.connect(seller).unlistProduct(productID);
    product = await marketplace.products(productID);
    expect(product.state).to.equal(3); // Cancelled
  });

  it('Should order and confirm a product', async function () {
    const productID = '1';
    const amount = ethers.parseEther('1');
    const buyerID = 'buyer1';

    await marketplace.connect(seller).createProduct(productID, amount, 'seller1');
    await marketplace.connect(seller).listProduct(productID, 'QmHash');

    await marketplace.connect(buyer).orderProduct(productID, amount, buyerID);

    let product = await marketplace.products(productID);
    expect(product.state).to.equal(1); // Escrowed

    await marketplace.connect(seller).confirmOrder(productID);
    product = await marketplace.products(productID);
    expect(product.state).to.equal(2); // Confirmed
  });

  // More tests for other functionalities

});
