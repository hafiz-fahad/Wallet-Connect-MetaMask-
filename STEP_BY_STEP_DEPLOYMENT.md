# 📋 Step-by-Step Deployment Tutorial (For Complete Beginners)

## 🎯 Overview

This guide will take you from **zero to working NFT auction** in **30 minutes**.

No prior blockchain experience needed! I'll explain everything.

---

## 📚 What You'll Learn

By the end of this tutorial, you'll know how to:

- ✅ Deploy smart contracts to blockchain
- ✅ Mint your own NFTs
- ✅ Create NFT auctions
- ✅ Place bids on auctions
- ✅ Complete full auction cycle

---

## 🛠️ Prerequisites (5 minutes)

### Things You Need Before Starting:

#### 1. Node.js (If you don't have it)

Check if installed:
```bash
node --version
```

If not installed:
- Visit: https://nodejs.org
- Download LTS version
- Install and restart terminal

#### 2. MetaMask Mobile App

- Download from App Store / Play Store
- Create new wallet
- **SAVE YOUR SEED PHRASE** (12 words)
- Set a strong password

#### 3. Add BNB Testnet to MetaMask

In MetaMask:
1. Tap hamburger menu (≡)
2. Tap "Settings"
3. Tap "Networks"
4. Tap "Add Network"
5. Fill in:
   ```
   Network Name: BNB Testnet
   RPC URL: https://data-seed-prebsc-1-s1.binance.org:8545
   Chain ID: 97
   Currency Symbol: tBNB
   Block Explorer: https://testnet.bscscan.com
   ```
6. Tap "Save"

#### 4. Get Test Funds (FREE!)

1. Copy your wallet address from MetaMask
2. Go to: https://testnet.bnbchain.org/faucet-smart
3. Paste your address
4. Click "Give me BNB"
5. Wait 1-2 minutes
6. Check MetaMask - you should have 0.5 tBNB!

✅ **You're ready to deploy!**

---

## 🚀 Part 1: Deploy Smart Contracts (10 minutes)

### Step 1: Open Terminal

```bash
# Navigate to your project
cd /Users/fahad/Documents/FlutterProjects/wallet_connect

# Go to contracts folder
cd contracts
```

### Step 2: Install Required Packages

```bash
npm install
```

**What happens:**
```
Installing packages...
✓ hardhat
✓ @openzeppelin/contracts
✓ ethers
... (about 100 packages)

Done! (takes 2-3 minutes)
```

**Why:** These are tools needed to deploy contracts to blockchain.

### Step 3: Get Your Private Key

**⚠️ IMPORTANT: Keep this SECRET!**

1. Open MetaMask app
2. Tap three dots (⋮) on your account
3. Tap "Account Details"
4. Tap "Show Private Key"
5. Enter your password
6. Copy the key

**Example:** `abc123def456789...` (64 characters)

### Step 4: Create Environment File

```bash
# Create .env file from example
cp env-example.txt .env

# Open it for editing
nano .env
```

Paste your private key:
```env
PRIVATE_KEY=abc123def456789...
```

**Save and exit:**
- Press `Ctrl + O` (save)
- Press `Enter` (confirm)
- Press `Ctrl + X` (exit)

### Step 5: Deploy to Blockchain

```bash
npm run deploy:testnet
```

**What you'll see:**
```
🚀 Starting deployment...

📝 Deploying contracts with account: 0x1234...
💰 Account balance: 500000000000000000

📦 Deploying SimpleNFT contract...
✅ SimpleNFT deployed to: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0

📦 Deploying NFTAuction contract...
✅ NFTAuction deployed to: 0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf

🎨 Minting test NFTs...
✅ Minted 3 test NFTs to deployer

📋 DEPLOYMENT SUMMARY
============================================================
SimpleNFT Contract: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0
NFTAuction Contract: 0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf
Network: bnbTestnet
Chain ID: 97
Deployer: 0x1234...
============================================================

💾 Deployment info saved to deployment-bnbTestnet.json
```

### Step 6: Save Important Information

**✏️ WRITE THESE DOWN:**

1. **SimpleNFT Address**: `0x742d35Cc...` (your actual address)
2. **NFTAuction Address**: `0x8f86403A...` (your actual address)

You'll need these in the next part!

---

## 📱 Part 2: Update Your Flutter App (3 minutes)

