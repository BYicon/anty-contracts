const { task, run } = require("hardhat/config");

task("deploy-anty", "deploy and verify AntyToken contract").setAction(
  async (taskArgs, hre) => {
    // create factory
    const mirFactory = await ethers.getContractFactory("Anty");
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
  await run("verify:verify", {
    address: mirAddr,
    constructorArguments: args,
  });
}

module.exports = {};
