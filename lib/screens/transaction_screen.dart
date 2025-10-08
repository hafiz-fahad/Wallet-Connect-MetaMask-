import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';
import '../constants/app_colors.dart';

class TransactionScreen extends StatefulWidget {
  final WalletService walletService;
  final String? connectedAddress;

  const TransactionScreen({
    super.key,
    required this.walletService,
    required this.connectedAddress,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _recipientController = TextEditingController();
  bool _isSending = false;
  final List<Map<String, dynamic>> _transactionHistory = [];

  @override
  void initState() {
    super.initState();
    // Set default recipient to user's own address
    if (widget.connectedAddress != null) {
      _recipientController.text = widget.connectedAddress!;
    }
  }

  @override
  void didUpdateWidget(TransactionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update recipient when address changes
    if (widget.connectedAddress != oldWidget.connectedAddress) {
      if (widget.connectedAddress != null) {
        _recipientController.text = widget.connectedAddress!;
      }
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  Future<void> _sendTransaction() async {
    if (widget.connectedAddress == null) {
      _showSnackBar('Please connect your wallet first', isError: true);
      return;
    }

    final recipient = _recipientController.text.trim();
    if (recipient.isEmpty) {
      _showSnackBar('Please enter a recipient address', isError: true);
      return;
    }

    if (!_isValidAddress(recipient)) {
      _showSnackBar('Invalid Ethereum address', isError: true);
      return;
    }

    setState(() => _isSending = true);

    try {
      final txHash = await widget.walletService.sendTestTransaction(
        from: widget.connectedAddress!,
        to: recipient,
        amountEther: 0.0001,
        context: context,
      );

      if (mounted) {
        setState(() {
          _transactionHistory.insert(0, {
            'hash': txHash,
            'to': recipient,
            'amount': '0.0001',
            'timestamp': DateTime.now(),
            'status': 'success',
          });
        });

        _showSnackBar('✅ Transaction sent successfully!', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Transaction failed: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  bool _isValidAddress(String address) {
    // Basic Ethereum address validation
    return address.startsWith('0x') && address.length == 42;
  }

  void _showSnackBar(String message, {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Colors.green
            : isError
                ? Colors.red
                : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _setMyAddress() {
    if (widget.connectedAddress != null) {
      _recipientController.text = widget.connectedAddress!;
    }
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
                const SizedBox(height: 32),
                if (widget.connectedAddress == null)
                  _buildNotConnectedCard()
                else ...[
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildTransactionForm(),
                  const SizedBox(height: 32),
                  if (_transactionHistory.isNotEmpty) ...[
                    _buildHistoryHeader(),
                    const SizedBox(height: 16),
                    _buildTransactionHistory(),
                  ],
                ],
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
            Icons.send_rounded,
            size: 60,
            color: AppColors.primaryPurple,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Test Transaction',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Send 0.0001 tBNB test transaction',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildNotConnectedCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Wallet Not Connected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please connect your wallet from the Wallet tab to send transactions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradientWithOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connected Address',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.connectedAddress!.substring(0, 10)}...${widget.connectedAddress!.substring(widget.connectedAddress!.length - 8)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primaryPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'Recipient Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _recipientController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: '0x...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppColors.darkNavy,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryPurple.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste, color: AppColors.primaryPurple, size: 20),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    _recipientController.text = data!.text!;
                  }
                },
                tooltip: 'Paste',
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _setMyAddress,
              icon: const Icon(Icons.account_circle, size: 18),
              label: const Text('Send to My Address'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '0.0001 ${widget.walletService.getSelectedNetwork().symbol}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Test Amount',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppColors.primaryPurple,
                disabledBackgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSending
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Send Transaction',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      children: [
        const Icon(Icons.history, color: AppColors.primaryPurple, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Text(
          '${_transactionHistory.length}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      children: _transactionHistory.map((tx) => _buildTransactionItem(tx)).toList(),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final DateTime timestamp = tx['timestamp'];
    final String timeAgo = _getTimeAgo(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To: ${tx['to'].substring(0, 10)}...${tx['to'].substring(tx['to'].length - 8)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${tx['amount']} ${widget.walletService.getSelectedNetwork().symbol}',
                style: const TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Tx Hash: ',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Expanded(
                child: Text(
                  '${tx['hash'].substring(0, 10)}...${tx['hash'].substring(tx['hash'].length - 8)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final network = widget.walletService.getSelectedNetwork();
                  final url = '${network.explorerTxBase}${tx['hash']}';
                  _showSnackBar('View on explorer: $url');
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryPurple,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

