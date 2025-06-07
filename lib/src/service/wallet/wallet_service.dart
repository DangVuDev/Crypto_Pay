import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:crysta_pay/src/service/wallet/balance_service.dart';
import 'package:crysta_pay/src/service/wallet/external_wallet_service.dart';
import 'package:crysta_pay/src/service/wallet/seed_phrase_service.dart';
import 'package:crysta_pay/src/service/wallet/wallet_connect_service.dart';
import 'package:crysta_pay/src/service/wallet/wallet_creation_service.dart';
import 'package:logger/logger.dart';

/// Main service that orchestrates all wallet-related operations.
/// This service acts as a facade for all wallet functionality.
class WalletService {
  final Logger _logger = Logger();
  final SeedPhraseService _seedPhraseService = SeedPhraseService();
  final WalletCreationService _walletCreationService = WalletCreationService();
  final WalletConnectService _walletConnectService = WalletConnectService();
  final ExternalWalletService _externalWalletService = ExternalWalletService();
  final BalanceService _balanceService = BalanceService();

  // Seed phrase operations
  Future<String> generateSeedPhrase() => _seedPhraseService.generateSeedPhrase();

  Future<bool> validateSeedPhrase(String mnemonic) => _seedPhraseService.validateSeedPhrase(mnemonic);

  // Wallet creation operations
  Future<Map<String, dynamic>> createWalletFromSeed(String seedPhrase, CryptoType type) =>
      _walletCreationService.createWalletFromSeed(seedPhrase, type);

  // WalletConnect operations
  Future<Map<String, dynamic>> connectWalletConnect(Map<String, dynamic> params) =>
      _walletConnectService.connectWalletConnect(params);

  Future<Map<String, dynamic>> reconnectWalletConnect(CryptoType cryptoType) =>
      _walletConnectService.reconnectWalletConnect(cryptoType);

  String? get walletConnectUri => _walletConnectService.lastUri;

  // External wallet operations
  Future<Map<String, dynamic>> connectExternalWallet(CryptoType cryptoType, String walletType, Map<String, dynamic> params) =>
      _externalWalletService.connectExternalWallet(cryptoType, walletType, params: params);

  Future<Map<String, dynamic>> reconnectExternalWallet(CryptoType cryptoType, String walletType) =>
      _externalWalletService.reconnectExternalWallet(cryptoType, walletType);

  String? get externalWalletUri => _externalWalletService.lastUri;

  // Balance operations
  Future<double> getBalance(String address, CryptoType type) =>
      _balanceService.getBalance(address, type);

  Future<double> getUsdValue(CryptoType type, double amount) =>
      _balanceService.getUsdValue(type, amount);

  Future<double> getCryptoPrice(CryptoType type) =>
      _balanceService.getCryptoPrice(type);

  // Generic reconnect method
  Future<Map<String, dynamic>> reconnectWallet(CryptoType cryptoType, String walletType) async {
    try {
      _logger.i('Attempting to reconnect to $walletType for $cryptoType');
      if (walletType.toLowerCase() == 'walletconnect') {
        return await reconnectWalletConnect(cryptoType);
      } else {
        return await reconnectExternalWallet(cryptoType, walletType);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to reconnect to $walletType for $cryptoType', error: e, stackTrace: stackTrace);
      throw Exception('Failed to reconnect to $walletType for $cryptoType: $e');
    }
  }

  // Get the last URI from any wallet connection
  String? get lastUri => walletConnectUri ?? externalWalletUri;

  /// Disposes of all services and resources.
  void dispose() {
    _balanceService.dispose();
    // Note: Other services like ExternalWalletService and WalletConnectService may need disposal
    // if they manage resources (e.g., WalletConnect connectors). Add if necessary.
    _logger.i('WalletService disposed');
  }
}