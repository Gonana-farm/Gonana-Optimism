// // scripts/deploy.ts
// import { ethers } from "hardhat";

// async function main() {
//   const [deployer] = await ethers.getSigners();
//   console.log("Deploying contracts with the account:", deployer.address);

//   const Marketplace = await ethers.getContractFactory("Marketplace");
  
//   const marketplace = await Marketplace.deploy();
//   await marketplace.deployed();

//   console.log("Marketplace contract deployed to:", marketplace.address);
// }

// // Run the deployment script using ts-node
// main()
//   .then(() => process.exit(0))
//   .catch((error) => {
//     console.error(error);
//     process.exit(1);
//   });