### Step 1: Open Auction Service File

```bash
# From project root
cd /Users/fahad/Documents/FlutterProjects/wallet_connect

# Open in editor or nano
nano lib/services/auction_service.dart
```

### Step 2: Update Contract Addresses

Find these lines (lines 10-11):

**BEFORE:**
```dart
static const String auctionContractAddress = '0x...';
static const String nftContractAddress = '0x...';
```

**AFTER (use YOUR addresses):**
```dart
static const String auctionContractAddress = '0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf';
static const String nftContractAddress = '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0';
```

Save the file:
- Press `Ctrl + O`, `Enter`, `Ctrl + X`

---

## 🎮 Part 3: Test Everything (10 minutes)

### Test 1: Run the App

```bash
flutter run
```

**What you see:**
- 3 tabs at bottom: Wallet | Send | Auctions
- Dark theme with purple accents
- Professional UI

### Test 2: Connect Wallet

1. Tap **Wallet** tab
2. Select "BNB Testnet" from dropdown
3. Tap "Connect MetaMask"
4. MetaMask opens
5. Tap "Connect"
6. ✅ You see your address!

**Example:** `0x1234...5678`

### Test 3: Send Test Transaction

1. Tap **Send** tab
2. Default recipient is your address
3. Tap "Send Transaction"
4. Approve in MetaMask
5. Wait 10-30 seconds
6. ✅ Transaction appears in history!

### Test 4: View Auctions

1. Tap **Auctions** tab
2. See "Active Auctions" tab
3. View sample auctions (mock data for now)
4. Tap "Create Auction" tab
5. See the form

✅ **Your app is working!**

---

## 🎨 Part 4: Create Your First Real Auction (10 minutes)

### Understanding What We're Doing

When you deployed, 3 NFTs were automatically minted:
- Token ID: 1
- Token ID: 2
- Token ID: 3

Let's create an auction for NFT #1!

### Step 1: Approve Auction Contract

```bash
cd contracts
npx hardhat console --network bnbTestnet
```

**You'll see:**
```
Welcome to Node.js v18.x
Type .help for more information.
>
```

Now run these commands **one by one:**

```javascript
// 1. Get NFT contract (replace with YOUR address!)
const nft = await ethers.getContractAt(
  "SimpleNFT",
  "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0"
);

// 2. Approve auction contract (replace with YOUR address!)
const tx = await nft.approve(
  "0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf",
  1
);

// 3. Wait for confirmation
await tx.wait();

// 4. You should see:
console.log("✅ Token ID 1 approved for auction!");
```

**What this does:** Gives auction contract permission to transfer your NFT.

### Step 2: Create Auction

Still in hardhat console:

```javascript
// 1. Get auction contract (replace with YOUR address!)
const auction = await ethers.getContractAt(
  "NFTAuction",
  "0x8f86403A4DE0BB5791fa46B8e795C547942fE4Cf"
);

// 2. Create auction
const createTx = await auction.createAuction(
  "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0",  // NFT address
  1,                                 // Token ID
  ethers.parseEther("0.1"),          // Start at 0.1 ETH
  86400                              // 24 hours (in seconds)
);

// 3. Wait for confirmation
await createTx.wait();

console.log("✅ Auction created! ID: 0");
```

**What this does:** Creates auction #0 with your NFT!

### Step 3: Verify Auction Was Created

```javascript
const details = await auction.getAuction(0);

console.log("Seller:", details[0]);
console.log("NFT Contract:", details[1]);
console.log("Token ID:", details[2].toString());
console.log("Start Price:", ethers.formatEther(details[3]));
console.log("Current Bid:", ethers.formatEther(details[4]));
console.log("Time Left:", Number(details[6]) - Math.floor(Date.now() / 1000), "seconds");
```

**You should see:**
```
Seller: 0x1234... (your address)
NFT Contract: 0x742d...
Token ID: 1
Start Price: 0.1
Current Bid: 0
Time Left: 86400 seconds
```

✅ **Success! Your auction is live!**

### Step 4: Place a Bid

```javascript
// Place bid of 0.15 ETH
const bidTx = await auction.placeBid(0, {
  value: ethers.parseEther("0.15")
});

await bidTx.wait();

console.log("✅ Bid placed!");
```

