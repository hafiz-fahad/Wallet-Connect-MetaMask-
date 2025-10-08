# 🎨 NFT Auction - Quick Start (5 Minutes)

## ✨ What's New?

Your app now has **3 tabs**:

```
┌────────────────────────────────────────┐
│  👛 Wallet  |  📤 Send  |  🎨 Auctions │
└────────────────────────────────────────┘
```

### New Auctions Tab Features:

**Active Auctions (View & Bid)**
- See all ongoing NFT auctions
- View current bids and time remaining
- Place bids to win NFTs

**Create Auction (Sell Your NFTs)**
- Create new auctions for your NFTs
- Set starting price and duration
- Earn money from your digital art

---

## 🎯 What is an NFT Auction? (Simple Explanation)

Think of it like eBay for digital art:

1. **Owner** creates auction with starting price (e.g., $10)
2. **Bidders** compete by bidding higher amounts
3. **Timer** counts down (e.g., 24 hours)
4. **Winner** gets the NFT, seller gets paid

**Example:**
```
Start: $10
Bob bids: $15
Alice bids: $20
Charlie bids: $25
Time expires → Charlie wins! Gets NFT, seller gets $25
```

---

## 🚀 Deploy Contracts (10 Minutes)

### Step 1: Get Test Money

Go to: https://testnet.bnbchain.org/faucet-smart
- Enter your MetaMask address
- Click "Give me BNB"
- Wait 1 minute
- ✅ You have 0.5 tBNB (free test money)

### Step 2: Install & Deploy

```bash
# 1. Go to contracts folder
cd contracts

# 2. Install packages (takes 2 minutes)
npm install

# 3. Create environment file
cp env-example.txt .env

# 4. Edit .env and add your MetaMask private key
# (Get from MetaMask → Account Details → Show Private Key)
nano .env

# 5. Deploy contracts (takes 2 minutes)
npm run deploy:testnet
```

### Step 3: Save Addresses

You'll see:
```
SimpleNFT Contract: 0xABC123...
NFTAuction Contract: 0xDEF456...
```

**COPY THESE!** You'll need them in the next step.

### Step 4: Update App

Open `lib/services/auction_service.dart` (lines 10-11):

```dart
// Replace with YOUR addresses
static const String auctionContractAddress = '0xDEF456...';
static const String nftContractAddress = '0xABC123...';
```

---

## 🎮 How to Use

### Test It Out (5 Minutes)

#### 1. Run App
```bash
flutter run
```

#### 2. Connect Wallet
- Go to Wallet tab
- Tap "Connect MetaMask"
- ✅ Connected!

#### 3. View Auctions
- Go to Auctions tab
- Tap "Active Auctions"
- See example auctions (with mock data)

#### 4. Try Creating Auction
- Tap "Create Auction" tab
- See the form
- Read the guide in the app

---

## 📖 Complete Workflow Example

### Alice Sells NFT to Bob

**Step 1: Alice Prepares** (3 minutes)
```bash
# Alice approves her NFT
cd contracts
npx hardhat console --network bnbTestnet

const nft = await ethers.getContractAt("SimpleNFT", "YOUR_NFT_ADDRESS");
await nft.approve("YOUR_AUCTION_ADDRESS", 1);
```

**Step 2: Alice Creates Auction** (1 minute)
- Open app → Auctions tab
- Tap "Create Auction"
- Fill form:
  - NFT Address: 0xABC123...
  - Token ID: 1
  - Start Price: 0.1
  - Duration: 24 hours
- Tap "Create Auction"
- Approve in MetaMask
- ✅ Auction live!

**Step 3: Bob Places Bid** (1 minute)
- Open app → Auctions tab
- Tap "Active Auctions"
- Find Alice's auction
- Tap "Place Bid"
- Enter amount: 0.15 ETH
- Approve in MetaMask
- ✅ Bob is highest bidder!

**Step 4: Auction Ends** (after 24 hours)
```bash
# Anyone can end it
cd contracts
npx hardhat console --network bnbTestnet

const auction = await ethers.getContractAt("NFTAuction", "YOUR_AUCTION_ADDRESS");
await auction.endAuction(0);
```

**Result:**
- ✅ Bob owns the NFT
- ✅ Alice gets 0.1463 ETH (0.15 - 2.5% fee)
- ✅ Platform gets 0.0037 ETH fee

---

## 🎨 UI Screenshots (What You'll See)

