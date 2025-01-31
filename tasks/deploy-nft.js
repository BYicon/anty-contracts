const { task } = require("hardhat/config")

task("deploy-nft", "deploy and verify NFTMIR contract")
.addParam("addr", "erc20 contract address")
.setAction(async(taskArgs, hre) => {
    console.log("taskArgs", taskArgs)
    // create factory 
    const nftFactory = await ethers.getContractFactory("ANTYNFT")
    console.log("contract deploying")
    const nft = await nftFactory.deploy(taskArgs.addr)
    await nft.waitForDeployment()
    console.log(`contract has been deployed successfully, contract address is ${nft.target}`);
    console.log(`chainId is ${hre.network.config.chainId}`)
    // verify nft contract
    if(hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY) {
        console.log("Waiting for 5 confirmations")
        await nft.deploymentTransaction().wait(5)  // 等待5个区块确认
        await verifyNFT(nft.target, [taskArgs.addr])
    } else {
        console.log("verification skipped..")
    }
} )

async function verifyNFT(nftAddr, args) {
    await hre.run("verify:verify", {
        address: nftAddr,
        constructorArguments: args,
      });
}

module.exports = {}