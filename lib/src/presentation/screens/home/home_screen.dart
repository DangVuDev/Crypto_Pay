import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:crysta_pay/src/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:crysta_pay/src/presentation/widgets/wallet/filter_chips.dart';
import 'package:crysta_pay/src/presentation/widgets/wallet/wallet_card.dart';
import 'package:crysta_pay/src/presentation/widgets/wallet/wallet_dialogs.dart';
import 'package:crysta_pay/src/presentation/widgets/wallet/wallet_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Configuration class for consistent styling and constants
class WalletScreenConfig {
  static const Color backgroundColor = Color(0xFF121212);
  static const Color gradientStart = Color(0xFF1A1A1A);
  static const Color gradientEnd = Color(0xFF121212);
  static const double padding = 24.0;
  static const double borderRadius = 16.0;
  static const String fontFamily = 'Poppins';
  static const Color textColor = Colors.white;
}

// WalletsScreen widget to display and manage wallets
class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'All';
  String _sortBy = 'Name'; // Default sort by name
  int _unreadNotifications = 3; // Mock unread notifications count

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

  // Handle filter selection
  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
      _animationController.reset();
      _animationController.forward();
    });
  }

  // Handle sort selection
  void _onSortSelected(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _animationController.reset();
      _animationController.forward();
    });
  }

  // Filter wallets based on selected filter
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

  // Sort wallets based on selected sort option
  List<WalletModel> _sortWallets(List<WalletModel> wallets) {
    final filtered = _filterWallets(wallets);
    if (_sortBy == 'Balance') {
      return filtered..sort((a, b) => b.balance.compareTo(a.balance));
    }
    return filtered..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WalletScreenConfig.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [WalletScreenConfig.gradientStart, WalletScreenConfig.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: BlocConsumer<WalletBloc, WalletState>(
              listener: (context, state) {
                if (state.error != null) {
                  _showErrorSnackBar(context, state.error!);
                }
              },
              builder: (context, state) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<WalletBloc>().add(RefreshWalletBalances());
                    await Future.delayed(const Duration(milliseconds: 500)); // Smooth refresh
                  },
                  color: Colors.blue,
                  backgroundColor: WalletScreenConfig.gradientStart,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(context)),
                      SliverToBoxAdapter(child: _buildStatsCard(state)),
                      SliverToBoxAdapter(child: _buildFilterChips()),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: WalletScreenConfig.padding, vertical: 16),
                        sliver: _buildWalletList(state),
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

  // Build header with title, notifications, and sort options
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(WalletScreenConfig.padding),
      child: Row(
        children: [
          const Text(
            'My Wallets',
            style: TextStyle(
              color: WalletScreenConfig.textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: WalletScreenConfig.fontFamily,
            ),
          ),
          const Spacer(),
          _buildSortButton(context),
          const SizedBox(width: 8),
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  // Build notification button with badge
  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: WalletScreenConfig.textColor),
          style: IconButton.styleFrom(
            backgroundColor: WalletScreenConfig.textColor.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
          onPressed: () {
            _showNotificationsDialog(context);
          },
        ),
        if (_unreadNotifications > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$_unreadNotifications',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  // Build sort button with dropdown
  Widget _buildSortButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort, color: WalletScreenConfig.textColor),
      onSelected: _onSortSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Name', child: Text('Sort by Name')),
        const PopupMenuItem(value: 'Balance', child: Text('Sort by Balance')),
      ],
      color: WalletScreenConfig.gradientStart,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WalletScreenConfig.borderRadius)),
    );
  }

  // Build stats card showing total balance and wallet count
  Widget _buildStatsCard(WalletState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WalletScreenConfig.padding),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(WalletScreenConfig.borderRadius),
          border: Border.all(color: WalletScreenConfig.textColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      color: WalletScreenConfig.textColor.withOpacity(0.7),
                      fontSize: 14,
                      fontFamily: WalletScreenConfig.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${state.totalBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: WalletScreenConfig.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: WalletScreenConfig.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: WalletScreenConfig.textColor.withOpacity(0.2),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Wallets',
                    style: TextStyle(
                      color: WalletScreenConfig.textColor.withOpacity(0.7),
                      fontSize: 14,
                      fontFamily: WalletScreenConfig.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.wallets.length}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: WalletScreenConfig.fontFamily,
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

  // Build filter chips with slide animation
  Widget _buildFilterChips() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _animationController, curve: Curves.easeOut)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: WalletScreenConfig.padding),
        child: FilterChips(
          selectedFilter: _selectedFilter,
          onFilterSelected: _onFilterSelected,
        ),
      ),
    );
  }

  // Build wallet list with fade and scale animation
  Widget _buildWalletList(WalletState state) {
    if (state.isLoading) {
      return const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator(color: Colors.blue)));
    }

    final filteredWallets = _sortWallets(state.wallets);
    if (filteredWallets.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: WalletScreenConfig.textColor.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFilter == 'All'
                    ? 'No Wallets Yet'
                    : 'No $_selectedFilter Wallets',
                style: TextStyle(
                  color: WalletScreenConfig.textColor.withOpacity(0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: WalletScreenConfig.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a wallet to get started',
                style: TextStyle(
                  color: WalletScreenConfig.textColor.withOpacity(0.5),
                  fontSize: 14,
                  fontFamily: WalletScreenConfig.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<WalletBloc>().add(LoadWallets()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(WalletScreenConfig.borderRadius)),
                ),
                child: const Text(
                  'Retry Loading',
                  style: TextStyle(
                      color: WalletScreenConfig.textColor,
                      fontFamily: WalletScreenConfig.fontFamily),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeOut)),
            child: GestureDetector(
              onTap: () => showWalletDetails(context, filteredWallets[index]),
              onLongPress: () => showWalletDetails(context, filteredWallets[index]),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WalletCard(wallet: filteredWallets[index]),
              ),
            ),
          ),
        ),
        childCount: filteredWallets.length,
      ),
    );
  }

  // Build add wallet button
  Widget _buildAddWalletButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => showWalletOptionsBottomSheet(context),
      backgroundColor: Colors.blue,
      icon: const Icon(Icons.add, color: WalletScreenConfig.textColor),
      label: const Text(
        'Add Wallet',
        style: TextStyle(
          color: WalletScreenConfig.textColor,
          fontWeight: FontWeight.bold,
          fontFamily: WalletScreenConfig.fontFamily,
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WalletScreenConfig.borderRadius)),
    );
  }

  // Show notifications dialog (placeholder)
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WalletScreenConfig.backgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WalletScreenConfig.borderRadius)),
        title: const Text(
          'Notifications',
          style: TextStyle(
              color: WalletScreenConfig.textColor,
              fontFamily: WalletScreenConfig.fontFamily),
        ),
        content: Text(
          'You have $_unreadNotifications unread notifications.\nFeature not fully implemented.',
          style: TextStyle(
              color: WalletScreenConfig.textColor.withOpacity(0.7),
              fontFamily: WalletScreenConfig.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                  color: WalletScreenConfig.textColor.withOpacity(0.7),
                  fontFamily: WalletScreenConfig.fontFamily),
            ),
          ),
        ],
      ),
    );
    setState(() => _unreadNotifications = 0); // Clear notifications on view
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: WalletScreenConfig.fontFamily),
        ),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: WalletScreenConfig.textColor,
          onPressed: () => context.read<WalletBloc>().add(LoadWallets()),
        ),
      ),
    );
  }
}