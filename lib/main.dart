import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/*
README (short)
- Set your WalletConnect Cloud Project ID:
  - Create a project at https://cloud.walletconnect.com and copy the Project ID.
  - Set env var before run: export WC_PROJECT_ID=YOUR_ID or put it into code below.

- Add BSC Testnet to MetaMask (mobile):
  - Open MetaMask > Networks > Add network > Add manually
  - Network Name: BSC Testnet
  - RPC URL: https://data-seed-prebsc-1-s1.binance.org:8545
  - Chain ID: 97
  - Currency Symbol: tBNB
  - Block Explorer: https://testnet.bscscan.com

- Get tBNB:
  - Use Binance official testnet faucet: https://testnet.bnbchain.org/faucet-smart

Notes
- This app uses WalletConnect v2 (Sign API) to request a session with eip155:97 and send a small transaction.
- Signing occurs in MetaMask mobile via deep link (metamask://wc?uri=...).
*/

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
      title: 'WalletConnect v2 (BSC Testnet)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WalletConnectPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WalletConnectPage extends StatefulWidget {
  const WalletConnectPage({super.key});

  @override
  State<WalletConnectPage> createState() => _WalletConnectPageState();
}

class _WalletConnectPageState extends State<WalletConnectPage> {
  late final WalletService _walletService;
  String? _address;
  String _toAddressInput = '';
  String? _lastTxHash;
  bool _connecting = false;
  bool _sending = false;
  _Network _selected = _Network.bnbTestnet;

  @override
  void initState() {
    super.initState();
    if(kDebugMode){
      textEditingController = TextEditingController(text: "0x572985CC28E2882889B6d364F53B14daD9a7F798");
    }
    _walletService = WalletService();
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    try {
      _walletService.setSelectedChain(_selected.chainId);
      final address = await _walletService.connect(context: context);
      setState(() {
        _address = address;
      });
    } catch (e) {
      _showErrorSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _sendTx() async {
    if (_address == null) {
      _showErrorSnack(context, 'Connect a wallet first');
      return;
    }
    setState(() => _sending = true);
    try {
      // final to = _toAddressInput.trim().isEmpty ? _address! : _toAddressInput.trim();
      final to = textEditingController.text;
      final txHash = await _walletService.sendTestTransaction(
        from: _address!,
        to: to,
        amountEther: 0.0001,
        context: context,
      );
      setState(() => _lastTxHash = txHash);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction sent: $txHash')),
      );
    } catch (e) {
      _showErrorSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final address = _address ?? 'Not connected';
    return Scaffold(
      appBar: AppBar(title: const Text('MetaMask + WalletConnect v2')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Network:  '),
                DropdownButton<_Network>(
                  value: _selected,
                  items: _Network.values
                      .map((n) => DropdownMenuItem(value: n, child: Text(n.label)))
                      .toList(),
                  onChanged: (n) {
                    if (n == null) return;
                    setState(() {
                      _selected = n;
                      // If already connected with a different chain, require reconnect
                      _address = null;
                      _lastTxHash = null;
                      _walletService.clearSession();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Address:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(address),
            const SizedBox(height: 16),
            TextFormField(
              controller: textEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Recipient (optional) - defaults to self',
              ),
              onChanged: (v) => _toAddressInput = v,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _connecting ? null : _connect,
                    child: _connecting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Connect MetaMask'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sending ? null : _sendTx,
                    child: _sending
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('Send 0.0001 ${_selected.symbol}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lastTxHash != null) _TxHashView(hash: _lastTxHash!, explorerBase: _selected.explorerTxBase),
            const Spacer(),
            Text('Chain: ${_selected.label} (${_selected.chainId})')
          ],
        ),
      ),
    );
  }

  void _showErrorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _TxHashView extends StatelessWidget {
  const _TxHashView({required this.hash, required this.explorerBase});
  final String hash;
  final String explorerBase;

  @override
  Widget build(BuildContext context) {
    final url = Uri.parse('$explorerBase$hash');
    return Row(
      children: [
        Expanded(
          child: SelectableText(hash),
        ),
        TextButton(
          onPressed: () async {
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: const Text('View on Explorer'),
        )
      ],
    );
  }
}

enum _Network {
  bnbTestnet,
  sepolia,
}

extension on _Network {
  String get label => this == _Network.bnbTestnet ? 'BNB Testnet' : 'Sepolia';
  String get symbol => this == _Network.bnbTestnet ? 'tBNB' : 'ETH';
  String get chainId => this == _Network.bnbTestnet ? 'eip155:97' : 'eip155:11155111';
  String get explorerTxBase => this == _Network.bnbTestnet
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

  Future<void> _ensureInitialized() async {
    if (_web3App != null) return;
    final id = dotenv.env['WC_PROJECT_ID'] ?? const String.fromEnvironment('WC_PROJECT_ID', defaultValue: '');
    if (id.isEmpty) {
      throw Exception('Missing WalletConnect Project ID. Run with --dart-define=WC_PROJECT_ID=YOUR_ID');
    }

    _web3App = await Web3App.createInstance(
      projectId: id,
      metadata: const PairingMetadata(
        name: 'WalletConnect BSC Testnet Demo',
        description: 'Minimal demo to connect MetaMask and send tx on BSC Testnet',
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
    return '0x' + bigInt.toRadixString(16);
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

