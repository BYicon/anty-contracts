const hre = require("hardhat");

async function main() {
  const MirrorCoin = await hre.ethers.getContractFactory("MirrorCoin");
  console.log('MirrorCoin 🚀🚀🚀', MirrorCoin);
  const mirrorCoin = await MirrorCoin.deploy();

  await mirrorCoin.deployed();

  console.log("CONTRACT_ADDRESS 🚀🚀🚀", create.address);
}

//npx hardhat run scripts/deploy.js --network polygon_amoy
//npx hardhat run scripts/deploy.js --network localhost

main().catch((error) => {
  console.error('error 🔴🔴🔴', error);
  process.exitCode = 1;
});
