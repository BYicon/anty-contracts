import { HardhatRuntimeEnvironment } from "hardhat/types";

async function deployMirToken({getNamedAccounts, deployments}: HardhatRuntimeEnvironment) {
    const owner = (await getNamedAccounts()).owner369;
    console.log("owner 🚀🚀🚀" , owner);

    // TODO: Deploy the MIR token
};

export default deployMirToken;