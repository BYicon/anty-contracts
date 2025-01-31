const { task } = require("hardhat/config");

task("deploy-etf", "deploy and verify ETF contract").setAction(
  async (_, hre) => {
    // MockWBTC (WBTC): 0x567B31515f4159ca962168f324E3eB4BC7A815af
    // MockWrappedETH (WETH): 0xBea1F36b96C21D0cB3890a43Fd23a3aaF5d1a623
    // MockLINK (LINK): 0x72D8f66C0De729548257e3F534c0595c49f0Dc2B
    // MockAUD (AUD): 0x731547Af3879aa3892A0a36BE718a639000a0335
    // MockUSDC (USDC): 0x8700bb76B942616118BfEd1f1970f0aE60C850Ec
    const name = "AntyETF"
    const symbol = "ANTYETF"

    const tokens = [
      "0x567B31515f4159ca962168f324E3eB4BC7A815af",
      "0xBea1F36b96C21D0cB3890a43Fd23a3aaF5d1a623",
      "0x72D8f66C0De729548257e3F534c0595c49f0Dc2B",
      "0x731547Af3879aa3892A0a36BE718a639000a0335",
      "0x8700bb76B942616118BfEd1f1970f0aE60C850Ec",
    ];

    // btc 100000, eth 3100, link 23, aud 0.6
    // weights: btc 40%, eth 30%, link 20%, aud 10%
    // 1 Share = 100U
    // btcAmountPerShare = 100 * 40% / 100000 * 1e8 = 4000
    // ethAmountPerShare = 100 * 30% / 3100 * 1e18 = 9677419354838710
    // linkAmountPerShare = 100 * 20% / 23 * 1e18 = 8695652173913043000
    // audAmountPerShare = 100 * 10% / 0.6 * 1e18 = 166666666666666668000

    const initTokenAmountPerShares = [
        "4000",
        "9677419354838710000",
        "8695652173913043000000",
        "166666666666666668000000"
    ].map(x => ethers.parseUnits(x, 0));
    const minMintAmount = ethers.parseUnits("1", 18)
    // create factory
    const etfFactory = await ethers.getContractFactory("ETFv1");
    console.log("contract deploying...");
    // deploy etf
    // string memory name_,
    // string memory symbol_,
    // address[] memory tokens_,
    // uint256[] memory initTokenAmountPerShares_,
    // uint256 minMintAmount_
    const etf = await etfFactory.deploy(
      name,
      symbol,
      tokens,
      initTokenAmountPerShares,
      minMintAmount
    );
    await etf.waitForDeployment();
    console.log(
      `contract has been deployed successfully, contract address is ${etf.target}`
    );
    console.log(`chainId is ${hre.network.config.chainId}`);
    // verify nft contract
    if (
      hre.network.config.chainId == 11155111 &&
      process.env.ETHERSCAN_API_KEY
    ) {
      console.log("Waiting for 5 confirmations");
      await etf.deploymentTransaction().wait(5); // 等待5个区块确认
      await verifyETF(etf.target, [
        name,
        symbol,
        tokens,
        initTokenAmountPerShares,
        minMintAmount
      ]);
    } else {
      console.log("verification skipped..");
    }
  }
);

async function verifyETF(etfAddr, args) {
  await hre.run("verify:verify", {
    address: etfAddr,
    constructorArguments: args,
  });
}

module.exports = {};
