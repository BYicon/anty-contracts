async function deployMirToken({getNamedAccounts, deployments}: HardhatRuntimeEnvironment) {
    const owner = (await getNamedAccounts()).owner369;
    console.log("owner 🚀🚀🚀" , owner);
};

export default deployMirToken;