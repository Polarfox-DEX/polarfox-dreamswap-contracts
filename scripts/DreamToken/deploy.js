async function main() {
  const DreamToken = await ethers.getContractFactory("DreamToken");
  // Start deployment, returning a promise that resolves to a contract object
  const dreamToken = await DreamToken.deploy();
  
  console.log("Contract deployed to address:", dreamToken.address);
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});