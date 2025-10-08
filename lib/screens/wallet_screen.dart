import 'package:flutter/material.dart';
import '../services/wallet_service.dart';
import '../constants/app_colors.dart';

class WalletScreen extends StatefulWidget {
  final WalletService walletService;
  final String? connectedAddress;
  final Function(String?) onAddressChanged;

  const WalletScreen({
    super.key,
    required this.walletService,
    required this.connectedAddress,
    required this.onAddressChanged,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isConnecting = false;
  Network _selectedNetwork = Network.bnbTestnet;

  Future<void> _connectWallet() async {
    setState(() => _isConnecting = true);
    try {
      widget.walletService.setSelectedChain(_selectedNetwork.chainId);
      final address = await widget.walletService.connect(context: context);
      
      if (mounted && address != null) {
        widget.onAddressChanged(address);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Wallet connected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Connection failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _disconnectWallet() async {
    widget.onAddressChanged(null);
    widget.walletService.clearSession();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🔌 Wallet disconnected')),
      );
    }
  }

  void _onNetworkChanged(Network? network) {
    if (network == null) return;
    setState(() {
      _selectedNetwork = network;
      // If already connected, disconnect to force reconnection with new network
      if (widget.connectedAddress != null) {
        widget.onAddressChanged(null);
        widget.walletService.clearSession();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Network changed. Please reconnect your wallet.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildNetworkSelector(),
                const SizedBox(height: 32),
                _buildWalletStatusCard(),
                const SizedBox(height: 32),
                _buildConnectionButton(),
                const SizedBox(height: 20),
                if (widget.connectedAddress != null) _buildDisconnectButton(),
                const SizedBox(height: 40),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradientWithOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            size: 60,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Connect Your Wallet',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose network and connect to start',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.language, color: AppColors.primaryPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'Select Network',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Network>(
                value: _selectedNetwork,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryPurple),
                dropdownColor: AppColors.darkBlue,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: Network.values.map((network) {
                  return DropdownMenuItem(
                    value: network,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: network == Network.bnbTestnet ? Colors.yellow : Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(network.label),
                        const Spacer(),
                        Text(
                          network.symbol,
                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: widget.connectedAddress == null ? _onNetworkChanged : null,
              ),
            ),
          ),
          if (widget.connectedAddress != null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '⚠️ Disconnect wallet to change network',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWalletStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradientWithOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.connectedAddress != null
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.connectedAddress != null ? Icons.check_circle : Icons.power_off,
                  color: widget.connectedAddress != null ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.connectedAddress != null ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.connectedAddress != null ? Colors.green : Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedNetwork.label,
                      style: const TextStyle(fontSize: 14, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.connectedAddress != null) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),
            const Text(
              'Wallet Address',
              style: TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkNavy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.connectedAddress!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionButton() {
    return ElevatedButton(
      onPressed: _isConnecting || widget.connectedAddress != null ? null : _connectWallet,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: AppColors.primaryPurple,
        disabledBackgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: _isConnecting
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.connectedAddress != null ? 'Connected' : 'Connect MetaMask',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }

  Widget _buildDisconnectButton() {
    return OutlinedButton(
      onPressed: _disconnectWallet,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        side: const BorderSide(color: Colors.red, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.power_off, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text(
            'Disconnect Wallet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'Network Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Chain ID', _selectedNetwork.chainId),
          const SizedBox(height: 8),
          _buildInfoRow('Currency', _selectedNetwork.symbol),
          const SizedBox(height: 8),
          _buildInfoRow('Explorer', _selectedNetwork.explorerTxBase),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white54)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

