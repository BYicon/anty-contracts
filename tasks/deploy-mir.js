const { task } = require("hardhat/config");

task("deploy-mir", "deploy and verify MirrorToken contract").setAction(
  async (taskArgs, hre) => {
    // const sender = await ethers.getSigners();
    // console.log("sender 🚀🚀🚀", sender);
    // create factory
    const mirFactory = await ethers.getContractFactory("MIR");
    console.log("contract deploying");
    // deploy
    const mir = await mirFactory.deploy(1000000000000000);
    await mir.waitForDeployment();
    console.log(
      `contract has been deployed successfully, contract address is ${mir.target}`
    );
    // verify
    if (
      hre.network.config.chainId == 11155111 &&
      process.env.ETHERSCAN_API_KEY
    ) {
      console.log("Waiting for 5 confirmations");
      await mir.deploymentTransaction().wait(5); // 等待5个区块确认
      await verifyMIR(mir.target, [1000000000000000]);
    } else {
      console.log("verification skipped..");
    }
  }
);

async function verifyMIR(mirAddr, args) {
  await hre.run("verify:verify", {
    address: mirAddr,
    constructorArguments: args,
  });
}

module.exports = {};
