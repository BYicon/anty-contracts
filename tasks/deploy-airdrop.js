const { task } = require("hardhat/config")

task("deploy-airdrop", "deploy and verify SignatureDrop contract")
.addParam("addr", "erc20 contract address")
.setAction(async(taskArgs, hre) => {
    console.log("taskArgs", taskArgs)
    // create factory 
    const airdropFactory = await ethers.getContractFactory("SignatureDrop")
    console.log("contract deploying")
    const airdrop = await airdropFactory.deploy(taskArgs.addr)
    await airdrop.waitForDeployment()
    console.log(`🟢🟢🟢 airdrop contract has been deployed successfully, contract address is ${airdrop.target}`);
    console.log(`🟢🟢🟢 chainId is ${hre.network.config.chainId}`)
    // verify nft contract
    if(hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY) {
        console.log("Waiting for 5 confirmations")
        await airdrop.deploymentTransaction().wait(5)  // 等待5个区块确认
        await verifyAirdrop(airdrop.target, [taskArgs.addr])
    } else {
        console.log("verification skipped..")
    }
} )

async function verifyAirdrop(airdropAddr, args) {
    await hre.run("verify:verify", {
        address: airdropAddr,
        constructorArguments: args,
      });
}

module.exports = {}