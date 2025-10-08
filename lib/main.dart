import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Services
import 'services/wallet_service.dart';

// Screens
import 'screens/wallet_screen.dart';
import 'screens/transaction_screen.dart';
import 'screens/auction_screen.dart';

// Constants
import 'constants/app_theme.dart';
import 'constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // If .env is missing in release/profile, we fall back to dart-define only.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFT Auction - WalletConnect',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final WalletService _walletService = WalletService();
  String? _connectedAddress;

  void _updateAddress(String? address) {
    setState(() {
      _connectedAddress = address;
    });
  }

  String get _appBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Wallet Connection';
      case 1:
        return 'Test Transaction';
      case 2:
        return 'NFT Auctions';
      default:
        return 'NFT Auction App';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          WalletScreen(
            walletService: _walletService,
            connectedAddress: _connectedAddress,
            onAddressChanged: _updateAddress,
          ),
          TransactionScreen(
            walletService: _walletService,
            connectedAddress: _connectedAddress,
          ),
          AuctionScreen(
            walletService: _walletService,
            connectedAddress: _connectedAddress,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue.withOpacity(0.95),
            AppColors.mediumBlue.withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textWhite38,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_rounded),
            label: 'Send',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel_rounded),
            label: 'Auctions',
          ),
        ],
      ),
    );
  }
}