### Step 5: Check Current Bid

```javascript
const details = await auction.getAuction(0);
console.log("Highest Bid:", ethers.formatEther(details[4]));
console.log("Highest Bidder:", details[5]);
```

**You should see:**
```
Highest Bid: 0.15
Highest Bidder: 0x1234... (your address)
```

✅ **You're the highest bidder!**

### Step 6: Check Time Remaining

```javascript
const timeLeft = await auction.getTimeRemaining(0);
console.log("Time remaining:", timeLeft.toString(), "seconds");
console.log("That's", Number(timeLeft) / 3600, "hours");
```

---

## 🏆 Part 5: End Auction (After 24 Hours)

### Wait for Time to Expire

**Note:** You can't end auction before time expires!

To test quickly, you can:
1. Create auction with shorter duration (e.g., 1 hour)
2. Wait for it to expire
3. Then end it

### End the Auction

```bash
npx hardhat console --network bnbTestnet
```

```javascript
const auction = await ethers.getContractAt(
  "NFTAuction",
  "YOUR_AUCTION_ADDRESS"
);

// End auction
await auction.endAuction(0);

console.log("✅ Auction ended!");
console.log("NFT transferred to winner");
console.log("Payment sent to seller");
```

### Withdraw Your Payment (If you were seller)

```javascript
// Check pending withdrawal
const pending = await auction.pendingWithdrawals(deployer.address);
console.log("You can withdraw:", ethers.formatEther(pending), "ETH");

// Withdraw
await auction.withdraw();
console.log("✅ Payment withdrawn to your wallet!");
```

### Check Your NFT Balance (If you were winner)

```javascript
const nft = await ethers.getContractAt("SimpleNFT", "NFT_ADDRESS");
const balance = await nft.balanceOf(deployer.address);
console.log("You own", balance.toString(), "NFTs");

// Check owner of specific token
const owner = await nft.ownerOf(1);
console.log("Token ID 1 owner:", owner);
```

---

## 🎓 Concepts Explained (For Beginners)

### What is a Smart Contract?

**Simple:** A program that runs on blockchain and can't be changed.

**Example:** 
- You write rules: "If someone bids highest, they win"
- Contract enforces rules automatically
- Nobody can cheat or change the rules

### What is an NFT?

**Simple:** A unique digital item you own.

**Examples:**
- Digital art
- Trading cards
- Virtual land
- Game items

**Key:** Each NFT is unique (like a serial number).

### What is "Deploying"?

**Simple:** Putting your contract on the blockchain.

**Like:**
- Writing code = Creating a website
- Deploying = Publishing it online
- Gas fees = Hosting costs

### What is "Gas"?

**Simple:** Fee to do anything on blockchain.

**Why it exists:** 
- Pays miners/validators to process your transaction
- Prevents spam
- Keeps network running

**On testnet:** Gas is FREE (using test money)!

### What is "Approve"?

**Simple:** Giving contract permission to use your NFT.

**Why needed:**
- NFTs can't be moved without owner's permission
- Auction contract needs permission to transfer your NFT
- You approve once, then create auction

**Like:** Giving your friend the key to sell your car.

---

## 📊 Visual Flow Diagram

### Complete Auction Lifecycle:

