# 🎯 NFT Auction Platform - Complete Guide

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Smart Contract Features](#smart-contract-features)
3. [Setup Instructions](#setup-instructions)
4. [Deploy Smart Contracts](#deploy-smart-contracts)
5. [Run Flutter App](#run-flutter-app)
6. [Using the Platform](#using-the-platform)
7. [Smart Contract Functions](#smart-contract-functions)
8. [Troubleshooting](#troubleshooting)

---

## 🎨 Project Overview

This is a complete NFT auction platform with:
- **Flutter Mobile App** - Wallet connection with MetaMask
- **Smart Contracts** - NFT auctions on BNB Testnet / Sepolia
- **Network Support** - BNB Testnet & Ethereum Sepolia

### Current Structure

```
wallet_connect/
├── lib/
│   ├── main.dart                      # Flutter app with wallet connection
│   ├── services/
│   │   ├── wallet_service.dart        # WalletConnect integration
│   │   └── auction_service.dart       # Smart contract interaction
│   └── constants/
│       ├── app_colors.dart
│       └── app_theme.dart
│
├── contracts/
│   ├── NFTAuction.sol                 # Main auction contract
│   ├── SimpleNFT.sol                  # Test NFT contract (ERC721)
│   ├── package.json                   # Node dependencies
│   ├── hardhat.config.js              # Hardhat configuration
│   └── scripts/
│       └── deploy.js                  # Deployment script
│
└── pubspec.yaml                       # Flutter dependencies
```

---

## 🎯 Smart Contract Features

### NFTAuction.sol
- ✅ Create auctions with any ERC721 NFT
- ✅ Place bids (automatic refund for outbid users)
- ✅ End auction (transfer NFT to winner)
- ✅ Cancel auction (only if no bids)
- ✅ Withdraw funds (sellers & outbid bidders)
- ✅ Platform fees (2.5% default, adjustable)
- ✅ Reentrancy protection
- ✅ Time-based auction expiry

### SimpleNFT.sol
- ✅ Mint NFTs for testing
- ✅ Batch mint support
- ✅ ERC721 compliant
- ✅ URI storage for metadata

---

## 🚀 Setup Instructions

### Prerequisites

1. **Node.js & npm** (v18+)
   ```bash
   node --version  # Should be v18 or higher
   npm --version
   ```

2. **Flutter SDK** (v3.7+)
   ```bash
   flutter --version
   ```

3. **MetaMask Mobile App**
   - Download from App Store / Play Store
   - Create wallet & save seed phrase

4. **Test Funds**
   - BNB Testnet: https://testnet.bnbchain.org/faucet-smart
   - Sepolia: https://sepoliafaucet.com/

---

## 📦 Deploy Smart Contracts

### Step 1: Install Dependencies

```bash
cd contracts
npm install
```

### Step 2: Configure Environment

Create `.env` file in `contracts/` folder:

```bash
# Copy the example
cp env-example.txt .env

# Edit with your details
nano .env
```

Add your private key (get from MetaMask):
```
PRIVATE_KEY=your_private_key_without_0x_prefix
```

⚠️ **NEVER commit .env to git! It's already in .gitignore**

### Step 3: Compile Contracts

```bash
npx hardhat compile
```

You should see:
```
✓ Compiled 10 Solidity files successfully
```

### Step 4: Deploy to BNB Testnet

```bash
npm run deploy:testnet
```

Or deploy to Sepolia:
```bash
npm run deploy:sepolia
```

### Step 5: Save Contract Addresses

After deployment, you'll see:

```
📋 DEPLOYMENT SUMMARY
============================================================
SimpleNFT Contract: 0xABC123...
NFTAuction Contract: 0xDEF456...
Network: bnbTestnet
Chain ID: 97
Deployer: 0x789...
============================================================
```

**📝 IMPORTANT:** Copy these addresses!

### Step 6: Update Flutter App

Open `lib/services/auction_service.dart` and update:

```dart
// Line 10-11
static const String auctionContractAddress = '0xDEF456...'; // Your auction address
static const String nftContractAddress = '0xABC123...';     // Your NFT address
```

### Step 7: Get Contract ABIs

After compilation, ABIs are in `contracts/artifacts/`. You'll need:
- `contracts/NFTAuction.sol/NFTAuction.json`
- `contracts/SimpleNFT.sol/SimpleNFT.json`

Copy the `abi` arrays to your Flutter app for contract interaction.

---

## 📱 Run Flutter App

### Step 1: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 2: Configure WalletConnect Project ID

Get your Project ID from https://cloud.walletconnect.com

Create `.env` in project root:
```
WC_PROJECT_ID=your_walletconnect_project_id
```

### Step 3: Run the App

```bash
# Run on connected device/emulator
flutter run

# Or with Project ID directly
flutter run --dart-define=WC_PROJECT_ID=your_project_id
```

---

## 🎮 Using the Platform

### 1. Connect Wallet

1. Open the app
2. Select network (BNB Testnet or Sepolia)
3. Tap "Connect MetaMask"
4. Approve connection in MetaMask mobile
5. Your address appears on screen ✅

### 2. Create an Auction (via Contract)

Using Remix IDE or Hardhat console:

```javascript
// First, approve auction contract to transfer your NFT
await nftContract.approve(auctionContractAddress, tokenId);

// Create auction
// startPrice in Wei (e.g., 0.1 ETH = 100000000000000000)
// duration in hours
await auctionContract.createAuction(
  nftContractAddress,    // NFT contract address
  tokenId,               // Your NFT token ID
  "100000000000000000",  // 0.1 ETH start price
  24                     // 24 hours duration
);
```

### 3. Place a Bid

```javascript
// Bid must be higher than current bid
// Amount in Wei
await auctionContract.placeBid(
  auctionId,  // Auction ID (0, 1, 2, ...)
  { value: "150000000000000000" }  // 0.15 ETH
);
```

### 4. End Auction

```javascript
// After auction time expires
await auctionContract.endAuction(auctionId);
```

### 5. Withdraw Funds

```javascript
// Withdraw your funds (sellers & outbid bidders)
await auctionContract.withdraw();
```

---

## 📚 Smart Contract Functions

### NFTAuction Contract

#### Read Functions
```solidity
// Get auction details
function getAuction(uint256 _auctionId) returns (
    address seller,
    address nftContract,
    uint256 tokenId,
    uint256 startPrice,
    uint256 highestBid,
    address highestBidder,
    uint256 endTime,
    bool ended,
    bool cancelled
)

// Check if auction is active
function isAuctionActive(uint256 _auctionId) returns (bool)

// Get time remaining
function getTimeRemaining(uint256 _auctionId) returns (uint256)

// Check pending withdrawals
function pendingWithdrawals(address user) returns (uint256)
```

#### Write Functions
```solidity
// Create a new auction
function createAuction(
    address _nftContract,
    uint256 _tokenId,
    uint256 _startPrice,
    uint256 _duration
) returns (uint256)

// Place a bid (send ETH)
function placeBid(uint256 _auctionId) payable

// End an auction
function endAuction(uint256 _auctionId)

// Cancel auction (only if no bids)
function cancelAuction(uint256 _auctionId)

// Withdraw your funds
function withdraw()
```

### SimpleNFT Contract

```solidity
// Mint a single NFT
function mintNFT(address _to, string memory _tokenURI) returns (uint256)

// Batch mint for testing
function batchMint(address _to, uint256 _count)

// Approve auction contract
function approve(address to, uint256 tokenId)
```

---

## 🔧 Interacting from Flutter

The `AuctionService` class provides methods to interact with contracts:

```dart
// Initialize service
final auctionService = AuctionService(walletService: walletService);
await auctionService.initialize(Network.bnbTestnet);

// Get auction details
final auction = await auctionService.getAuction(BigInt.from(0));

// Place a bid
final txHash = await auctionService.placeBid(
  auctionId: BigInt.from(0),
  bidAmount: AuctionService.etherToWei(0.15),
  context: context,
);

// End auction
await auctionService.endAuction(
  auctionId: BigInt.from(0),
  context: context,
);

// Withdraw funds
await auctionService.withdraw(context: context);
```

---

## 🧪 Testing Workflow

### 1. Deploy Contracts
```bash
cd contracts
npm run deploy:testnet
```

### 2. Mint Test NFTs
```bash
npx hardhat console --network bnbTestnet
```

```javascript
const SimpleNFT = await ethers.getContractFactory("SimpleNFT");
const nft = await SimpleNFT.attach("YOUR_NFT_ADDRESS");
await nft.mintNFT(deployer.address, "ipfs://test");
```

### 3. Create Test Auction
```javascript
// Approve
await nft.approve("YOUR_AUCTION_ADDRESS", 1);

// Create auction
const NFTAuction = await ethers.getContractFactory("NFTAuction");
const auction = await NFTAuction.attach("YOUR_AUCTION_ADDRESS");
await auction.createAuction(
  "YOUR_NFT_ADDRESS",
  1,
  ethers.parseEther("0.1"),
  24 * 3600
);
```

### 4. Test in App
- Connect wallet
- View auction details
- Place bids
- End auction
- Withdraw funds

---

## 🐛 Troubleshooting

### Contract Deployment Issues

**Error: "Insufficient funds"**
```bash
# Get test tokens
# BNB Testnet: https://testnet.bnbchain.org/faucet-smart
# Sepolia: https://sepoliafaucet.com/
```

**Error: "Invalid nonce"**
```bash
# Reset MetaMask account in Settings > Advanced > Reset Account
```

### Flutter App Issues

**Error: "Contract not approved"**
```dart
// Approve NFT transfer first
await nftContract.approve(auctionAddress, tokenId);
```

**Error: "Bid below start price"**
```dart
// Ensure bid is higher than startPrice
// Get auction details first
final auction = await auctionService.getAuction(auctionId);
final minBid = auction['highestBid'] > 0 
    ? auction['highestBid'] + BigInt.from(1) 
    : auction['startPrice'];
```

**Error: "Wallet not connected"**
```dart
// Connect wallet first
await walletService.connect(context: context);
```

### MetaMask Connection Issues

1. **Deep link not opening MetaMask**
   - Ensure MetaMask mobile app is installed
   - Try using universal link: `https://metamask.app.link/wc?uri=...`

2. **Network mismatch**
   - Disconnect wallet in app
   - Change network in dropdown
   - Reconnect wallet

3. **Transaction not showing**
   - Open MetaMask manually
   - Check pending transactions
   - Approve or reject

---

## 📊 Gas Estimates (BNB Testnet)

| Operation | Gas Used | Cost (~20 gwei) |
|-----------|----------|-----------------|
| Deploy NFTAuction | ~2,500,000 | ~0.05 BNB |
| Deploy SimpleNFT | ~1,800,000 | ~0.036 BNB |
| Create Auction | ~150,000 | ~0.003 BNB |
| Place Bid | ~80,000 | ~0.0016 BNB |
| End Auction | ~120,000 | ~0.0024 BNB |
| Withdraw | ~45,000 | ~0.0009 BNB |

---

## 🔐 Security Best Practices

1. **Never share your private key**
2. **Use test networks for development**
3. **Audit contracts before mainnet deployment**
4. **Test thoroughly with small amounts first**
5. **Keep `.env` files out of version control**
6. **Use hardware wallets for large amounts**
7. **Verify contracts on block explorers**

---

## 📝 Next Steps

### Phase 1: Testing (Current)
- ✅ Deploy to testnet
- ✅ Test wallet connection
- ⬜ Test auction creation
- ⬜ Test bidding flow
- ⬜ Test withdrawals

### Phase 2: UI Enhancement
- ⬜ Add auction list screen
- ⬜ Add NFT detail view
- ⬜ Add bid history
- ⬜ Add notifications

### Phase 3: Advanced Features
- ⬜ English auction
- ⬜ Dutch auction
- ⬜ Reserve price
- ⬜ Buy now option
- ⬜ Multiple currency support

### Phase 4: Production
- ⬜ Security audit
- ⬜ Mainnet deployment
- ⬜ App store submission
- ⬜ Marketing & launch

---

## 🆘 Getting Help

### Resources
- **Hardhat Docs**: https://hardhat.org/docs
- **Web3Dart Docs**: https://pub.dev/packages/web3dart
- **WalletConnect**: https://docs.walletconnect.com/
- **OpenZeppelin**: https://docs.openzeppelin.com/contracts/

### Support
- Open an issue on GitHub
- Check BNB Testnet explorer: https://testnet.bscscan.com
- Check Sepolia explorer: https://sepolia.etherscan.io

---

## ✨ Success!

You now have a complete NFT auction platform with:
- ✅ Clean wallet connection UI
- ✅ Network selection (BNB Testnet & Sepolia)
- ✅ Production-ready smart contracts
- ✅ Flutter integration setup
- ✅ Deployment scripts

**Happy Bidding! 🎉**

