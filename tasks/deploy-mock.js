const { task } = require("hardhat/config");

task("deploy-mock", "deploy and verify multiple mock tokens")
  .setAction(async (taskArgs, hre) => {
    const tokens = [
      { name: "MockWBTC", symbol: "WBTC", decimals: 8 },
      { name: "MockWrappedETH", symbol: "WETH", decimals: 18 },
      { name: "MockLINK", symbol: "LINK", decimals: 18 },
      { name: "MockAUD", symbol: "AUD", decimals: 18 },
      { name: "MockUSDC", symbol: "USDC", decimals: 6 }
    ];

    const mockFactory = await ethers.getContractFactory("MockToken");
    const deployedTokens = [];

    for (const token of tokens) {
      console.log(`Deploying ${token.name}...`);
      const mockToken = await mockFactory.deploy(
        token.name,
        token.symbol,
        token.decimals
      );
      await mockToken.waitForDeployment();
      
      console.log(
        `${token.name} has been deployed successfully, contract address is ${mockToken.target}`
      );

      deployedTokens.push({
        ...token,
        address: mockToken.target,
      });

      // verify contract if on Sepolia testnet
      if (
        hre.network.config.chainId == 11155111 &&
        process.env.ETHERSCAN_API_KEY
      ) {
        console.log(`Waiting for 5 confirmations for ${token.name}`);
        await mockToken.deploymentTransaction().wait(5);
        await verifyMock(mockToken.target, [
          token.name,
          token.symbol,
          token.decimals,
        ]);
      }
    }

    console.log("\nDeployment Summary:");
    deployedTokens.forEach(token => {
      console.log(`${token.name} (${token.symbol}): ${token.address}`);
    });
  });

async function verifyMock(mockAddr, args) {
  await hre.run("verify:verify", {
    address: mockAddr,
    constructorArguments: args,
  });
}

module.exports = {};
