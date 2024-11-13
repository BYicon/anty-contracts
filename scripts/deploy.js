// const hre = require("hardhat");

// async function main() {
//   const MirrorNFT = await hre.ethers.getContractFactory("NFTMIR");
//   const mirrorNFT = await MirrorNFT.deploy();
//   console.log('mirrorNFT 🚀🚀🚀', mirrorNFT);
//   await mirrorNFT.deployed();

//   console.log("CONTRACT_ADDRESS 🚀🚀🚀", mirrorNFT.address);
// }

// //npx hardhat run scripts/deploy.js --network polygon_amoy
// //npx hardhat run scripts/deploy.js --network localhost

// main().catch((error) => {
//   console.error('error 🔴🔴🔴', error);
//   process.exitCode = 1;
// });

// scripts/deploy.js

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const NFTMIR = await ethers.getContractFactory("NFTMIR");
  const nftmir = await NFTMIR.deploy(deployer.address);

  console.log("NFTMIR contract deployed to:", nftmir.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
