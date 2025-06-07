import 'package:crysta_pay/src/service/encryption_service.dart';
import 'package:crysta_pay/src/service/wallet/wallet_service.dart' show WalletService;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crysta_pay/src/data/datasources/app_preferences.dart';
import 'package:crysta_pay/src/data/datasources/secure_storage.dart';
import 'package:crysta_pay/src/data/repositories/auth_repository.dart';
import 'package:crysta_pay/src/data/repositories/wallet_repository.dart';
import 'package:crysta_pay/src/data/repositories/transaction_repository.dart';
import 'package:crysta_pay/src/data/repositories/user_repository.dart';
import 'package:crysta_pay/src/presentation/bloc/auth/auth_bloc.dart';
import 'package:crysta_pay/src/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:crysta_pay/src/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:crysta_pay/src/presentation/bloc/theme/theme_bloc.dart';
import 'package:crysta_pay/src/presentation/bloc/language/language_bloc.dart';

final getIt = GetIt.instance;

/// Sets up dependency injection using GetIt.
/// Ensures singletons are registered only once to prevent duplicate registration errors.
Future<void> setupServiceLocator() async {
  // Skip registration if already initialized
  if (getIt.isRegistered<SharedPreferences>()) {
    print('Service locator already initialized, skipping registration.');
    return;
  }

  try {
    // External Services
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

    // Data Sources
    if (!getIt.isRegistered<AppPreferences>()) {
      getIt.registerSingleton<AppPreferences>(AppPreferences(
        sharedPreferences: getIt<SharedPreferences>(),
      ));
    }
    if (!getIt.isRegistered<SecureStorage>()) {
      getIt.registerSingleton<SecureStorage>(SecureStorage(
        secureStorage: getIt<FlutterSecureStorage>(),
      ));
    }

    // Services
    if (!getIt.isRegistered<WalletService>()) {
      getIt.registerSingleton<WalletService>(WalletService());
    }
    if (!getIt.isRegistered<EncryptionService>()) {
      getIt.registerSingleton<EncryptionService>(EncryptionService());
    }

    // Repositories
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerSingleton<AuthRepository>(AuthRepository(
        secureStorage: getIt<SecureStorage>(),
        preferences: getIt<AppPreferences>(),
      ));
    }
    if (!getIt.isRegistered<WalletRepository>()) {
      getIt.registerSingleton<WalletRepository>(WalletRepositoryImpl());
    }
    if (!getIt.isRegistered<TransactionRepository>()) {
      getIt.registerSingleton<TransactionRepository>(TransactionRepository(
        preferences: getIt<AppPreferences>(),
      ));
    }
    if (!getIt.isRegistered<UserRepository>()) {
      getIt.registerSingleton<UserRepository>(UserRepository(
        preferences: getIt<AppPreferences>(),
        secureStorage: getIt<SecureStorage>(),
      ));
    }

    // BLoCs
    if (!getIt.isRegistered<ThemeBloc>()) {
      getIt.registerFactory<ThemeBloc>(() => ThemeBloc(
            preferences: getIt<AppPreferences>(),
          ));
    }
    if (!getIt.isRegistered<LanguageBloc>()) {
      getIt.registerFactory<LanguageBloc>(() => LanguageBloc(
            preferences: getIt<AppPreferences>(),
          ));
    }
    if (!getIt.isRegistered<AuthBloc>()) {
      getIt.registerFactory<AuthBloc>(() => AuthBloc(
            authRepository: getIt<AuthRepository>(),
          ));
    }
    if (!getIt.isRegistered<WalletBloc>()) {
      getIt.registerFactory<WalletBloc>(() => WalletBloc(
            walletRepository: getIt<WalletRepository>(),
            walletService: getIt<WalletService>(),
            encryptionService: getIt<EncryptionService>(),
          ));
    }
    if (!getIt.isRegistered<TransactionBloc>()) {
      getIt.registerFactory<TransactionBloc>(() => TransactionBloc(
            transactionRepository: getIt<TransactionRepository>(),
          ));
    }

    print('Service locator initialized successfully.');
  } catch (e, stackTrace) {
    // Log error for debugging (replace with proper logging in production)
    print('Error setting up service locator: $e\n$stackTrace');
    rethrow;
  }
}