```
┌─────────────────────────────────────────────────────────┐
│                    1. PREPARATION                       │
│                                                         │
│  You              →  Mint NFT  →  You own Token ID 1   │
│  You              →  Approve   →  Contract can move it │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│                   2. CREATE AUCTION                     │
│                                                         │
│  You              →  createAuction()                    │
│  Your NFT         →  Contract (locked)                  │
│  Auction Status   →  LIVE ⏰                            │
│  Starting Bid     →  0.1 ETH                            │
│  Duration         →  24 hours                           │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│                     3. BIDDING PHASE                    │
│                                                         │
│  Alice            →  Bid 0.12 ETH  →  Highest bidder   │
│  Bob              →  Bid 0.15 ETH  →  Highest bidder   │
│  Alice refunded   ←  0.12 ETH (automatic)               │
│  Charlie          →  Bid 0.20 ETH  →  Highest bidder   │
│  Bob refunded     ←  0.15 ETH (automatic)               │
└─────────────────────────────────────────────────────────┘
                              ↓
                      ⏰ 24 Hours Pass
                              ↓
┌─────────────────────────────────────────────────────────┐
│                     4. AUCTION ENDS                     │
│                                                         │
│  Anyone           →  endAuction()                       │
│  NFT              →  Charlie (winner)                   │
│  Payment          →  You (seller): 0.195 ETH            │
│  Platform Fee     →  Contract: 0.005 ETH (2.5%)         │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│                      5. WITHDRAWAL                      │
│                                                         │
│  You              →  withdraw()                         │
│  0.195 ETH        →  Your wallet                        │
│  ✅ Complete!                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 🔍 Understanding Each Step

### 1. Mint NFT

**What:** Create a new unique digital item  
**Where:** SimpleNFT contract  
**Who:** Anyone can mint  
**Cost:** ~0.002 tBNB gas fee  

**Command:**
```javascript
await nft.mintNFT(yourAddress, "ipfs://metadata.json");
```

**Result:** You own a new NFT with unique Token ID

### 2. Approve

**What:** Give permission for auction contract to transfer your NFT  
**Where:** SimpleNFT contract  
**Who:** Only NFT owner can approve  
**Cost:** ~0.001 tBNB gas fee  

**Command:**
```javascript
await nft.approve(auctionContractAddress, tokenId);
```

**Result:** Auction contract can now move your NFT

### 3. Create Auction

**What:** Start auction with your NFT  
**Where:** NFTAuction contract  
**Who:** Only approved NFT owner  
**Cost:** ~0.003 tBNB gas fee  

**Command:**
```javascript
await auction.createAuction(nftAddress, tokenId, startPrice, duration);
```

**Result:** 
- NFT locked in contract
- Auction is live
- People can start bidding

### 4. Place Bid

**What:** Offer to buy NFT at certain price  
**Where:** NFTAuction contract  
**Who:** Anyone except seller  
**Cost:** Your bid amount + ~0.002 tBNB gas  

**Command:**
```javascript
await auction.placeBid(auctionId, { value: bidAmount });
```

**Result:**
- Your money sent to contract
- You become highest bidder
- Previous bidder refunded automatically

### 5. End Auction

**What:** Finalize auction after time expires  
**Where:** NFTAuction contract  
**Who:** Anyone (after time expires)  
**Cost:** ~0.002 tBNB gas fee  

**Command:**
```javascript
await auction.endAuction(auctionId);
```

**Result:**
- NFT sent to winner
- Payment sent to seller (minus 2.5% fee)
- Auction closed

### 6. Withdraw

**What:** Get your money from auction  
**Where:** NFTAuction contract  
**Who:** Sellers and outbid bidders  
**Cost:** ~0.001 tBNB gas fee  

**Command:**
```javascript
await auction.withdraw();
```

**Result:** Money transferred to your wallet

---

## 🎯 Practice Exercises

### Exercise 1: Create Simple Auction

**Goal:** Create auction with minimum price

```bash
# 1. Approve NFT
await nft.approve(auctionAddress, 1);

# 2. Create auction for 1 hour
await auction.createAuction(
  nftAddress,
  1,
  ethers.parseEther("0.01"),  // Very low price
  3600  // 1 hour
);

# 3. Wait 1 hour
# 4. End auction
await auction.endAuction(0);
```

### Exercise 2: Bid War

**Goal:** Practice bidding multiple times

```javascript
// 1. Create auction (as above)

// 2. Bid #1
await auction.placeBid(0, { value: ethers.parseEther("0.02") });

// 3. Bid #2 (higher)
await auction.placeBid(0, { value: ethers.parseEther("0.03") });

// 4. Check who's winning
const details = await auction.getAuction(0);
console.log("Winner:", details[5]);
```

### Exercise 3: Full Cycle

**Goal:** Complete entire auction process

1. Mint NFT
2. Approve auction contract
3. Create auction
4. Place bid
5. Wait for time
6. End auction
7. Withdraw payment
8. Check NFT ownership changed

---

## 🐛 Common Errors & How to Fix

### Error: "Insufficient funds for gas"

**Meaning:** You don't have enough tBNB for transaction  
**Fix:** Get more from faucet  
**Command:**
```bash
# Visit: https://testnet.bnbchain.org/faucet-smart
```

### Error: "Contract not approved to transfer NFT"

**Meaning:** You forgot to approve auction contract  
**Fix:** Run approve command first  
**Command:**
```javascript
await nft.approve(auctionAddress, tokenId);
```

### Error: "You don't own this NFT"

**Meaning:** Token ID doesn't belong to you  
**Fix:** Check which NFTs you own  
**Command:**
```javascript
const balance = await nft.balanceOf(yourAddress);
console.log("You own", balance.toString(), "NFTs");
```

### Error: "Bid not high enough"

**Meaning:** Your bid is lower than current bid  
**Fix:** Bid higher amount  
**Command:**
```javascript
// Check current bid first
const details = await auction.getAuction(0);
const currentBid = details[4];
console.log("Current:", ethers.formatEther(currentBid));

