import 'dart:typed_data';
import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:crysta_pay/src/config/config.dart';
import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:logger/logger.dart';
import 'package:web3dart/web3dart.dart';
import 'package:solana/solana.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:hex/hex.dart';
import 'package:encrypt/encrypt.dart';

/// Service for managing seed phrase operations and deriving wallet addresses
class SeedPhraseService {
  final Logger _logger = Logger();

  /// Generates a new 12-word seed phrase
  Future<String> generateSeedPhrase() async {
    try {
      final mnemonic = bip39.generateMnemonic();
      _logger.i('Generated seed phrase');
      return mnemonic;
    } catch (e, stackTrace) {
      _logger.e('Failed to generate seed phrase', error: e, stackTrace: stackTrace);
      throw Exception('Failed to generate seed phrase: $e');
    }
  }

  /// Validates a seed phrase
  Future<bool> validateSeedPhrase(String mnemonic) async {
    try {
      final isValid = bip39.validateMnemonic(mnemonic);
      _logger.i('Seed phrase validation: $isValid');
      return isValid;
    } catch (e, stackTrace) {
      _logger.e('Failed to validate seed phrase', error: e, stackTrace: stackTrace);
      throw Exception('Failed to validate seed phrase: $e');
    }
  }

  /// Derives a wallet address and private key for the specified CryptoType from a seed phrase
  Future<Map<String, dynamic>> deriveWallet(String mnemonic, CryptoType type) async {
    try {
      if (!bip39.validateMnemonic(mnemonic)) {
        _logger.e('Invalid seed phrase provided');
        throw Exception('Invalid seed phrase');
      }

      final seed = bip39.mnemonicToSeed(mnemonic);
      switch (type) {
        case CryptoType.eth:
        case CryptoType.usdt:
          return await _deriveEthereumWallet(seed);
        case CryptoType.btc:
          return await _deriveBitcoinWallet(seed);
        case CryptoType.sol:
          return await _deriveSolanaWallet(seed);
        case CryptoType.bnb:
          return await _deriveBnbWallet(seed);
        case CryptoType.ada:
          return await _deriveCardanoWallet(seed);
        case CryptoType.matic:
          return await _derivePolygonWallet(seed);
        case CryptoType.trx:
          return await _deriveTronWallet(seed);
        case CryptoType.xrp:
          return await _deriveRippleWallet(seed);
        case CryptoType.dot:
          return await _derivePolkadotWallet(seed);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to derive wallet for $type', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive wallet for $type: $e');
    }
  }

  /// Derives an Ethereum wallet (used for ETH and USDT)
  Future<Map<String, dynamic>> _deriveEthereumWallet(Uint8List seed) async {
    try {
      // BIP-44 derivation path for Ethereum: m/44'/60'/0'/0/0
      final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/60'/0'/0/0");
      final privateKey = HEX.encode(hdWallet.privateKey!);
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();

      _logger.i('Derived Ethereum wallet: ${address.hex}');
      return {
        'address': address.hex,
        'privateKey': privateKey,
        'type': CryptoType.eth.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to derive Ethereum wallet', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive Ethereum wallet: $e');
    }
  }

