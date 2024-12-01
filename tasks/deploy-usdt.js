const { task } = require("hardhat/config")

task("deploy-usdt", "deploy and verify fake usdt contract").setAction(async(taskArgs, hre) => {
    // create factory 
    const usdtFactory = await ethers.getContractFactory("USDT")
    console.log("contract deploying")
    // deploy contract from factory
    const usdt = await usdtFactory.deploy(1000000000000000)
    await usdt.waitForDeployment()
    console.log(`contract has been deployed successfully, contract address is ${usdt.target}`);
    console.log(`chainId is ${hre.network.config.chainId}`)
    // verify usdt
    if(hre.network.config.chainId == 11155111 && process.env.ETHERSCAN_API_KEY) {
        console.log("Waiting for 5 confirmations")
        await usdt.deploymentTransaction().wait(5)  // 等待5个区块确认
        await verifyUSDT(usdt.target, [1000000000000000])
    } else {
        console.log("verification skipped..")
    }
} )

async function verifyUSDT(usdtAddr, args) {
    await hre.run("verify:verify", {
        address: usdtAddr,
        constructorArguments: args,
      });
}

module.exports = {}