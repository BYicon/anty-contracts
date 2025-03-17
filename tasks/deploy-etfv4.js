const { task } = require("hardhat/config");

task("deploy-etfv4", "deploy and verify ETFv4 contract").setAction(
  async (_, hre) => {
    // MockWBTC (WBTC): 0x567B31515f4159ca962168f324E3eB4BC7A815af
    // MockWrappedETH (WETH): 0xBea1F36b96C21D0cB3890a43Fd23a3aaF5d1a623
    // MockLINK (LINK): 0x72D8f66C0De729548257e3F534c0595c49f0Dc2B
    // MockAUD (AUD): 0x731547Af3879aa3892A0a36BE718a639000a0335
    // MockUSDC (USDC): 0x8700bb76B942616118BfEd1f1970f0aE60C850Ec
    const name = "AntyETFv4"
    const symbol = "ANTYETFv4"

    const tokens = [
      "0x567B31515f4159ca962168f324E3eB4BC7A815af",
      "0xBea1F36b96C21D0cB3890a43Fd23a3aaF5d1a623",
      "0x72D8f66C0De729548257e3F534c0595c49f0Dc2B",
      "0x731547Af3879aa3892A0a36BE718a639000a0335",
      // "0x8700bb76B942616118BfEd1f1970f0aE60C850Ec",
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
    const minMintAmount = ethers.parseUnits("1", 18);
    
    // ETFv4需要的额外参数
    const swapRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // Uniswap V2 Router地址
    const weth = "0xBea1F36b96C21D0cB3890a43Fd23a3aaF5d1a623"; // WETH地址
    const etfQuoter = "0x1234567890123456789012345678901234567890"; // ETF报价器地址，需要替换为实际地址
    const miningToken = "0x8700bb76B942616118BfEd1f1970f0aE60C850Ec"; // 挖矿代币地址，这里使用USDC作为示例
    
    // 创建工厂
    const etfFactory = await ethers.getContractFactory("ETFv4");
    console.log("ETFv4合约部署中...");
    
    // 部署ETFv4
    const etf = await etfFactory.deploy(
      name,
      symbol,
      tokens,
      initTokenAmountPerShares,
      minMintAmount,
      swapRouter,
      weth,
      etfQuoter,
      miningToken
    );
    
    await etf.waitForDeployment();
    console.log(
      `contract deployed, address: ${etf.target}`
    );
    console.log(`chainId: ${hre.network.config.chainId}`);
    
    // 验证合约
    if (
      hre.network.config.chainId == 11155111 &&
      process.env.ETHERSCAN_API_KEY
    ) {
      console.log("waiting for 5 blocks");
      await etf.deploymentTransaction().wait(5);
      await verifyETFv4(etf.target, [
        name,
        symbol,
        tokens,
        initTokenAmountPerShares,
        minMintAmount,
        swapRouter,
        weth,
        etfQuoter,
        miningToken
      ]);
    } else {
      console.log("跳过验证...");
    }
  }
);

async function verifyETFv4(etfAddr, args) {
  await hre.run("verify:verify", {
    address: etfAddr,
    constructorArguments: args,
  });
}

module.exports = {}; 