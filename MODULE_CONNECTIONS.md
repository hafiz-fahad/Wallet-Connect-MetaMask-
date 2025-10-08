# 🔗 Module Connections & Data Flow

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         main.dart                           │
│                    (App Entry Point)                        │
│  - Initializes app                                          │
│  - Sets up theme                                            │
│  - Manages bottom navigation                                │
│  - Holds WalletService instance                             │
└────────────┬────────────────────────────────────────────────┘
             │
             ├─────────────┬─────────────┬──────────────────┐
             ▼             ▼             ▼                  ▼
    ┌────────────┐ ┌──────────────┐ ┌───────────┐ ┌───────────────┐
    │ HomeScreen │ │ Marketplace  │ │  Profile  │ │ NFTDetail     │
    │            │ │   Screen     │ │  Screen   │ │  Screen       │
    └─────┬──────┘ └──────┬───────┘ └─────┬─────┘ └───────┬───────┘
          │               │                │               │
          └───────────────┴────────────────┴───────────────┘
                          │
          ┌───────────────┴───────────────┐
          ▼                               ▼
    ┌──────────────┐              ┌──────────────┐
    │   Services   │              │   Widgets    │
    │              │              │              │
    │ - Wallet     │              │ - NFTCard    │
    │ - NFTData    │              │ - WalletCard │
    └──────┬───────┘              │ - StatCard   │
           │                      │ - BidHistory │
           ▼                      └──────────────┘
    ┌──────────────┐                     │
    │   Models     │◄────────────────────┘
    │              │
    │ - NFT        │
    │ - Bid        │
    └──────────────┘
           │
           ▼
    ┌──────────────┐
    │  Constants   │
    │              │
    │ - Colors     │
    │ - Theme      │
    └──────────────┘
```

## 🔄 Data Flow Examples

### 1. **User Connects Wallet**

```
User taps "Connect Wallet"
         │
         ▼
HomeScreen._connectWallet()
         │
         ▼
WalletService.connect()
         │
         ├─ Initialize Web3App
         ├─ Clean up stale pairings
         ├─ Create connection request
         └─ Launch MetaMask
         │
         ▼
WalletService.connectedAddress
         │
         ▼
HomeScreen._address (setState)
         │
         ▼
MainScreen._connectedAddress (callback)
         │
         ▼
MarketplaceScreen & ProfileScreen
(receive updated address)
```

### 2. **User Browses NFTs**

```
User opens Marketplace tab
         │
         ▼
MarketplaceScreen.build()
         │
         ▼
NFTDataService.getAllNFTs()
         │
         ├─ Generate mock NFT data
         ├─ Create NFT models
         └─ Generate random bids
         │
         ▼
MarketplaceScreen._filteredNFTs
         │
         ▼
GridView with NFTCard widgets
         │
         ▼
User sees NFT grid
```

### 3. **User Places Bid**

```
User taps NFT card
         │
         ▼
Navigator.push(NFTDetailScreen)
         │
         ▼
NFTDetailScreen displays:
  - NFT info from NFT model
  - Bid history from Bid models
  - Live countdown timer
         │
         ▼
User enters bid & taps "Place Bid"
         │
         ▼
NFTDetailScreen._placeBid()
         │
         ├─ Validate wallet connected
         ├─ Validate bid amount
         ├─ Simulate transaction
         └─ Show success message
         │
         ▼
