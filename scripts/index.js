const {ethers} = require("hardhat")


async function main() {
  const [deployer] = await ethers.getSigners()

  console.log("Deploying contracts with the account:", deployer.address)

  console.log("Account balance:", (await deployer.getBalance()).toString())

  const marketplace = await ethers.getContractFactory("Marketplace")
  const market = await marketplace.deploy()
  await market.deployed()

  const contract = await ethers.getContractAt("Marketplace", market.address,deployer)

  const response = await contract.createProduct("1",10,"poppins",deployer.address)
  console.log(response)

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })