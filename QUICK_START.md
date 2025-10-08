# 🚀 Quick Start Guide

## ✅ What You Have Now

### 1. **Clean Flutter App**
- ✅ Simple wallet connection screen
- ✅ Network dropdown (BNB Testnet & Sepolia)
- ✅ Address display after connection
- ✅ Professional dark theme UI
- ✅ No dummy data - clean slate!

### 2. **Smart Contracts**
- ✅ **NFTAuction.sol** - Complete auction system
- ✅ **SimpleNFT.sol** - ERC721 for testing
- ✅ Production-ready with security features
- ✅ Deployment scripts included

### 3. **Project Structure**

```
wallet_connect/
├── lib/
│   ├── main.dart              # Clean wallet connection UI
│   ├── services/
│   │   ├── wallet_service.dart      # WalletConnect v2
│   │   └── auction_service.dart     # Contract interaction
│   └── constants/
│       ├── app_colors.dart          # Theme colors
│       └── app_theme.dart           # App theme
│
└── contracts/
    ├── NFTAuction.sol         # Auction contract
    ├── SimpleNFT.sol          # Test NFT contract
    ├── package.json           # Node dependencies
    ├── hardhat.config.js      # Deployment config
    └── scripts/
        └── deploy.js          # Deploy script
```

---

## 🎯 Next Steps (5 Minutes)

### Step 1: Run the Flutter App

```bash
# Make sure you're in project root
cd /Users/fahad/Documents/FlutterProjects/wallet_connect

# Run the app
flutter run
```

You'll see:
- Network selector (BNB Testnet / Sepolia)
- Connect MetaMask button
- Clean, professional UI

### Step 2: Test Wallet Connection

1. Open the app on your device/emulator
2. Select a network
3. Tap "Connect MetaMask"
4. Approve in MetaMask mobile app
5. See your address displayed! ✅

---

## 🔧 Deploy Smart Contracts (10 Minutes)

### Quick Deploy to BNB Testnet

```bash
# 1. Go to contracts folder
cd contracts

# 2. Install dependencies
npm install

# 3. Create .env file
cp env-example.txt .env

# 4. Edit .env and add your private key
# Get it from MetaMask: Settings > Security & Privacy > Show Private Key
nano .env

# 5. Get test BNB
# Visit: https://testnet.bnbchain.org/faucet-smart

# 6. Deploy!
npm run deploy:testnet
```

After deployment, you'll see:
```
SimpleNFT Contract: 0xABC123...
NFTAuction Contract: 0xDEF456...
```

**Save these addresses!**

### Update Flutter App

Open `lib/services/auction_service.dart` (line 10-11):

```dart
static const String auctionContractAddress = '0xDEF456...'; // Your address
static const String nftContractAddress = '0xABC123...';     // Your address
```

---

## 📚 Full Documentation

For complete guide, see:
- **[NFT_AUCTION_GUIDE.md](./NFT_AUCTION_GUIDE.md)** - Complete documentation
- **[contracts/README.md](./contracts/README.md)** - Contract details

---

## 🎨 What You Can Do

### Current Features

1. **Wallet Connection**
   - Connect to MetaMask
   - Switch between networks
   - View connected address
   - Disconnect wallet

2. **Smart Contract (After Deploy)**
   - Create NFT auctions
   - Place bids
   - End auctions
   - Withdraw funds
   - Platform fees management

### Smart Contract Functions

**NFTAuction Contract:**
- `createAuction()` - Create new auction
- `placeBid()` - Bid on auction
- `endAuction()` - Finalize auction
- `withdraw()` - Withdraw funds
- `getAuction()` - Get auction details
- `isAuctionActive()` - Check if active

**SimpleNFT Contract:**
- `mintNFT()` - Mint new NFT
- `batchMint()` - Mint multiple NFTs
- `approve()` - Approve auction contract

---

## 🧪 Testing Flow

### 1. Deploy Contracts
```bash
cd contracts && npm run deploy:testnet
```

### 2. Mint Test NFT
```bash
npx hardhat console --network bnbTestnet
```

```javascript
const SimpleNFT = await ethers.getContractFactory("SimpleNFT");
const nft = await SimpleNFT.attach("YOUR_NFT_ADDRESS");
await nft.mintNFT(deployer.address, "ipfs://test");
```

### 3. Create Auction
```javascript
await nft.approve("AUCTION_ADDRESS", 1);

const NFTAuction = await ethers.getContractFactory("NFTAuction");
const auction = await NFTAuction.attach("AUCTION_ADDRESS");
await auction.createAuction(
  "NFT_ADDRESS",
  1, // token ID
  ethers.parseEther("0.1"), // start price
  24 * 3600 // 24 hours
);
```

### 4. Place Bid
```javascript
await auction.placeBid(0, { value: ethers.parseEther("0.15") });
```

### 5. End Auction (after time expires)
```javascript
await auction.endAuction(0);
```

### 6. Withdraw Funds
```javascript
await auction.withdraw();
```

---

## 🎯 Key Files to Know

### Flutter App
- **`lib/main.dart`** - Main app with wallet connection UI
- **`lib/services/wallet_service.dart`** - WalletConnect integration
- **`lib/services/auction_service.dart`** - Contract interaction methods
- **`lib/constants/app_colors.dart`** - Color theme
- **`lib/constants/app_theme.dart`** - App theme config

### Smart Contracts
- **`contracts/NFTAuction.sol`** - Main auction logic
- **`contracts/SimpleNFT.sol`** - Test NFT minting
- **`contracts/scripts/deploy.js`** - Deployment script
- **`contracts/hardhat.config.js`** - Network config

---

## 🔑 Important Notes

### Security
- ✅ `.env` is in `.gitignore` - your keys are safe
- ✅ Never commit private keys
- ✅ Use test networks for development
- ✅ Contracts have reentrancy protection

### Networks
- **BNB Testnet**: Chain ID 97
- **Sepolia**: Chain ID 11155111

### Getting Test Funds
- **BNB Testnet**: https://testnet.bnbchain.org/faucet-smart
- **Sepolia**: https://sepoliafaucet.com/

---

## 🆘 Troubleshooting

### Flutter App Won't Connect
```bash
# Check MetaMask is installed on mobile device
# Ensure network matches in both app and MetaMask
# Try disconnecting and reconnecting
```

### Contract Deployment Failed
```bash
# Check you have test funds
# Verify private key in .env (no 0x prefix)
# Try: npx hardhat clean
# Then: npm run compile && npm run deploy:testnet
```

### Transaction Not Showing
```bash
# Open MetaMask app manually
# Check pending transactions
# Approve or reject
```

---

## ✨ Summary

### What Works Right Now
- ✅ Flutter app with wallet connection
- ✅ Network selection (BNB Testnet & Sepolia)
- ✅ MetaMask integration
- ✅ Address display
- ✅ Clean, professional UI
- ✅ No dummy data

### What You Need to Do
1. ⬜ Deploy smart contracts (10 min)
2. ⬜ Update contract addresses in app
3. ⬜ Test auction creation
4. ⬜ Test bidding flow

### Total Time to Full Working Platform
- **15 minutes** if you have MetaMask & test funds
- **30 minutes** if starting fresh

---

## 🎉 You're Ready!

Your NFT auction platform foundation is complete:
- Clean Flutter app ✅
- Production-ready smart contracts ✅
- Deployment scripts ✅
- Complete documentation ✅

**Next:** Deploy contracts and start testing!

For detailed instructions, see **[NFT_AUCTION_GUIDE.md](./NFT_AUCTION_GUIDE.md)**

Happy Building! 🚀