### Active Auctions Screen
```
┌─────────────────────────────────────┐
│  ℹ️ How NFT Auctions Work           │
│  1. Owner creates auction            │
│  2. Users place bids                 │
│  3. Highest bidder wins              │
├─────────────────────────────────────┤
│  🎨 Cool NFT #1             [LIVE]   │
│  Current Bid: 0.5 ETH                │
│  Time Left: 2h 30m                   │
│  Total Bids: 5                       │
│  [  Place Bid  ]                     │
├─────────────────────────────────────┤
│  🎨 Rare NFT #42            [LIVE]   │
│  Current Bid: 1.2 ETH                │
│  Time Left: 5h 15m                   │
│  Total Bids: 12                      │
│  [  Place Bid  ]                     │
└─────────────────────────────────────┘
```

### Create Auction Screen
```
┌─────────────────────────────────────┐
│  💡 Before Creating an Auction       │
│  1. Deploy/have NFT contract         │
│  2. Know your Token ID               │
│  3. Approve auction contract         │
│  4. Fill form below                  │
├─────────────────────────────────────┤
│  Create New Auction                  │
│  ┌───────────────────────────────┐  │
│  │ NFT Contract Address      📋  │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Token ID                  📋  │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Starting Price (ETH)      📋  │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Duration (hours)          📋  │  │
│  └───────────────────────────────┘  │
│  [   ➕ Create Auction   ]          │
└─────────────────────────────────────┘
```

---

## 🐛 Common Issues & Fixes

### "Contract not approved"
```bash
# Fix: Approve your NFT first
cd contracts
npx hardhat console --network bnbTestnet

const nft = await ethers.getContractAt("SimpleNFT", "NFT_ADDRESS");
await nft.approve("AUCTION_ADDRESS", TOKEN_ID);
```

### "Insufficient funds"
- Get more test BNB: https://testnet.bnbchain.org/faucet-smart

### "Bid too low"
- Your bid must be higher than current bid
- Add at least 0.01 ETH more

---

## 📚 Full Documentation

For complete details, see:
- **[COMPLETE_AUCTION_GUIDE.md](./COMPLETE_AUCTION_GUIDE.md)** - Detailed beginner guide (30 pages!)
- **[NFT_AUCTION_GUIDE.md](./NFT_AUCTION_GUIDE.md)** - Technical reference
- **[QUICK_START.md](./QUICK_START.md)** - App quick start

---

## ✅ Quick Checklist

Before using auctions:

- [ ] Deployed NFT contract
- [ ] Deployed Auction contract  
- [ ] Updated addresses in `auction_service.dart`
- [ ] Have test funds (0.1+ tBNB)
- [ ] Wallet connected in app
- [ ] Minted at least 1 NFT
- [ ] Approved auction contract

---

## 🎯 Key Commands Reference

```bash
# Deploy everything
cd contracts && npm run deploy:testnet

# Mint NFT
npx hardhat console --network bnbTestnet
const nft = await ethers.getContractAt("SimpleNFT", "ADDRESS");
await nft.mintNFT(deployer.address, "ipfs://test");

# Approve NFT
await nft.approve("AUCTION_ADDRESS", 1);

# Create auction (via console)
const auction = await ethers.getContractAt("NFTAuction", "ADDRESS");
await auction.createAuction(
  "NFT_ADDRESS",
  1,  // token ID
  ethers.parseEther("0.1"),  // start price
  86400  // 24 hours in seconds
);

# Place bid
await auction.placeBid(0, { value: ethers.parseEther("0.15") });

# End auction
await auction.endAuction(0);

# Withdraw payment
await auction.withdraw();
```

---

## 🎉 You're Ready!

You now have:
- ✅ Auction UI in your app
- ✅ Smart contracts ready to deploy
- ✅ Complete guides
- ✅ Example workflows

**Next Steps:**
1. Deploy contracts (10 min)
2. Update contract addresses
3. Run app and test!

**Total time: 15 minutes to fully working auction system!**

---

## 💡 Pro Tips

1. **Start Simple**: Test with your own address first
2. **Use Testnet**: Never use real money while learning
3. **Read Guides**: Check COMPLETE_AUCTION_GUIDE.md for details
4. **Ask Questions**: Refer to troubleshooting sections
5. **Have Fun**: You're learning blockchain development!

---

Happy Auctioning! 🎨🚀