Navigator.pop() back to Marketplace
```

## 📦 Module Dependencies

### **main.dart** depends on:
- `services/wallet_service.dart` - For wallet functionality
- `screens/*.dart` - All screen widgets
- `constants/app_theme.dart` - App theme
- `constants/app_colors.dart` - Color definitions

### **HomeScreen** depends on:
- `models/nft_model.dart` - NFT data structure
- `services/wallet_service.dart` - Wallet operations
- `services/nft_data_service.dart` - NFT data
- `widgets/wallet_card.dart` - Wallet display
- `widgets/stat_card.dart` - Stats display
- `screens/nft_detail_screen.dart` - Navigation target

### **MarketplaceScreen** depends on:
- `models/nft_model.dart` - NFT data structure
- `services/nft_data_service.dart` - NFT data
- `widgets/nft_card.dart` - NFT display
- `screens/nft_detail_screen.dart` - Navigation target

### **ProfileScreen** depends on:
- `models/nft_model.dart` - NFT data structure
- `services/nft_data_service.dart` - User data

### **NFTDetailScreen** depends on:
- `models/nft_model.dart` - NFT data structure
- `services/wallet_service.dart` - Transaction handling
- `widgets/bid_history_item.dart` - Bid display

### **Widgets** depend on:
- `models/*.dart` - Data structures
- `constants/*.dart` - Styling

### **Services** depend on:
- `models/*.dart` - Data structures
- External packages (WalletConnect, etc.)

### **Models** depend on:
- Nothing! (Pure data classes)

### **Constants** depend on:
- Nothing! (Pure configuration)

## 🎯 Key Design Principles

### 1. **Unidirectional Data Flow**
```
Services → Models → Widgets → UI
```

### 2. **Separation of Concerns**
```
UI Logic (Screens) ≠ Business Logic (Services) ≠ Data (Models)
```

### 3. **Dependency Injection**
```dart
// Services injected from main.dart
HomeScreen(walletService: _walletService)
```

### 4. **State Management**
```dart
// State at screen level
class _HomeScreenState extends State<HomeScreen> {
  String? _address; // Local state
  
  // Update via setState
  setState(() => _address = newAddress);
  
  // Propagate up via callback
  widget.onAddressChanged(newAddress);
}
```

## 🔌 Integration Points

### **WalletConnect Integration**
```
WalletService
  ├─ Web3App initialization
  ├─ Session management
  ├─ Transaction requests
  └─ MetaMask deep linking
```

### **NFT Data**
```
NFTDataService
  ├─ Generate mock NFTs
  ├─ Filter by category
  ├─ Search functionality
  └─ User's NFTs & bids
```

### **Theme System**
```
AppTheme + AppColors
  ├─ Used by all UI components
  ├─ Consistent styling
  └─ Easy to modify globally
```

## 🚀 Adding New Features

### Example: Adding "Favorites" Feature

#### 1. **Update Models**
```dart
// models/nft_model.dart
class NFT {
  // ... existing fields
  final bool isFavorite;
}
```

#### 2. **Update Service**
```dart
// services/nft_data_service.dart
static List<NFT> getFavoriteNFTs() {
  return getAllNFTs().where((nft) => nft.isFavorite).toList();
}
```

#### 3. **Create Widget**
```dart
// widgets/favorite_button.dart
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  // ... implementation
}
```

#### 4. **Add to Screen**
```dart
// screens/nft_detail_screen.dart
FavoriteButton(
  isFavorite: widget.nft.isFavorite,
  onToggle: _toggleFavorite,
)
```

#### 5. **Add to Profile**
```dart
// screens/profile_screen.dart
Tab(text: 'Favorites'),
// Show favorite NFTs
```

## 🔄 State Flow Example

### Wallet Connection State Flow

```
1. Initial State
   ├─ _connectedAddress = null (MainScreen)
   └─ _address = null (HomeScreen)

2. User Connects
   ├─ HomeScreen calls WalletService.connect()
   ├─ WalletService returns address
   └─ HomeScreen updates _address

3. Propagate Up
   ├─ HomeScreen calls widget.onAddressChanged(address)
   ├─ MainScreen updates _connectedAddress
   └─ MainScreen rebuilds with new state

4. Propagate Down
   ├─ MarketplaceScreen receives connectedAddress
   ├─ ProfileScreen receives connectedAddress
   └─ Both screens update UI accordingly
```

## 📝 File Import Guide

### Typical Import Order in a Screen:

```dart
// 1. Dart/Flutter packages
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Third-party packages
import 'package:url_launcher/url_launcher.dart';

// 3. Models
import '../models/nft_model.dart';
import '../models/bid_model.dart';

// 4. Services
import '../services/wallet_service.dart';
import '../services/nft_data_service.dart';

// 5. Constants
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';

// 6. Widgets
import '../widgets/nft_card.dart';
import '../widgets/wallet_card.dart';

// 7. Screens (for navigation)
import 'nft_detail_screen.dart';
```

## 🎨 Styling Consistency

### Using Constants Everywhere

```dart
// ❌ BAD - Hardcoded colors
Container(
  color: Color(0xFF9D4EDD),
)

// ✅ GOOD - Use constants
Container(
  color: AppColors.primaryPurple,
)

// ❌ BAD - Inline gradient
decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0xFF9D4EDD), Color(0xFF7209B7)],
  ),
)

// ✅ GOOD - Use constant gradient
decoration: BoxDecoration(
  gradient: AppColors.primaryGradient,
)
```

---

This architecture ensures:
- ✅ **Maintainability**: Easy to find and modify code
- ✅ **Testability**: Each module can be tested independently
- ✅ **Scalability**: Add features without breaking existing code
- ✅ **Reusability**: Share components across the app
- ✅ **Readability**: Clear structure and naming

