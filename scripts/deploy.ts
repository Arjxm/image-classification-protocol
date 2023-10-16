import { ethers, run } from "hardhat";


async function main() {
  const coreFunctions = await ethers.deployContract("CoreFunctions");
  await coreFunctions.waitForDeployment();
  console.log("coreFunctions", await coreFunctions.getAddress());
  await run("verify:verify", {
    address: await coreFunctions.getAddress(),
    constructorArguments: [],
  });

  const coreFunctionsHelper = await ethers.deployContract("CoreFunctionHelper", [coreFunctions.getAddress()]);
  await coreFunctionsHelper.waitForDeployment();
  console.log("coreFunctionsHelper", await coreFunctionsHelper.getAddress());
  await run("verify:verify", {
    address: await coreFunctionsHelper.getAddress(),
    constructorArguments: [coreFunctions.getAddress()],
  });

  const main = await ethers.deployContract("Main", [coreFunctionsHelper.getAddress()]);
  await main.waitForDeployment();
  console.log(`main ${main.target}`);
  await run("verify:verify", {
    address: await main.getAddress(),
    constructorArguments: [coreFunctionsHelper.getAddress()],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
