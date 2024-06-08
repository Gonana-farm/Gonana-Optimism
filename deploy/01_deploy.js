const {ethers, network} = require("hardhat");
const{verify} = require("../utils/verify.js")
const{developmentChains} = require("../helper-hh-config.js")


module.exports = async ({deployments, getNamedAccounts})=>{
    const {deploy,log} = deployments;
    const {deployer} = await getNamedAccounts();
    log("----------------------------------------------------")
    const args = []
    console.log("deployer: ", deployer)
    const contract = await deploy("Marketplace",{
        from : deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if(!developmentChains.includes(network.name)){
        log("Verifying...")
        await verify(contract.address, args);
    }


    


}