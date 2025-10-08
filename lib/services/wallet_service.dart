import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Network {
  bnbTestnet,
  sepolia,
}

extension NetworkExtension on Network {
  String get label => this == Network.bnbTestnet ? 'BNB Testnet' : 'Sepolia';
  String get symbol => this == Network.bnbTestnet ? 'tBNB' : 'ETH';
  String get chainId => this == Network.bnbTestnet ? 'eip155:97' : 'eip155:11155111';
  String get explorerTxBase => this == Network.bnbTestnet
      ? 'https://testnet.bscscan.com/tx/'
      : 'https://sepolia.etherscan.io/tx/';
}

class WalletService {
  WalletService();

  static const String _bscTestnetChain = 'eip155:97';
  static const String _sepoliaChain = 'eip155:11155111';
  static const List<String> _methods = <String>[
    'eth_sendTransaction',
    'personal_sign',
    'eth_signTypedData',
    'eth_sign',
  ];

  Web3App? _web3App;
  SessionData? _session;
  String _selectedChain = _bscTestnetChain;

  String? get connectedAddress {
    try {
      final accounts = _session?.namespaces['eip155']?.accounts ?? const <String>[];
      if (accounts.isEmpty) return null;
      final first = accounts.first; // e.g. eip155:97:0xabc...
      final parts = first.split(':');
      return parts.length == 3 ? parts[2] : null;
    } catch (_) {
      return null;
    }
  }

  void setSelectedChain(String chainId) {
    _selectedChain = chainId;
  }

  void clearSession() {
    _session = null;
  }

  Network getSelectedNetwork() {
    return _selectedChain == _bscTestnetChain ? Network.bnbTestnet : Network.sepolia;
  }

  Future<void> _ensureInitialized() async {
    if (_web3App != null) return;
    final id = dotenv.env['WC_PROJECT_ID'] ?? const String.fromEnvironment('WC_PROJECT_ID', defaultValue: '');
    if (id.isEmpty) {
      throw Exception('Missing WalletConnect Project ID. Run with --dart-define=WC_PROJECT_ID=YOUR_ID');
    }

    _web3App = await Web3App.createInstance(
      projectId: id,
      metadata: const PairingMetadata(
        name: 'NFT Auction Marketplace',
        description: 'Bid on exclusive digital art and collectibles',
        url: 'https://walletconnect.com',
        icons: ['https://walletconnect.com/meta/favicon.ico'],
        redirect: Redirect(native: 'wc:'),
      ),
    );
  }

  Future<String?> connect({required BuildContext context}) async {
    await _ensureInitialized();
    final app = _web3App!;

    try {
      // Clean up stale pairings to avoid empty sheets in some wallets
      for (final pairing in app.core.pairing.getPairings()) {
        try {
          await app.core.pairing.disconnect(topic: pairing.topic);
        } catch (_) {}
      }

      final ConnectResponse resp = await app.connect(
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: [_selectedChain],
            methods: _methods,
            events: const ['accountsChanged', 'chainChanged'],
          ),
        },
      );

      final uri = resp.uri;
      if (uri != null) {
        await _launchWallet(uri.toString());
      }

      _session = await resp.session.future;
      return connectedAddress;
    } on WalletConnectError catch (e) {
      _rethrowFriendly(e, context);
    } on TimeoutException {
      _showSnack(context, 'Proposal expired or timed out');
    } catch (e) {
      _showSnack(context, 'Failed to connect: $e');
    }
    return null;
  }

  Future<String> sendTestTransaction({
    required String from,
    required String to,
    required double amountEther,
    required BuildContext context,
  }) async {
    if (_session == null) {
      throw Exception('No active session');
    }
    await _ensureInitialized();

    final valueWeiHex = _toHexWei(amountEther);
    final tx = {
      'from': from,
      'to': to,
      'value': valueWeiHex,
    };

    try {
      final result = await _web3App!.request(
        topic: _session!.topic,
        chainId: _selectedChain,
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [tx],
        ),
      );
      if (result is String) return result; // tx hash
      // Some wallets return JSON-RPC style object
      if (result is Map && result['result'] is String) return result['result'] as String;
      return result.toString();
    } on WalletConnectError catch (e) {
      _rethrowFriendly(e, context);
      rethrow;
    } on TimeoutException {
      _showSnack(context, 'Request timed out. Open MetaMask and check pending requests.');
      rethrow;
    } catch (e) {
      _showSnack(context, 'Failed to send tx: $e');
      rethrow;
    }
  }

  // Helpers
  Future<void> _launchWallet(String wcUri) async {
    final encoded = Uri.encodeComponent(wcUri);
    final primaryEncoded = Uri.parse('metamask://wc?uri=$encoded');
    final primaryRaw = Uri.parse('metamask://wc?uri=$wcUri');
    final fallback = Uri.parse('https://metamask.app.link/wc?uri=$encoded');

    if (await canLaunchUrl(primaryEncoded)) {
      final ok = await launchUrl(primaryEncoded, mode: LaunchMode.externalApplication);
      if (ok) return;
    }
    if (await canLaunchUrl(primaryRaw)) {
      final ok = await launchUrl(primaryRaw, mode: LaunchMode.externalApplication);
      if (ok) return;
    }
    if (!await launchUrl(fallback, mode: LaunchMode.externalApplication)) {
      throw Exception('MetaMask not installed');
    }
  }

  // Converts decimal tBNB to hex-encoded Wei string, e.g. 0x16345785d8a0000
  String _toHexWei(double amountTBNB) {
    final bigInt = BigInt.from(amountTBNB * 1e18);
    return '0x${bigInt.toRadixString(16)}';
  }

  Never _rethrowFriendly(WalletConnectError e, BuildContext context) {
    final msg = e.message?.toLowerCase() ?? '';
    if (msg.contains('user rejected')) {
      _showSnack(context, 'User rejected');
    } else if (msg.contains('expired') || msg.contains('proposal')) {
      _showSnack(context, 'Proposal expired');
    } else {
      _showSnack(context, 'Error: ${e.message ?? e.toString()}');
    }
    throw e;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

