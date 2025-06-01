import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../bloc/wallet/wallet_bloc.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../widgets/common/custom_bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;
  
  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<WalletBloc>()),
        BlocProvider(create: (_) => getIt<TransactionBloc>()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentLocation: GoRouterState.of(context).fullPath ?? '/home',
          onTap: (index) {
            String location;
            
            switch (index) {
              case 0:
                location = '/home';
                break;
              case 1:
                location = '/wallets';
                break;
              case 2:
                location = '/profile';
                break;
              default:
                location = '/home';
            }
            
            context.go(location);
          },
          items: [
            BottomNavItem(
              icon: Icons.home_rounded,
              label: l10n.translate('home'),
              path: '/home',
            ),
            BottomNavItem(
              icon: Icons.account_balance_wallet_rounded,
              label: l10n.translate('wallets'),
              path: '/wallets',
            ),
            BottomNavItem(
              icon: Icons.person_rounded,
              label: l10n.translate('profile'),
              path: '/profile',
            ),
          ],
        ),
      ),
    );
  }
}

final getIt = GetIt.instance;