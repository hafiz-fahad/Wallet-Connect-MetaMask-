import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../services/wallet_service.dart';
import '../constants/app_colors.dart';

class AuctionScreen extends StatefulWidget {
  final WalletService walletService;
  final String? connectedAddress;

  const AuctionScreen({
    super.key,
    required this.walletService,
    required this.connectedAddress,
  });

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Contract addresses (DEPLOYED)
  static const String _nftContractAddress =
      '0x8bd069d0141c8f866652f55cf1964F6C843Ce3f2';
  static const String _auctionContractAddress =
      '0x57856838dEEeBa2d621FC380a1eBd0586a345FCD';
  static const String _rpcUrl = 'https://data-seed-prebsc-1-s1.binance.org:8545';

  // Loading states
  bool _isCreatingAuction = false;
  bool _isPlacingBid = false;
  bool _isLoadingAuctions = false;

  // Real auction data from blockchain
  List<Map<String, dynamic>> _realAuctions = [];
  int _totalAuctions = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAuctions();
  }

  Future<void> _loadAuctions() async {
    if (widget.connectedAddress == null) return;

    setState(() => _isLoadingAuctions = true);

    try {
      final client = Web3Client(_rpcUrl, http.Client());
      
      // Get auction contract
      final auctionContract = DeployedContract(
        ContractAbi.fromJson(_auctionContractABI, 'NFTAuction'),
        EthereumAddress.fromHex(_auctionContractAddress),
      );

      // Get auction counter to know how many auctions exist
      final auctionCounterFunction = auctionContract.function('auctionCounter');
      final counterResult = await client.call(
        contract: auctionContract,
        function: auctionCounterFunction,
        params: [],
      );
      
      _totalAuctions = (counterResult[0] as BigInt).toInt();

      // Fetch all auctions
      final auctions = <Map<String, dynamic>>[];
      final getAuctionFunction = auctionContract.function('getAuction');
      final isActiveFunction = auctionContract.function('isAuctionActive');
      
      for (int i = 0; i < _totalAuctions; i++) {
        try {
          final auctionData = await client.call(
            contract: auctionContract,
            function: getAuctionFunction,
            params: [BigInt.from(i)],
          );

          final isActiveData = await client.call(
            contract: auctionContract,
            function: isActiveFunction,
            params: [BigInt.from(i)],
          );

          final seller = (auctionData[0] as EthereumAddress).hex;
          final nftContract = (auctionData[1] as EthereumAddress).hex;
          final tokenId = (auctionData[2] as BigInt).toInt();
          final startPrice = auctionData[3] as BigInt;
          final highestBid = auctionData[4] as BigInt;
          final highestBidder = (auctionData[5] as EthereumAddress).hex;
          final endTime = (auctionData[6] as BigInt).toInt();
          final ended = auctionData[7] as bool;
          final cancelled = auctionData[8] as bool;
          final isActive = isActiveData[0] as bool;

          if (!ended && !cancelled) {
            auctions.add({
              'id': i,
              'name': 'NFT #$tokenId',
              'nftContract': nftContract,
              'tokenId': tokenId,
              'seller': seller,
              'startPrice': _weiToEth(startPrice),
              'currentBid': _weiToEth(highestBid),
              'highestBidder': highestBidder,
              'endTime': endTime,
              'isActive': isActive,
              'ended': ended,
              'cancelled': cancelled,
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading auction $i: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _realAuctions = auctions;
        });
      }

      client.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading auctions: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingAuctions = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveAuctionsTab(),
                    _buildCreateAuctionTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradientWithOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_rounded,
              size: 60,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'NFT Auctions',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create auctions and place bids',
            style: TextStyle(fontSize: 16, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.list_rounded), text: 'Active Auctions'),
          Tab(icon: Icon(Icons.add_circle_outline), text: 'Create Auction'),
        ],
      ),
    );
  }

  // Active Auctions Tab
  Widget _buildActiveAuctionsTab() {
    if (widget.connectedAddress == null) {
      return _buildNotConnectedMessage();
    }

    return RefreshIndicator(
      onRefresh: _loadAuctions,
      color: AppColors.primaryPurple,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildRefreshButton(),
          const SizedBox(height: 24),
          if (_isLoadingAuctions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.primaryPurple),
              ),
            )
          else if (_realAuctions.isEmpty)
            _buildNoAuctionsMessage()
          else
            ..._realAuctions.map((auction) => _buildAuctionCard(auction)),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Found $_totalAuctions auction(s) on blockchain',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryPurple),
            onPressed: _loadAuctions,
            tooltip: 'Refresh auctions',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'How NFT Auctions Work',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            '1.',
            'NFT owner creates auction with start price & duration',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            '2.',
            'Users place bids (must be higher than current bid)',
          ),
          const SizedBox(height: 8),
          _buildInfoRow('3.', 'When time ends, highest bidder wins the NFT'),
          const SizedBox(height: 8),
          _buildInfoRow('4.', 'Seller gets payment, winner gets NFT'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildAuctionCard(Map<String, dynamic> auction) {
    final bool isActive = auction['isActive'] as bool;
    final String currentBid = auction['currentBid'] as String;
    final int endTime = auction['endTime'] as int;
    final String timeLeft = _getTimeRemaining(endTime);
    final String seller = auction['seller'] as String;
    final String shortSeller = '${seller.substring(0, 6)}...${seller.substring(seller.length - 4)}';
    
    // Determine total bids (if currentBid > 0, there's at least 1 bid)
    final hasBids = double.parse(currentBid) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isActive
                  ? AppColors.primaryPurple.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradientWithOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  color: AppColors.primaryPurple,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Auction ID: ${auction['id']} | Token ID: ${auction['tokenId']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),

          // Auction Details
          Row(
            children: [
              Expanded(
                child: _buildDetailColumn(
                  'Current Bid',
                  hasBids ? '$currentBid ETH' : 'No bids yet',
                  AppColors.primaryPurple,
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  'Time Left',
                  timeLeft,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildDetailColumn(
                  'Start Price',
                  '${auction['startPrice']} ETH',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Seller Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Seller:',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    shortSeller,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isActive ? () => _showBidDialog(auction) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryPurple,
                disabledBackgroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.gavel, size: 20),
              label: Text(
                isActive ? 'Place Bid' : 'Auction Ended',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNoAuctionsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Active Auctions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first auction or wait for others',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  // Create Auction Tab
  Widget _buildCreateAuctionTab() {
    if (widget.connectedAddress == null) {
      return _buildNotConnectedMessage();
    }

    return _buildCreateAuctionForm();
  }

  Widget _buildCreateAuctionForm() {
    final nftAddressController =
        kDebugMode
            ? TextEditingController(text: _nftContractAddress)
            : TextEditingController();
    final tokenIdController = TextEditingController();
    final startPriceController = TextEditingController();
    final durationController = TextEditingController(text: '24');

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildGuideCard(),
        const SizedBox(height: 24),
        _buildFormCard(
          title: 'Create New Auction',
          children: [
            _buildTextField(
              controller: nftAddressController,
              label: 'NFT Contract Address',
              hint: '0x...',
              icon: Icons.description,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: tokenIdController,
              label: 'Token ID',
              hint: '1',
              icon: Icons.tag,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: startPriceController,
              label: 'Starting Price (ETH)',
              hint: '0.1',
              icon: Icons.payments,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: durationController,
              label: 'Duration (hours)',
              hint: '24',
              icon: Icons.access_time,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _buildEstimateCard(
              startPriceController.text,
              durationController.text,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isCreatingAuction
                        ? null
                        : () => _createAuction(
                          nftAddressController.text,
                          tokenIdController.text,
                          startPriceController.text,
                          durationController.text,
                        ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.primaryPurple,
                  disabledBackgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon:
                    _isCreatingAuction
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.add_circle, size: 24),
                label: Text(
                  _isCreatingAuction ? 'Creating...' : 'Create Auction',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuideCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Before Creating an Auction',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideStep('1', 'You already have 3 NFTs (Token IDs: 1, 2, 3)'),
          const SizedBox(height: 8),
          _buildGuideStep('2', 'Approve NFT in Hardhat console (see guide)'),
          const SizedBox(height: 8),
          _buildGuideStep('3', 'Fill form with your NFT details'),
          const SizedBox(height: 8),
          _buildGuideStep('4', 'Tap Create Auction & approve in MetaMask'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'IMPORTANT: Approve NFT first using Hardhat console or transaction will fail!',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _showApprovalGuide,
            icon: const Icon(Icons.help_outline, size: 16),
            label: const Text('How to Approve NFT?'),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard({
    required String title,
    required List<Widget> children,
  }) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryPurple),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppColors.darkNavy,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 2,
              ),
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.paste,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              onPressed: () async {
                final data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  controller.text = data!.text!;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimateCard(String startPrice, String duration) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auction Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Starting Price', '$startPrice ETH'),
          const SizedBox(height: 8),
          _buildSummaryRow('Duration', '$duration hours'),
          const SizedBox(height: 8),
          _buildSummaryRow('Platform Fee', '2.5%'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotConnectedMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
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
              'Please connect your wallet from the Wallet tab to view and create auctions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  // Actions
  void _showBidDialog(Map<String, dynamic> auction) {
    final bidController = TextEditingController();
    final currentBid = double.parse(auction['currentBid']);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.darkBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Place Bid on ${auction['name']}',
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Bid: ${auction['currentBid']} ETH',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Minimum Bid: ${currentBid + 0.01} ETH',
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bidController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Your Bid (ETH)',
                    labelStyle: const TextStyle(color: Colors.white54),
                    hintText: '${currentBid + 0.1}',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: AppColors.darkNavy,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _placeBid(auction['id'], bidController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                ),
                child: const Text('Place Bid'),
              ),
            ],
          ),
    );
  }

  Future<void> _placeBid(int auctionId, String bidAmount) async {
    if (widget.connectedAddress == null) {
      _showMessage('Please connect your wallet first', isError: true);
      return;
    }

    final bidValue = double.tryParse(bidAmount);
    if (bidValue == null || bidValue <= 0) {
      _showMessage('Invalid bid amount', isError: true);
      return;
    }

    setState(() => _isPlacingBid = true);

    try {
      // Convert ETH to Wei (hex string)
      final weiAmount = _ethToWeiHex(bidValue);

      // Build transaction data for placeBid(uint256 auctionId)
      // Function signature: placeBid(uint256)
      // Selector: 0x1998aeef
      final paddedAuctionId = auctionId.toRadixString(16).padLeft(64, '0');
      final data = '0x1998aeef$paddedAuctionId';

      // Send transaction via WalletConnect
      final txHash = await widget.walletService.sendContractTransaction(
        from: widget.connectedAddress!,
        to: _auctionContractAddress,
        data: data,
        value: weiAmount,
        context: context,
      );

      if (mounted) {
        _showMessage(
          '✅ Bid placed successfully! TX: ${txHash.substring(0, 10)}...',
          isSuccess: true,
        );
        
        // Reload auctions to show updated bid
        _loadAuctions();
      }
    } catch (e) {
      if (mounted) {
        _showMessage('❌ Failed to place bid: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPlacingBid = false);
    }
  }

  Future<void> _createAuction(
    String nftAddress,
    String tokenId,
    String startPrice,
    String duration,
  ) async {
    // Validation
    if (nftAddress.isEmpty ||
        tokenId.isEmpty ||
        startPrice.isEmpty ||
        duration.isEmpty) {
      _showMessage('Please fill all required fields', isError: true);
      return;
    }

    if (widget.connectedAddress == null) {
      _showMessage('Please connect your wallet first', isError: true);
      return;
    }

    // Validate address format
    if (!nftAddress.startsWith('0x') || nftAddress.length != 42) {
      _showMessage('Invalid NFT contract address', isError: true);
      return;
    }

    final tokenIdNum = int.tryParse(tokenId);
    if (tokenIdNum == null || tokenIdNum < 1) {
      _showMessage('Invalid token ID', isError: true);
      return;
    }

    final startPriceNum = double.tryParse(startPrice);
    if (startPriceNum == null || startPriceNum <= 0) {
      _showMessage('Invalid start price', isError: true);
      return;
    }

    final durationNum = int.tryParse(duration);
    if (durationNum == null || durationNum < 1) {
      _showMessage('Invalid duration', isError: true);
      return;
    }

    setState(() => _isCreatingAuction = true);

    try {
      // Build transaction data for createAuction(address,uint256,uint256,uint256)
      // Function signature: createAuction(address,uint256,uint256,uint256)
      // Selector: 0x2f17c1c6

      // Encode parameters
      final addressParam = nftAddress
          .substring(2)
          .padLeft(64, '0'); // Remove 0x and pad
      final tokenIdParam = tokenIdNum.toRadixString(16).padLeft(64, '0');
      final startPriceWei = _ethToWeiBigInt(startPriceNum);
      final startPriceParam = startPriceWei.toRadixString(16).padLeft(64, '0');
      final durationSeconds = durationNum * 3600; // Convert hours to seconds
      final durationParam = durationSeconds.toRadixString(16).padLeft(64, '0');

      final data =
          '0x2f17c1c6$addressParam$tokenIdParam$startPriceParam$durationParam';

      // Send transaction via WalletConnect
      final txHash = await widget.walletService.sendContractTransaction(
        from: widget.connectedAddress!,
        to: _auctionContractAddress,
        data: data,
        value: '0x0',
        // No value sent, just creating auction
        context: context,
      );

      if (mounted) {
        _showMessage(
          '✅ Auction created successfully! TX: ${txHash.substring(0, 10)}...',
          isSuccess: true,
        );

        // Reload auctions to show the new one
        _loadAuctions();

        // Show instructions
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: AppColors.darkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  '🎉 Auction Created!',
                  style: TextStyle(color: Colors.white),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your auction is now live on the blockchain!',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Transaction Hash:',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      txHash,
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'View on Explorer:',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      'https://testnet.bscscan.com/tx/$txHash',
                      style: const TextStyle(color: Colors.blue, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                    ),
                    child: const Text('Great!'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          '❌ Failed to create auction: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingAuction = false);
    }
  }

  // Helper methods
  String _ethToWeiHex(double ethAmount) {
    final weiAmount = BigInt.from(ethAmount * 1e18);
    return '0x${weiAmount.toRadixString(16)}';
  }

  BigInt _ethToWeiBigInt(double ethAmount) {
    return BigInt.from(ethAmount * 1e18);
  }

  void _showMessage(
    String message, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isSuccess
                ? Colors.green
                : isError
                ? Colors.red
                : Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showApprovalGuide() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.darkBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              '✅ How to Approve NFT',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Before creating an auction, you MUST approve the auction contract to transfer your NFT.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Open Terminal and run:',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'cd contracts',
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          'npx hardhat console --network bnbTestnet',
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Then run these commands:',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'const nft = await ethers.getContractAt("SimpleNFT", "$_nftContractAddress");',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'await nft.approve("$_auctionContractAddress", 1);',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Replace "1" with your Token ID. You can approve Token IDs 1, 2, or 3 (you own all three).',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                ),
                child: const Text('Got it!'),
              ),
            ],
          ),
    );
  }

  void _showDetailedGuide() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.darkBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Complete Auction Guide',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGuideSection(
                    '📝 Step 1: Deploy Contracts',
                    'Deploy NFTAuction.sol and SimpleNFT.sol contracts to testnet. See COMPLETE_AUCTION_GUIDE.md for instructions.',
                  ),
                  _buildGuideSection(
                    '🎨 Step 2: Mint an NFT',
                    'Use SimpleNFT contract to mint a test NFT. You\'ll need the token ID for creating auction.',
                  ),
                  _buildGuideSection(
                    '✅ Step 3: Approve Contract',
                    'Approve the auction contract to transfer your NFT. This is required before creating auction.',
                  ),
                  _buildGuideSection(
                    '🚀 Step 4: Create Auction',
                    'Fill the form with NFT address, token ID, start price, and duration. Then create auction!',
                  ),
                  _buildGuideSection(
                    '💰 Step 5: Place Bids',
                    'Other users can place bids. Each bid must be higher than the current bid.',
                  ),
                  _buildGuideSection(
                    '🏆 Step 6: End Auction',
                    'When time expires, anyone can end the auction. Winner gets NFT, seller gets payment.',
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                ),
                child: const Text('Got it!'),
              ),
            ],
          ),
    );
  }

  Widget _buildGuideSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Helper method to convert Wei to ETH
  String _weiToEth(BigInt wei) {
    if (wei == BigInt.zero) return '0';
    final eth = wei.toDouble() / 1e18;
    return eth.toStringAsFixed(4);
  }

  // Helper method to get time remaining string
  String _getTimeRemaining(int endTime) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remaining = endTime - now;
    
    if (remaining <= 0) return 'Ended';
    
    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Minimal ABI for reading auction data
  static const String _auctionContractABI = '''
  [
    {
      "inputs": [],
      "name": "auctionCounter",
      "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "_auctionId", "type": "uint256"}],
      "name": "getAuction",
      "outputs": [
        {"internalType": "address", "name": "seller", "type": "address"},
        {"internalType": "address", "name": "nftContract", "type": "address"},
        {"internalType": "uint256", "name": "tokenId", "type": "uint256"},
        {"internalType": "uint256", "name": "startPrice", "type": "uint256"},
        {"internalType": "uint256", "name": "highestBid", "type": "uint256"},
        {"internalType": "address", "name": "highestBidder", "type": "address"},
        {"internalType": "uint256", "name": "endTime", "type": "uint256"},
        {"internalType": "bool", "name": "ended", "type": "bool"},
        {"internalType": "bool", "name": "cancelled", "type": "bool"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [{"internalType": "uint256", "name": "_auctionId", "type": "uint256"}],
      "name": "isAuctionActive",
      "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    }
  ]
  ''';
}
