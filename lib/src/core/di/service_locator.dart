import 'package:crysta_pay/src/data/datasources/app_preferences.dart';
import 'package:crysta_pay/src/data/datasources/secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/datasources/app_preferences.dart';
import '../../data/datasources/app_preferences.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/wallet/wallet_bloc.dart';
import '../../presentation/bloc/transaction/transaction_bloc.dart';
import '../../presentation/bloc/theme/theme_bloc.dart';
import '../../presentation/bloc/language/language_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External Services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  
  // Data Sources
  getIt.registerSingleton<AppPreferences>(AppPreferences(getIt<SharedPreferences>()));
  getIt.registerSingleton<SecureStorage>(SecureStorage(getIt<FlutterSecureStorage>()));
  
  // Repositories
  getIt.registerSingleton<AuthRepository>(AuthRepository(
    secureStorage: getIt<SecureStorage>(),
    preferences: getIt<AppPreferences>(),
  ));
  getIt.registerSingleton<WalletRepository>(WalletRepository(
    preferences: getIt<AppPreferences>(),
  ));
  getIt.registerSingleton<TransactionRepository>(TransactionRepository(
    preferences: getIt<AppPreferences>(),
  ));
  getIt.registerSingleton<UserRepository>(UserRepository(
    preferences: getIt<AppPreferences>(),
    secureStorage: getIt<SecureStorage>(),
  ));

  
  
  // BLoCs
  getIt.registerFactory<ThemeBloc>(() => ThemeBloc(
    preferences: getIt<AppPreferences>(),
  ));
  getIt.registerFactory<LanguageBloc>(() => LanguageBloc(
    preferences: getIt<AppPreferences>(),
  ));
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
    authRepository: getIt<AuthRepository>(),
  ));
  getIt.registerFactory<WalletBloc>(() => WalletBloc(
    walletRepository: getIt<WalletRepository>(),
  ));
  getIt.registerFactory<TransactionBloc>(() => TransactionBloc(
    transactionRepository: getIt<TransactionRepository>(),
  ));
}