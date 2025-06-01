
import 'package:crysta_pay/src/presentation/screens/error/error_screen.dart';
import 'package:crysta_pay/src/presentation/screens/home/home_screen_v2.dart';
import 'package:crysta_pay/src/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:crysta_pay/src/presentation/screens/profile/profile_screen.dart';
import 'package:crysta_pay/src/presentation/screens/receive/receive_screen.dart';
import 'package:crysta_pay/src/presentation/screens/send/send_screen_v2.dart';
import 'package:crysta_pay/src/presentation/screens/wallets/wallets_screen.dart';
import 'package:crysta_pay/src/presentation/screens/auth/login_screen.dart';
import 'package:crysta_pay/src/presentation/screens/auth/register_screen.dart';
import 'package:crysta_pay/src/presentation/screens/introduce/splash_screen.dart';
import 'package:crysta_pay/src/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../presentation/screens/main_navigation.dart' hide getIt;

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    final isOnboarded = await AuthService.isOnboardingCompleted();
    final isLoggedIn = await AuthService.isAuthenticated();
    
    final location = state.matchedLocation;
    
    debugPrint('Router redirect - Location: $location, Onboarded: $isOnboarded, LoggedIn: $isLoggedIn');
    
    if (location == '/') return null;
    
    if (!isOnboarded && location != '/onboarding') {
      return '/onboarding';
    }
    
    if (isOnboarded && !isLoggedIn) {
      if (location != '/login' && location != '/register') {
        return '/login';
      }
      return null;
    }
    
    if (isLoggedIn && (location == '/login' || location == '/register' || location == '/onboarding')) {
      return '/home';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainNavigation(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'send',
              name: RouteNames.send,
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const SendScreen(),
            ),
            GoRoute(
              path: 'receive',
              name: RouteNames.receive,
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const ReceiveScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/wallets',
          name: RouteNames.wallets,
          builder: (context, state) => const WalletsScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: RouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error.toString()),
);