// Bid higher
await auction.placeBid(0, {
  value: ethers.parseEther("0.20")  // Higher than current
});
```

### Error: "Auction has not ended yet"

**Meaning:** Trying to end auction before time expires  
**Fix:** Wait for time or check time remaining  
**Command:**
```javascript
const timeLeft = await auction.getTimeRemaining(0);
console.log("Wait", timeLeft.toString(), "more seconds");
```

---

## 📝 Cheat Sheet

### Quick Commands Reference

```javascript
// ==== NFT CONTRACT ====
const nft = await ethers.getContractAt("SimpleNFT", "ADDRESS");

// Mint NFT
await nft.mintNFT(address, "uri");

// Approve
await nft.approve(auctionAddress, tokenId);

// Check owner
await nft.ownerOf(tokenId);

// Check balance
await nft.balanceOf(address);


// ==== AUCTION CONTRACT ====
const auction = await ethers.getContractAt("NFTAuction", "ADDRESS");

// Create auction
await auction.createAuction(nftAddr, tokenId, price, duration);

// Place bid
await auction.placeBid(auctionId, { value: amount });

// End auction
await auction.endAuction(auctionId);

// Withdraw funds
await auction.withdraw();

// Get auction info
await auction.getAuction(auctionId);

// Check if active
await auction.isAuctionActive(auctionId);

// Time remaining
await auction.getTimeRemaining(auctionId);


// ==== USEFUL ETHERS FUNCTIONS ====

// Convert 0.1 ETH to Wei
ethers.parseEther("0.1")

// Convert Wei to ETH
ethers.formatEther(weiAmount)

// Get your address
const [deployer] = await ethers.getSigners();
console.log(deployer.address);

// Get current time
Math.floor(Date.now() / 1000)
```

---

## 🎉 Congratulations!

### What You've Accomplished:

✅ Deployed 2 smart contracts to blockchain  
✅ Minted 3 test NFTs  
✅ Created your first auction  
✅ Placed your first bid  
✅ Understand the complete auction flow  

### What You Can Do Now:

✅ Create auctions for any NFT  
✅ Place bids on auctions  
✅ End auctions and transfer NFTs  
✅ Withdraw auction payments  
✅ Use all features via Flutter app  

### Next Steps:

1. Create more auctions (practice!)
2. Test with different amounts
3. Try shorter/longer durations
4. Invite friends to test bidding
5. Build UI features in Flutter app

---

## 📚 Additional Resources

- **README.md** - Project overview
- **AUCTION_QUICK_START.md** - 5-minute overview
- **COMPLETE_AUCTION_GUIDE.md** - Detailed beginner guide
- **NFT_AUCTION_GUIDE.md** - Technical reference

---

## 🆘 Still Confused?

### Start Here:

1. **Watch YouTube**: "What is an NFT" + "How do auctions work"
2. **Read README.md**: Project overview (start here!)
3. **Read AUCTION_QUICK_START.md**: Quick 5-min overview
4. **Follow this guide**: Step-by-step deployment
5. **Experiment**: Try commands and see what happens!

### Remember:

- **Testnet = Practice**: All money is fake, can't lose anything!
- **Try Things**: Worst case, redeploy contracts
- **Read Errors**: They usually tell you what's wrong
- **Take Breaks**: Don't rush, learn at your pace

---

## 🎨 You're a Blockchain Developer Now!

You've successfully:
- ✅ Deployed smart contracts
- ✅ Created NFT auctions
- ✅ Integrated blockchain with mobile app

**That's amazing for a beginner! Keep learning and building! 🚀**

---

Happy Developing! 🎨✨

