import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:crysta_pay/src/service/wallet/seed_phrase_service.dart';
import 'package:logger/logger.dart';

/// Service for creating wallets from seed phrases
class WalletCreationService {
  final Logger _logger = Logger();
  final SeedPhraseService _seedPhraseService = SeedPhraseService();

  /// Creates a wallet from a seed phrase for the specified blockchain type.
  Future<Map<String, dynamic>> createWalletFromSeed(String seedPhrase, CryptoType type) async {
    try {
      _logger.i('Attempting to create wallet for $type from seed phrase');
      
      // Validate seed phrase using SeedPhraseService
      if (!await _seedPhraseService.validateSeedPhrase(seedPhrase)) {
        _logger.e('Invalid seed phrase provided');
        throw Exception('Invalid seed phrase');
      }

      // Delegate wallet derivation to SeedPhraseService
      final walletData = await _seedPhraseService.deriveWallet(seedPhrase, type);
      
      _logger.i('Created wallet for $type: ${walletData['address']}');
      return {
        'success': true,
        'address': walletData['address'],
        'privateKey': walletData['privateKey'],
        'type': type.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to create wallet for $type', error: e, stackTrace: stackTrace);
      throw Exception('Failed to create wallet for $type: $e');
    }
  }
}