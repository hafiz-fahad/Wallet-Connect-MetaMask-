# 🎨 Complete NFT Auction Guide for Beginners

## 📚 Table of Contents
1. [What are NFT Auctions?](#what-are-nft-auctions)
2. [How Do They Work?](#how-do-they-work)
3. [Your New Auction Screen](#your-new-auction-screen)
4. [Deploy Smart Contracts](#deploy-smart-contracts)
5. [Step-by-Step Usage Guide](#step-by-step-usage-guide)
6. [Real Example Walkthrough](#real-example-walkthrough)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 What are NFT Auctions?

### Simple Explanation

Think of an **NFT Auction** like an eBay auction, but for digital items (NFTs):

- **NFT** = A unique digital item (like a digital art piece, trading card, or collectible)
- **Auction** = A sale where people bid against each other
- **Winner** = Person who bids the highest amount before time runs out

### Real-World Example

Imagine you have a rare Pokemon card:
1. You want to sell it to the highest bidder
2. You start the auction at $10
3. People bid: $15, $20, $25...
4. After 24 hours, auction ends
5. Highest bidder ($25) wins and gets the card
6. You get the $25

**NFT Auctions work exactly the same, but with digital items on the blockchain!**

---

## 🔄 How Do They Work?

### The Process (Step by Step)

```
1. NFT Owner Creates Auction
   ├─ Sets starting price (e.g., 0.1 ETH)
   ├─ Sets duration (e.g., 24 hours)
   └─ Transfers NFT to auction contract

2. People Place Bids
   ├─ Each bid must be higher than current bid
   ├─ Previous bidder gets refunded automatically
   └─ Auction timer counts down

3. Auction Ends
   ├─ Time expires (e.g., 24 hours passed)
   ├─ Winner gets the NFT
   └─ Seller gets the payment (minus 2.5% fee)
```

### Key Terms You Need to Know

| Term | What It Means |
|------|---------------|
| **NFT** | Non-Fungible Token - a unique digital item |
| **Smart Contract** | Code on blockchain that automatically executes rules |
| **Token ID** | Unique number identifying your specific NFT |
| **Wei** | Smallest unit of ETH (like cents to dollars) |
| **Gas Fee** | Cost to make transactions on blockchain |
| **Approve** | Give contract permission to transfer your NFT |

---

## 📱 Your New Auction Screen

### What You'll See

Your app now has **3 tabs** at the bottom:

```
┌──────────────────────────────────────────┐
│  👛 Wallet  |  📤 Send  |  🎨 Auctions  │
└──────────────────────────────────────────┘
```

### Auctions Tab Features

**Tab 1: Active Auctions**
- See all ongoing auctions
- View current bids and time left
- Place bids on NFTs you want

**Tab 2: Create Auction**
- Create your own auction
- Set starting price and duration
- Sell your NFTs to highest bidder

---

## 🚀 Deploy Smart Contracts

### Prerequisites (What You Need)

Before starting, make sure you have:

- [x] Node.js installed (v18+)
- [x] MetaMask wallet with test funds
- [x] Your Flutter app connected to wallet

### Step 1: Get Test Funds

You need test cryptocurrency to deploy contracts:

**For BNB Testnet:**
1. Go to: https://testnet.bnbchain.org/faucet-smart
2. Enter your wallet address
3. Click "Give me BNB"
4. Wait 1-2 minutes
5. You'll get 0.5 tBNB (free testnet money)

**For Sepolia:**
1. Go to: https://sepoliafaucet.com/
2. Enter your wallet address
3. Complete captcha
4. You'll get 0.5 ETH (free testnet money)

### Step 2: Install Contract Dependencies

```bash
# Navigate to contracts folder
cd contracts

# Install required packages (takes 1-2 minutes)
npm install

# You should see:
# ✓ Installed hardhat
# ✓ Installed @openzeppelin/contracts
# ✓ Installed other dependencies
```

### Step 3: Configure Environment

Create a file called `.env` in the `contracts` folder:

```bash
# Copy the example
cp env-example.txt .env

# Open and edit it
nano .env
```

Add your private key (get from MetaMask):

```env
# Your wallet private key (WITHOUT 0x prefix)
PRIVATE_KEY=abc123def456...

# Optional: API keys for verification
BSCSCAN_API_KEY=your_key_here
ETHERSCAN_API_KEY=your_key_here
```

**⚠️ How to Get Private Key from MetaMask:**
1. Open MetaMask
2. Click three dots → Account Details
3. Click "Show Private Key"
4. Enter password
5. Copy the key (WITHOUT "0x" at start)

### Step 4: Deploy Contracts

```bash
# Deploy to BNB Testnet (recommended for beginners)
npm run deploy:testnet
```
# OR deploy to Sepolia
npm run deploy:sepolia


**What Happens:**
```
🚀 Starting deployment...
📦 Deploying SimpleNFT contract...
✅ SimpleNFT deployed to: 0xABC123...
📦 Deploying NFTAuction contract...
✅ NFTAuction deployed to: 0xDEF456...
🎨 Minting test NFTs...
✅ Minted 3 test NFTs

📋 DEPLOYMENT SUMMARY
====================================
SimpleNFT Contract: 0xABC123...
NFTAuction Contract: 0xDEF456...
Network: bnbTestnet
====================================
```

**🎉 Congratulations! Your contracts are deployed!**

### Step 5: Save Contract Addresses

**IMPORTANT:** Copy these two addresses:
- `SimpleNFT Contract: 0xABC123...`
- `NFTAuction Contract: 0xDEF456...`

Now update your Flutter app:

Open `lib/services/auction_service.dart` and update lines 10-11:

```dart
// BEFORE
static const String auctionContractAddress = '0x...';
static const String nftContractAddress = '0x...';

// AFTER (use YOUR addresses)
static const String auctionContractAddress = '0xDEF456...'; // Your auction address
static const String nftContractAddress = '0xABC123...';     // Your NFT address
```

---

## 🎮 Step-by-Step Usage Guide

### Scenario 1: Create Your First Auction

#### Step 1: Run Your App

```bash
flutter run
```

#### Step 2: Connect Wallet

1. Open app
2. Go to **Wallet** tab
3. Select "BNB Testnet"
4. Tap "Connect MetaMask"
5. Approve in MetaMask
6. ✅ You're connected!

#### Step 3: View Your NFTs

You now have 3 test NFTs (minted during deployment):
- Token ID: 1
- Token ID: 2  
- Token ID: 3

#### Step 4: Approve Auction Contract

Before creating auction, you must approve the contract:

**Using Hardhat Console:**
```bash
cd contracts
npx hardhat console --network bnbTestnet
```

Then run:
```javascript
// Get your NFT contract
const SimpleNFT = await ethers.getContractFactory("SimpleNFT");
const nft = await SimpleNFT.attach("YOUR_NFT_ADDRESS");

// Approve auction contract to transfer your NFT
await nft.approve("YOUR_AUCTION_ADDRESS", 1);

// Wait for confirmation
console.log("✅ Approved! You can now create auction with Token ID 1");
```

#### Step 5: Create Auction in App

1. Go to **Auctions** tab
2. Tap **"Create Auction"** tab
3. Fill the form:
   ```
   NFT Contract Address: 0xABC123... (your NFT address)
   Token ID: 1
   Starting Price: 0.1
   Duration: 24
   ```
4. Tap **"Create Auction"**
5. Approve transaction in MetaMask
6. Wait for confirmation (30 seconds - 2 minutes)
7. ✅ Auction created!

#### Step 6: View Your Auction

1. Go to **"Active Auctions"** tab
2. You'll see your auction listed:
   ```
   Cool NFT #1
   Current Bid: 0.1 ETH
   Time Left: 23h 59m
   Total Bids: 0
   ```

---

### Scenario 2: Place a Bid

#### As Another User (or same user for testing):

1. Go to **Auctions** tab
2. Tap **"Active Auctions"**
3. Find an auction you like
4. Tap **"Place Bid"** button
5. Enter bid amount (must be higher than current):
   ```
   Current Bid: 0.1 ETH
   Your Bid: 0.15 ETH
   ```
6. Tap **"Place Bid"**
7. Approve transaction in MetaMask
8. ✅ Your bid is placed!

**What Happens:**
- Your 0.15 ETH is sent to contract
- You become the highest bidder
- Previous bidder gets refunded automatically
- Auction continues until time expires

---

### Scenario 3: End Auction and Get Your NFT

#### After 24 Hours Pass:

**As Anyone (seller, bidder, or third party):**

```bash
# Using Hardhat console
cd contracts
npx hardhat console --network bnbTestnet
```

```javascript
// Get auction contract
const NFTAuction = await ethers.getContractFactory("NFTAuction");
const auction = await NFTAuction.attach("YOUR_AUCTION_ADDRESS");

// End the auction (ID 0 for first auction)
await auction.endAuction(0);

// Wait for confirmation
console.log("✅ Auction ended!");
```

**What Happens:**
- NFT transferred to highest bidder
- Payment sent to seller (minus 2.5% fee)
- Auction marked as completed

#### Claim Your Winnings

**If you were the winner:**
- Check your wallet - you now own the NFT!

**If you were the seller:**
```javascript
// Withdraw your payment
await auction.withdraw();
console.log("✅ Payment withdrawn!");
```

---

## 🎯 Real Example Walkthrough

### Example: Alice Sells NFT, Bob Buys It

#### Characters:
- **Alice**: Has NFT #1, wants to sell it
- **Bob**: Wants to buy Alice's NFT

#### Timeline:

**Day 1, 9:00 AM - Alice Creates Auction**
```
1. Alice approves auction contract
2. Alice creates auction:
   - NFT: Token ID #1
   - Start Price: 0.1 ETH
   - Duration: 24 hours
3. NFT transferred from Alice → Contract
```

**Day 1, 10:00 AM - Bob Places First Bid**
```
1. Bob sees auction in app
2. Bob bids 0.15 ETH
3. Bob's 0.15 ETH sent to contract
4. Bob is now highest bidder
```

**Day 1, 2:00 PM - Charlie Outbids Bob**
```
1. Charlie bids 0.20 ETH
2. Charlie's 0.20 ETH sent to contract
3. Bob's 0.15 ETH refunded automatically
4. Charlie is now highest bidder
```

**Day 1, 8:00 PM - Bob Bids Again**
```
1. Bob bids 0.25 ETH
2. Bob's 0.25 ETH sent to contract
3. Charlie's 0.20 ETH refunded automatically
4. Bob is highest bidder again
```

**Day 2, 9:00 AM - Auction Ends**
```
1. 24 hours passed
2. Anyone calls endAuction()
3. NFT transferred: Contract → Bob
4. Payment sent: 0.2438 ETH → Alice (0.25 - 2.5% fee)
5. Platform fee: 0.0062 ETH → Contract owner
```

**Final Result:**
- ✅ Bob owns NFT #1
- ✅ Alice received 0.2438 ETH
- ✅ Platform earned 0.0062 ETH fee

---

## 🐛 Troubleshooting

### Problem: "Contract not approved"

**Solution:**
```bash
# Approve your NFT first
cd contracts
npx hardhat console --network bnbTestnet

const SimpleNFT = await ethers.getContractFactory("SimpleNFT");
const nft = await SimpleNFT.attach("YOUR_NFT_ADDRESS");
await nft.approve("YOUR_AUCTION_ADDRESS", YOUR_TOKEN_ID);
```

### Problem: "Transaction failed - insufficient funds"

**Solution:**
- Get more test funds from faucet
- BNB Testnet: https://testnet.bnbchain.org/faucet-smart
- Sepolia: https://sepoliafaucet.com/

### Problem: "Cannot place bid - amount too low"

**Solution:**
- Your bid must be higher than current bid
- Check current bid first
- Add at least 0.01 ETH more

### Problem: "Auction already ended"

**Solution:**
- You can't bid on ended auctions
- Look for active auctions in the list
- Check "Time Left" before bidding

### Problem: "NFT not found"

**Solution:**
- Make sure you minted NFTs first
- Use correct Token ID (1, 2, or 3)
- Check NFT contract address is correct

---

## 📊 Quick Reference

### Contract Addresses (Update These!)

```dart
// In lib/services/auction_service.dart
auctionContractAddress = 'YOUR_AUCTION_ADDRESS';
nftContractAddress = 'YOUR_NFT_ADDRESS';
```

### Important Commands

```bash
# Deploy contracts
npm run deploy:testnet

# Mint NFT
npx hardhat console --network bnbTestnet
const nft = await ethers.getContractAt("SimpleNFT", "ADDRESS");
await nft.mintNFT(deployer.address, "ipfs://test");

# Approve NFT
await nft.approve("AUCTION_ADDRESS", TOKEN_ID);

# Create auction
const auction = await ethers.getContractAt("NFTAuction", "ADDRESS");
await auction.createAuction(NFT_ADDRESS, TOKEN_ID, ethers.parseEther("0.1"), 86400);

# Place bid
await auction.placeBid(AUCTION_ID, { value: ethers.parseEther("0.15") });

# End auction
await auction.endAuction(AUCTION_ID);

# Withdraw funds
await auction.withdraw();
```

### Gas Costs (Approximate)

| Operation | Cost |
|-----------|------|
| Deploy Contracts | ~0.08 tBNB |
| Mint NFT | ~0.002 tBNB |
| Approve NFT | ~0.001 tBNB |
| Create Auction | ~0.003 tBNB |
| Place Bid | ~0.002 tBNB |
| End Auction | ~0.002 tBNB |
| Withdraw | ~0.001 tBNB |

---

## ✅ Checklist

Before using auctions, make sure:

- [x] Deployed both contracts (NFT + Auction)
- [x] Updated contract addresses in auction_service.dart
- [x] Have test funds in wallet
- [x] Wallet connected in app
- [x] Minted at least one NFT
- [x] Approved auction contract
- [x] Read this guide!

---

## 🎓 Key Learnings

### What You Now Understand:

1. **NFTs** - Unique digital items on blockchain
2. **Auctions** - Competitive bidding for NFTs
3. **Smart Contracts** - Automated code that enforces rules
4. **Deployment** - Putting contracts on blockchain
5. **Interactions** - How to create auctions and place bids

### What You Can Do:

1. ✅ Connect wallet to BNB Testnet
2. ✅ Deploy NFT and Auction contracts
3. ✅ Mint your own NFTs
4. ✅ Create auctions for your NFTs
5. ✅ Place bids on other auctions
6. ✅ End auctions and claim NFTs
7. ✅ Withdraw auction payments

---

## 🚀 Next Steps

### Phase 1: Testing (Current)
- [x] Deploy to testnet
- [ ] Create your first auction
- [ ] Place test bids
- [ ] End auction and verify transfer

### Phase 2: Advanced Features
- [ ] Add NFT images
- [ ] Show NFT metadata
- [ ] Add bid history
- [ ] Add notifications

### Phase 3: Production
- [ ] Security audit
- [ ] Deploy to mainnet
- [ ] Launch to public

---

## 📞 Need Help?

### Resources:
- **Smart Contracts**: `contracts/NFTAuction.sol` and `contracts/SimpleNFT.sol`
- **Auction Screen**: `lib/screens/auction_screen.dart`
- **Service Integration**: `lib/services/auction_service.dart`

### Documentation:
- **Quick Start**: See `QUICK_START.md`
- **Transaction Guide**: See `TRANSACTION_FEATURE.md`
- **Main Guide**: See `NFT_AUCTION_GUIDE.md`

---

## 🎉 Congratulations!

You now know:
- ✅ What NFT auctions are
- ✅ How they work
- ✅ How to deploy contracts
- ✅ How to use your auction app
- ✅ Complete workflow from creation to completion

**You're ready to create and manage NFT auctions! 🚀**

Happy Auctioning! 🎨✨

