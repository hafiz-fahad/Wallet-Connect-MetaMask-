const hre = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment...\n");

  // Get deployer
  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 Deploying contracts with account:", deployer.address);
  console.log("💰 Account balance:", (await deployer.provider.getBalance(deployer.address)).toString(), "\n");

  // Deploy SimpleNFT contract
  console.log("📦 Deploying SimpleNFT contract...");
  const SimpleNFT = await hre.ethers.getContractFactory("SimpleNFT");
  const nft = await SimpleNFT.deploy();
  await nft.waitForDeployment();
  const nftAddress = await nft.getAddress();
  console.log("✅ SimpleNFT deployed to:", nftAddress);

  // Deploy NFTAuction contract
  console.log("\n📦 Deploying NFTAuction contract...");
  const NFTAuction = await hre.ethers.getContractFactory("NFTAuction");
  const auction = await NFTAuction.deploy();
  await auction.waitForDeployment();
  const auctionAddress = await auction.getAddress();
  console.log("✅ NFTAuction deployed to:", auctionAddress);

  // Mint some test NFTs
  console.log("\n🎨 Minting test NFTs...");
  const mintTx = await nft.batchMint(deployer.address, 3);
  await mintTx.wait();
  console.log("✅ Minted 3 test NFTs to deployer");

  // Display summary
  console.log("\n" + "=".repeat(60));
  console.log("📋 DEPLOYMENT SUMMARY");
  console.log("=".repeat(60));
  console.log("SimpleNFT Contract:", nftAddress);
  console.log("NFTAuction Contract:", auctionAddress);
  console.log("Network:", hre.network.name);
  console.log("Chain ID:", hre.network.config.chainId);
  console.log("Deployer:", deployer.address);
  console.log("=".repeat(60));

  console.log("\n📝 Next steps:");
  console.log("1. Update lib/services/auction_service.dart with these addresses:");
  console.log(`   auctionContractAddress = '${auctionAddress}';`);
  console.log(`   nftContractAddress = '${nftAddress}';`);
  console.log("\n2. To verify contracts on explorer:");
  console.log(`   npx hardhat verify --network ${hre.network.name} ${auctionAddress}`);
  console.log(`   npx hardhat verify --network ${hre.network.name} ${nftAddress}`);
  
  // Save deployment info to file
  const fs = require("fs");
  const deploymentInfo = {
    network: hre.network.name,
    chainId: hre.network.config.chainId,
    nftContract: nftAddress,
    auctionContract: auctionAddress,
    deployer: deployer.address,
    timestamp: new Date().toISOString()
  };
  
  fs.writeFileSync(
    `deployment-${hre.network.name}.json`,
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log(`\n💾 Deployment info saved to deployment-${hre.network.name}.json`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

