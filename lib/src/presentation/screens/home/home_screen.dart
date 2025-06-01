import 'package:crysta_pay/src/config/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// Fake App Localizations
class AppLocalizations {
  static AppLocalizations of(BuildContext context) => AppLocalizations();
  
  String translate(String key) {
    final translations = {
      'app_name': 'CrystaPay',
      'services': 'Dịch vụ',
      'recent_transactions': 'Giao dịch gần đây',
      'notifications': 'Thông báo',
      'view_all_transactions': 'Xem tất cả giao dịch',
    };
    return translations[key] ?? key;
  }
}

// Fake Logger
class AppLogger {
  // ignore: avoid_print
  static void debug(String message) => print('DEBUG: $message');
  // ignore: avoid_print
  static void info(String message) => print('INFO: $message');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isBalanceVisible = true;
  bool _isRefreshing = false;

  // Fake data with null safety
  late WalletState _walletState;
  late TransactionState _transactionState;

  @override
  void initState() {
    super.initState();
    _initializeFakeData();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeFakeData() {
    _walletState = WalletState(
      isLoading: false,
      totalBalance: 15420.75,
      wallets: [
        WalletModel(
          id: 'wallet001',
          name: 'Ví BTC chính',
          address: '1A2B3C4D5E6F7G8H9I0J',
          type: CryptoType.btc,
          balance: 0.045,
          usdValue: 3000.50,
          status: WalletStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        WalletModel(
          id: 'wallet002',
          name: 'Ví ETH phụ',
          address: '0x123456789abcdef',
          type: CryptoType.eth,
          balance: 1.2,
          usdValue: 4200.75,
          status: WalletStatus.locked,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        WalletModel(
          id: 'wallet003',
          name: 'Ví USDT giao dịch',
          address: '0xabcdef987654321',
          type: CryptoType.usdt,
          balance: 500.0,
          usdValue: 500.0,
          status: WalletStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    );

    _transactionState = TransactionState(
      isLoading: false,
      recentTransactions: [
        TransactionModel(
          id: 'tx001',
          title: 'Chuyển BTC tới ví phụ',
          address: '1A2b3C4d5E6f7G8h9I0j',
          amount: 0.0054,
          cryptoType: 'BTC',
          feeAmount: 0.0001,
          type: TransactionType.send,
          status: TransactionStatus.completed,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          hash: '000xabc123456789',
          notes: 'Chuyển cho ví phụ để lưu trữ dài hạn',
        ),
        TransactionModel(
          id: 'tx002',
          title: 'Nhận ETH từ khách hàng',
          address: '0x9f8b7d6c5a4e3f2d1c0b',
          amount: 1.25,
          cryptoType: 'ETH',
          feeAmount: 0.002,
          type: TransactionType.receive,
          status: TransactionStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          hash: null,
          notes: 'Thanh toán dịch vụ tháng 5',
        ),
        TransactionModel(
          id: 'tx003',
          title: 'Bán USDT qua sàn',
          address: '0xexchange12345678',
          amount: 500.00,
          cryptoType: 'USDT',
          feeAmount: 1.0,
          type: TransactionType.sell,
          status: TransactionStatus.failed,
          timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
          hash: '0xsellfailed999999',
          notes: 'Lỗi xác thực tài khoản',
        ),
      ],
    );
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building HomeScreen');
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.blueAccent,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBalanceCard(context, _walletState),
                        const SizedBox(height: 32),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildSectionTitle(
                          context, 
                          AppLocalizations.of(context).translate('services'),
                          icon: Icons.apps_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildServicesGrid(context),
                        const SizedBox(height: 32),
                        _buildSectionTitle(
                          context,
                          'Khuyến mãi',
                          icon: Icons.local_fire_department_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildPromoBanner(context),
                        const SizedBox(height: 32),
                        _buildSectionTitle(
                          context,
                          AppLocalizations.of(context).translate('recent_transactions'),
                          icon: Icons.history_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildTransactionHistory(context, _transactionState),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context).translate('app_name'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      actions: [
        _buildNotificationButton(context),
        _buildProfileButton(context),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.blueAccent),
          onPressed: () => _showNotifications(context),
          tooltip: AppLocalizations.of(context).translate('notifications'),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AppLogger.info('Navigate to profile');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Hero(
          tag: 'profile_avatar',
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blueAccent),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletState state) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tài sản',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleBalanceVisibility,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                      key: ValueKey(_isBalanceVisible),
                      size: 20,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _isBalanceVisible
                    ? '\$${state.totalBalance.toStringAsFixed(2)}'
                    : '****',
                key: ValueKey(_isBalanceVisible),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ví của tôi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AppLogger.info('Navigate to wallets');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      // ignore: deprecated_member_use
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.8),
                itemCount: state.wallets.length,
                itemBuilder: (context, index) {
                  final wallet = state.wallets[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildWalletCard(wallet, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(WalletModel wallet, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () => _onWalletTap(wallet),
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCryptoTypeDisplayName(wallet.type),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCryptoIcon(wallet.type),
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${wallet.balance.toStringAsFixed(4)} ${_getCryptoTypeDisplayName(wallet.type)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${wallet.usdValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final quickActions = [
      QuickAction(
        icon: Icons.send_rounded,
        label: 'Gửi',
        color: Colors.blue,
        onTap: () => _navigateToSend(context),
      ),
      QuickAction(
        icon: Icons.qr_code_rounded,
        label: 'Nhận',
        color: Colors.green,
        onTap: () => _navigateToReceive(context),
      ),
      QuickAction(
        icon: Icons.swap_horiz_rounded,
        label: 'Trao đổi',
        color: Colors.orange,
        onTap: () => _showComingSoon(context, 'Trao đổi'),
      ),
      QuickAction(
        icon: Icons.more_horiz_rounded,
        label: 'Khác',
        color: Colors.purple,
        onTap: () => _showMoreOptions(context),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: quickActions.map((action) => _buildQuickActionButton(action)).toList(),
    );
  }

  Widget _buildQuickActionButton(QuickAction action) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            // ignore: deprecated_member_use
            color: action.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icon,
              color: action.color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      ServiceItem(
        icon: Icons.shopping_cart_rounded,
        label: 'Mua crypto',
        isAvailable: false,
        color: Colors.blue,
      ),
      ServiceItem(
        icon: Icons.lock_rounded,
        label: 'Staking',
        isAvailable: false,
        color: Colors.green,
      ),
      ServiceItem(
        icon: Icons.receipt_long_rounded,
        label: 'Thanh toán',
        isAvailable: false,
        color: Colors.orange,
      ),
      ServiceItem(
        icon: Icons.analytics_rounded,
        label: 'Phân tích',
        isAvailable: false,
        color: Colors.purple,
      ),
      ServiceItem(
        icon: Icons.card_giftcard_rounded,
        label: 'Quà tặng',
        isAvailable: false,
        color: Colors.pink,
      ),
      ServiceItem(
        icon: Icons.support_agent_rounded,
        label: 'Hỗ trợ',
        isAvailable: true,
        color: Colors.indigo,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: _buildServiceCard(context, service),
            );
          },
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem service) {
    return GestureDetector(
      onTap: () => _handleServiceTap(context, service),
      child: Container(
        decoration: BoxDecoration(
          color: service.isAvailable ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: service.isAvailable 
                  // ignore: deprecated_member_use
                  ? service.color.withOpacity(0.1)
                  // ignore: deprecated_member_use
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: service.isAvailable 
                // ignore: deprecated_member_use
                ? service.color.withOpacity(0.2)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: service.isAvailable 
                    // ignore: deprecated_member_use
                    ? service.color.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                service.icon,
                size: 28,
                color: service.isAvailable ? service.color : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              service.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: service.isAvailable ? Colors.black87 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (!service.isAvailable) ...[
              const SizedBox(height: 2),
              Text(
                'Sắp ra mắt',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    final banners = [
      BannerData(
        title: 'Stake & Kiếm lãi',
        subtitle: 'Lên đến 12% APY',
        color: Colors.blueAccent,
        icon: Icons.trending_up,
      ),
      BannerData(
        title: 'Mời bạn bè',
        subtitle: 'Nhận 50 USDT',
        color: Colors.purpleAccent,
        icon: Icons.group_add,
      ),
      BannerData(
        title: 'Trading Bot',
        subtitle: 'Tự động giao dịch',
        color: Colors.green,
        icon: Icons.smart_toy,
      ),
    ];

    return SizedBox(
      height: 140,
      child: PageView.builder(
        itemCount: banners.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildBannerCard(banners[index]),
          );
        },
      ),
    );
  }

  Widget _buildBannerCard(BannerData banner) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        AppLogger.info('Tapped banner: ${banner.title}');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // ignore: deprecated_member_use
            colors: [banner.color.withOpacity(0.8), banner.color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: banner.color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                banner.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context, TransactionState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    final transactions = state.recentTransactions;
    
    if (transactions.isEmpty) {
      return _buildEmptyTransactions(context);
    }

    return Column(
      children: [
        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _TransactionTile(transaction: transaction),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              AppLogger.info('Navigate to transactions');
            },
            style: ElevatedButton.styleFrom(
              // ignore: deprecated_member_use
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              foregroundColor: Colors.blueAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.list_alt_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).translate('view_all_transactions'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có giao dịch nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các giao dịch của bạn sẽ xuất hiện tại đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        _showQuickSendDialog(context);
      },
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      elevation: 8,
      label: const Text(
        'Gửi nhanh',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.flash_on_rounded),
    );
  }

  // Event handlers
  void _toggleBalanceVisibility() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
    AppLogger.debug('Balance visibility toggled: $_isBalanceVisible');
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isRefreshing = false;
    });
    
    AppLogger.info('Data refreshed');
  }

  void _onWalletTap(WalletModel wallet) {
    HapticFeedback.lightImpact();
    AppLogger.info('Wallet tapped: ${wallet.name}');
    
    if (wallet.status == WalletStatus.locked) {
      _showWalletLockedDialog(wallet);
    } else {
      _navigateToWalletDetail(wallet);
    }
  }

  void _navigateToSend(BuildContext context) {
    AppLogger.info('Navigate to send screen');
    context.pushNamed(RouteNames.send);
  }

  void _navigateToReceive(BuildContext context) {
    AppLogger.info('Navigate to receive screen');
    context.pushNamed(RouteNames.receive);
  }

  void _navigateToWalletDetail(WalletModel wallet) {
    AppLogger.info('Navigate to wallet detail: ${wallet.id}');
    // Navigator.pushNamed(context, '/wallet_detail', arguments: wallet);
  }

  void _handleServiceTap(BuildContext context, ServiceItem service) {
    HapticFeedback.lightImpact();
    
    if (!service.isAvailable) {
      _showComingSoon(context, service.label);
    } else {
      switch (service.label) {
        case 'Hỗ trợ':
          _showSupportDialog(context);
          break;
        default:
          AppLogger.info('Service tapped: ${service.label}');
      }
    }
  }

  // Dialog methods
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.notifications_rounded, 
                         color: Colors.blueAccent, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Thông báo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildNotificationItem(
                      'Giao dịch hoàn tất',
                      'Bạn đã nhận 0.0054 BTC từ ví chính',
                      Icons.check_circle,
                      Colors.green,
                      '2 giờ trước',
                    ),
                    _buildNotificationItem(
                      'Bảo mật tài khoản',
                      'Đăng nhập từ thiết bị mới được phát hiện',
                      Icons.security,
                      Colors.orange,
                      '1 ngày trước',
                    ),
                    _buildNotificationItem(
                      'Khuyến mãi mới',
                      'Stake BTC và nhận lãi suất 8% APY',
                      Icons.local_fire_department,
                      Colors.red,
                      '3 ngày trước',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, IconData icon, Color color, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.construction_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Text('Sắp ra mắt'),
          ],
        ),
        content: Text('Tính năng "$feature" đang được phát triển và sẽ sớm có mặt trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Thêm tùy chọn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionItem(Icons.qr_code_scanner, 'Quét QR', () {}),
            _buildOptionItem(Icons.history, 'Lịch sử giao dịch', () {}),
            _buildOptionItem(Icons.settings, 'Cài đặt', () {}),
            _buildOptionItem(Icons.help_outline, 'Trợ giúp', () {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blueAccent, size: 20),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showWalletLockedDialog(WalletModel wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outlined, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text('Ví bị khóa'),
          ],
        ),
        content: Text('Ví "${wallet.name}" hiện đang bị khóa. Vui lòng liên hệ hỗ trợ để mở khóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSupportDialog(context);
            },
            child: const Text('Liên hệ hỗ trợ'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded, color: Colors.blueAccent, size: 24),
            SizedBox(width: 12),
            Text('Hỗ trợ khách hàng'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chúng tôi sẵn sàng hỗ trợ bạn 24/7:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Hotline: 1900-9999'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.mail, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text('Email: support@crystapay.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.chat, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('Live Chat: 24/7'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppLogger.info('Open live chat');
            },
            child: const Text('Chat ngay'),
          ),
        ],
      ),
    );
  }

  void _showQuickSendDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.flash_on_rounded, color: Colors.blueAccent, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Gửi nhanh',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Quét QR code hoặc nhập địa chỉ ví để gửi crypto nhanh chóng',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        AppLogger.info('Open QR scanner');
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Quét QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToSend(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Nhập địa chỉ thủ công'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getCryptoTypeDisplayName(CryptoType type) {
    switch (type) {
      case CryptoType.btc:
        return 'BTC';
      case CryptoType.eth:
        return 'ETH';
      case CryptoType.usdt:
        return 'USDT';
      default:
        return 'UNKNOWN';
    }
  }

  IconData _getCryptoIcon(CryptoType type) {
    switch (type) {
      case CryptoType.btc:
        return Icons.currency_bitcoin;
      case CryptoType.eth:
        return Icons.diamond;
      case CryptoType.usdt:
        return Icons.attach_money;
      default:
        return Icons.help;
    }
  }
}

// Transaction Tile Widget
class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: _getTransactionColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTransactionIcon(),
              color: _getTransactionColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_getAmountPrefix()}${transaction.amount.toStringAsFixed(4)} ${transaction.cryptoType}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getTransactionColor(),
                      ),
                    ),
                    Text(
                      _formatTimestamp(transaction.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                if (transaction.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor() {
    switch (transaction.type) {
      case TransactionType.send:
        return Colors.red;
      case TransactionType.receive:
        return Colors.green;
      case TransactionType.sell:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.send:
        return Icons.arrow_upward_rounded;
      case TransactionType.receive:
        return Icons.arrow_downward_rounded;
      case TransactionType.sell:
        return Icons.swap_horiz_rounded;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (transaction.status) {
      case TransactionStatus.completed:
        return 'Hoàn tất';
      case TransactionStatus.pending:
        return 'Đang xử lý';
      case TransactionStatus.failed:
        return 'Thất bại';
      default:
        return 'Không xác định';
    }
  }

  String _getAmountPrefix() {
    switch (transaction.type) {
      case TransactionType.send:
        return '-';
      case TransactionType.receive:
        return '+';
      case TransactionType.sell:
        return '-';
      default:
        return '';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}

// Data Models
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class ServiceItem {
  final IconData icon;
  final String label;
  final bool isAvailable;
  final Color color;

  ServiceItem({
    required this.icon,
    required this.label,
    required this.isAvailable,
    required this.color,
  });
}

class BannerData {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  BannerData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}

// Enum definitions (these would normally be in separate files)
enum CryptoType { btc, eth, usdt }
enum WalletStatus { active, locked, inactive }
enum TransactionType { send, receive, sell, buy }
enum TransactionStatus { completed, pending, failed }

// Model classes (these would normally be in separate files)
class WalletState {
  final bool isLoading;
  final double totalBalance;
  final List<WalletModel> wallets;

  WalletState({
    required this.isLoading,
    required this.totalBalance,
    required this.wallets,
  });
}

class TransactionState {
  final bool isLoading;
  final List<TransactionModel> recentTransactions;

  TransactionState({
    required this.isLoading,
    required this.recentTransactions,
  });
}

class WalletModel {
  final String id;
  final String name;
  final String address;
  final CryptoType type;
  final double balance;
  final double usdValue;
  final WalletStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WalletModel({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.balance,
    required this.usdValue,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
}

class TransactionModel {
  final String id;
  final String title;
  final String address;
  final double amount;
  final String cryptoType;
  final double feeAmount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? hash;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.title,
    required this.address,
    required this.amount,
    required this.cryptoType,
    required this.feeAmount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.hash,
    this.notes,
  });
}