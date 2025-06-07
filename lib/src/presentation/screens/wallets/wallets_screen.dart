import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:crysta_pay/src/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:crysta_pay/src/presentation/widgets/wallet/filter_chips.dart';
import 'package:crysta_pay/src/presentation/widgets/wallet/wallet_card.dart';
import 'package:crysta_pay/src/presentation/widgets/wallet/wallet_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    context.read<WalletBloc>().add(LoadWallets());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<WalletModel> _filterWallets(List<WalletModel> wallets) {
    switch (_selectedFilter) {
      case 'Connected':
        return wallets.where((w) => w.status == WalletStatus.active).toList();
      case 'Ethereum':
        return wallets.where((w) => w.type == CryptoType.eth).toList();
      case 'Bitcoin':
        return wallets.where((w) => w.type == CryptoType.btc).toList();
      case 'Hardware':
        return wallets.where((w) => w.isHardwareWallet).toList();
      default:
        return wallets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: BlocConsumer<WalletBloc, WalletState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () => context.read<WalletBloc>().add(LoadWallets()),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<WalletBloc>().add(RefreshWalletBalances());
                  },
                  color: Colors.blue,
                  backgroundColor: const Color(0xFF1A1A1A),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(context)),
                      SliverToBoxAdapter(child: _buildStatsCard(state)),
                      SliverToBoxAdapter(child: _buildFilterChips()),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        sliver: state.isLoading
                            ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                            : _buildWalletList(state),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: _buildAddWalletButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Text(
            'My Wallets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const Text('Notifications feature not yet implemented') as SnackBar,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(WalletState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${state.totalBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.2),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Wallets',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.wallets.length}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FilterChips(
        selectedFilter: _selectedFilter,
        onFilterSelected: _onFilterSelected,
      ),
    );
  }

  Widget _buildWalletList(WalletState state) {
    final filteredWallets = _filterWallets(state.wallets);
    if (filteredWallets.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFilter == 'All' ? 'No Wallets Yet' : 'No $_selectedFilter Wallets',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a wallet to get started',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => WalletCard(wallet: filteredWallets[index]),
        childCount: filteredWallets.length,
      ),
    );
  }

  Widget _buildAddWalletButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => showWalletOptionsBottomSheet(context),
      backgroundColor: Colors.blue,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Add Wallet',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}