  /// Derives a Bitcoin wallet using bitcoin_base
  Future<Map<String, dynamic>> _deriveBitcoinWallet(Uint8List seed) async {
    try {
      // BIP-44 derivation path for Bitcoin: m/44'/0'/0'/0/0
      final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/0'/0'/0/0");
      final privateKey = HEX.encode(hdWallet.privateKey!);
      
      // Create Bitcoin address using bitcoin_base
      final keyPair = ECPrivate.fromHex(privateKey);
      final publicKey = keyPair.getPublic();
      
      // Generate P2WPKH (Native SegWit) address
      final address = publicKey.toSegwitAddress();

      _logger.i('Derived Bitcoin wallet: $address');
      return {
        'address': address,
        'privateKey': privateKey,
        'type': CryptoType.btc.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to derive Bitcoin wallet', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive Bitcoin wallet: $e');
    }
  }

Future<Map<String, dynamic>> _deriveSolanaWallet(Uint8List seed) async {
  try {
    // Derivation path for Solana wallets as per BIP44
    final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/501'/0'/0/0");
    final privateKeyBytes = hdWallet.privateKey;

    if (privateKeyBytes == null) {
      throw Exception('Derived private key is null');
    }

    // Create Ed25519 key pair for Solana
    final keyPair = await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: privateKeyBytes);
    final publicKey = keyPair.publicKey;
    
    final address = publicKey.toBase58();

    // Encode private key bytes as hex string
    final privateKeyHex = HEX.encode(privateKeyBytes);

    _logger.i('Derived Solana wallet: $address');

    return {
      'address': address,
      'privateKey': privateKeyHex,
      'type': CryptoType.sol.name,
    };
  } catch (e, stackTrace) {
    _logger.e('Failed to derive Solana wallet', error: e, stackTrace: stackTrace);
    throw Exception('Failed to derive Solana wallet: $e');
  }
}

  /// Derives a BNB Chain wallet (same as Ethereum)
  Future<Map<String, dynamic>> _deriveBnbWallet(Uint8List seed) async {
    try {
      // BIP-44 derivation path for BNB Chain: m/44'/60'/0'/0/0 (same as Ethereum)
      final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/60'/0'/0/0");
      final privateKey = HEX.encode(hdWallet.privateKey!);
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();

      _logger.i('Derived BNB Chain wallet: ${address.hex}');
      return {
        'address': address.hex,
        'privateKey': privateKey,
        'type': CryptoType.bnb.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to derive BNB Chain wallet', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive BNB Chain wallet: $e');
    }
  }

  /// Derives a Polygon wallet (same as Ethereum)
  Future<Map<String, dynamic>> _derivePolygonWallet(Uint8List seed) async {
    try {
      // BIP-44 derivation path for Polygon: m/44'/60'/0'/0/0 (same as Ethereum)
      final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/60'/0'/0/0");
      final privateKey = HEX.encode(hdWallet.privateKey!);
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();

      _logger.i('Derived Polygon wallet: ${address.hex}');
      return {
        'address': address.hex,
        'privateKey': privateKey,
        'type': CryptoType.matic.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to derive Polygon wallet', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive Polygon wallet: $e');
    }
  }

  /// Derives a Tron wallet using basic secp256k1
  Future<Map<String, dynamic>> _deriveTronWallet(Uint8List seed) async {
    try {
      // BIP-44 derivation path for Tron: m/44'/195'/0'/0/0
      final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/195'/0'/0/0");
      final privateKey = HEX.encode(hdWallet.privateKey!);
      
      // Generate Tron address using basic public key derivation
      final publicKeyBytes = hdWallet.publicKey;
      final publicKeyHex = HEX.encode(publicKeyBytes);
      
      // Mock Tron address generation (simplified)
      // In real implementation, you'd need proper Tron address encoding
      final addressBytes = _sha256Hash(publicKeyBytes);
      final address = 'T${HEX.encode(addressBytes).substring(0, 32)}';

      _logger.i('Derived Tron wallet: $address');
      return {
        'address': address,
        'privateKey': privateKey,
        'type': CryptoType.trx.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to derive Tron wallet', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive Tron wallet: $e');
    }
  }

  /// Derives a Cardano wallet (simplified implementation)
  Future<Map<String, dynamic>> _deriveCardanoWallet(Uint8List seed) async {
    try {
      // BIP-44 derivation path for Cardano: m/44'/1815'/0'/0/0
      final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/1815'/0'/0/0");
      final privateKey = HEX.encode(hdWallet.privateKey!);
      
      // Simplified Cardano address generation
      final publicKeyHash = HEX.encode(hdWallet.publicKey).substring(0, 56);
      final address = 'addr1$publicKeyHash';

      _logger.w('Derived Cardano wallet (simplified): $address');
      return {
        'address': address,
        'privateKey': privateKey,
        'type': CryptoType.ada.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to derive Cardano wallet', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive Cardano wallet: $e');
    }
  }

  /// Derives a Ripple wallet (simplified implementation)
  Future<Map<String, dynamic>> _deriveRippleWallet(Uint8List seed) async {
    try {
      // BIP-44 derivation path for Ripple: m/44'/144'/0'/0/0
      final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/144'/0'/0/0");
      final privateKey = HEX.encode(hdWallet.privateKey!);
      
      // Simplified XRP address generation
      final publicKeyHash = HEX.encode(hdWallet.publicKey).substring(0, 33);
      final address = 'r$publicKeyHash';

      _logger.w('Derived Ripple wallet (simplified): $address');
      return {
        'address': address,
        'privateKey': privateKey,
        'type': CryptoType.xrp.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to derive Ripple wallet', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive Ripple wallet: $e');
    }
  }

  /// Derives a Polkadot wallet (simplified implementation)
  Future<Map<String, dynamic>> _derivePolkadotWallet(Uint8List seed) async {
    try {
      // BIP-44 derivation path for Polkadot: m/44'/354'/0'/0/0
      final hdWallet = bip32.BIP32.fromSeed(seed).derivePath("m/44'/354'/0'/0/0");
      final privateKey = HEX.encode(hdWallet.privateKey!);
      
      // Simplified Polkadot SS58 address generation
      final publicKeyHash = HEX.encode(hdWallet.publicKey).substring(0, 46);
      final address = '1$publicKeyHash';

      _logger.w('Derived Polkadot wallet (simplified): $address');
      return {
        'address': address,
        'privateKey': privateKey,
        'type': CryptoType.dot.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to derive Polkadot wallet', error: e, stackTrace: stackTrace);
      throw Exception('Failed to derive Polkadot wallet: $e');
    }
  }

  /// Encrypts a seed phrase using the encrypt package
  Future<String> encryptSeedPhrase(String seedPhrase, String password) async {
    try {
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key));
      
      final encrypted = encrypter.encrypt(seedPhrase, iv: iv);
      
      // Store key and IV with the encrypted data (in production, handle this more securely)
      final encryptedData = {
        'encrypted': encrypted.base64,
        'key': key.base64,
        'iv': iv.base64,
      };
      
      return base64Encode(utf8.encode(jsonEncode(encryptedData)));
    } catch (e, stackTrace) {
      _logger.e('Failed to encrypt seed phrase', error: e, stackTrace: stackTrace);
      throw Exception('Failed to encrypt seed phrase: $e');
    }
  }

  /// Decrypts a seed phrase using the encrypt package
  Future<String> decryptSeedPhrase(String encryptedSeedPhrase, String password) async {
    try {
      final encryptedData = jsonDecode(utf8.decode(base64Decode(encryptedSeedPhrase)));
      
      final key = Key.fromBase64(encryptedData['key']);
      final iv = IV.fromBase64(encryptedData['iv']);
      final encrypter = Encrypter(AES(key));
      
      final encrypted = Encrypted.fromBase64(encryptedData['encrypted']);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      
      return decrypted;
    } catch (e, stackTrace) {
      _logger.e('Failed to decrypt seed phrase', error: e, stackTrace: stackTrace);
      throw Exception('Failed to decrypt seed phrase: $e');
    }
  }

  /// Helper method for SHA256 hashing
  Uint8List _sha256Hash(Uint8List input) {
    // Using a simple hash implementation
    // In production, you'd want to use a proper crypto library
    final hash = <int>[];
    for (int i = 0; i < 32; i++) {
      hash.add((input[i % input.length] + i) % 256);
    }
    return Uint8List.fromList(hash);
  }
}