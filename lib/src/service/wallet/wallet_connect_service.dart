import 'dart:convert';
import 'package:crysta_pay/src/config/config.dart';
import 'package:crysta_pay/src/data/datasources/secure_storage.dart';
import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

/// Service for managing WalletConnect connections
class WalletConnectService {
  final Logger _logger = Logger();
  String? _lastUri; // Store last WalletConnect URI for QR code display

  /// Maps CryptoType to chain ID for WalletConnect
  int _getChainId(CryptoType type) {
    switch (type) {
      case CryptoType.eth:
      case CryptoType.usdt:
        return 1; // Ethereum Mainnet
      case CryptoType.bnb:
        return 56; // BNB Chain Mainnet
      case CryptoType.matic:
        return 137; // Polygon Mainnet
      case CryptoType.sol:
        return 501; // Solana (custom, verify wallet support)
      case CryptoType.dot:
        return 354; // Polkadot (custom, verify wallet support)
      case CryptoType.btc:
      case CryptoType.ada:
      case CryptoType.trx:
      case CryptoType.xrp:
        throw Exception('$type not supported via WalletConnect');
    }
  }

  /// Connects to any WalletConnect-compatible wallet
  Future<Map<String, dynamic>> connectWalletConnect(Map<String, dynamic> params) async {
    try {
      final connector = _createConnector();
      final cryptoType = params['cryptoType'] as CryptoType? ?? CryptoType.eth;
      final chainId = params['chainId'] as int? ?? _getChainId(cryptoType);
      final walletKey = 'walletconnect_${cryptoType.name}';

      // Check for stored session
      final storedSession = await GetIt.I<SecureStorage>().getWalletSession(walletKey);
      if (storedSession != null) {
        final sessionData = jsonDecode(storedSession) as Map<String, dynamic>;
        _logger.i('Reusing WalletConnect session for $cryptoType');
        return _validateAndReturnSession(cryptoType, sessionData, chainId);
      }

      // Create new session
      final session = await connector.createSession(
        chainId: chainId,
        onDisplayUri: (uri) {
          _lastUri = uri;
          _showQRCode(uri);
        },
      );

      final result = await _validateSession(cryptoType, session, chainId);
      await GetIt.I<SecureStorage>().setWalletSession(
        walletKey,
        jsonEncode({
          'accounts': session.accounts,
          'chainId': session.chainId,
        }),
      );
      _logger.i('Connected to WalletConnect for $cryptoType: ${result['address']}');

      return result;
    } catch (e, stackTrace) {
      _logger.e('WalletConnect connection failed', error: e, stackTrace: stackTrace);
      throw Exception('WalletConnect connection failed: $e');
    }
  }

  /// Reconnects to a saved WalletConnect session
  Future<Map<String, dynamic>> reconnectWalletConnect(CryptoType cryptoType) async {
    try {
      final walletKey = 'walletconnect_${cryptoType.name}';
      final storedSession = await GetIt.I<SecureStorage>().getWalletSession(walletKey);
      if (storedSession == null) {
        throw Exception('No saved session for WalletConnect ($cryptoType)');
      }

      final sessionData = jsonDecode(storedSession) as Map<String, dynamic>;
      _logger.i('Reconnected to WalletConnect session for $cryptoType');
      return _validateAndReturnSession(cryptoType, sessionData, _getChainId(cryptoType));
    } catch (e, stackTrace) {
      _logger.e('Failed to reconnect to WalletConnect for $cryptoType', error: e, stackTrace: stackTrace);
      throw Exception('Failed to reconnect to WalletConnect for $cryptoType: $e');
    }
  }

  /// Creates a WalletConnect connector with standard configuration
  WalletConnect _createConnector() {
    return WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'CrystaPay',
        description: 'CrystaPay Wallet App',
        url: 'https://crystapay.app',
        icons: ['https://crystapay.app/icon.png'],
      ),
    );
  }

  /// Validates a WalletConnect session and returns connection details
  Future<Map<String, dynamic>> _validateSession(CryptoType cryptoType, SessionStatus session, int expectedChainId) async {
    if (session.chainId != expectedChainId) {
      throw Exception('Wrong network. Please switch to chain $expectedChainId');
    }

    if (session.accounts.isEmpty) {
      throw Exception('No accounts found in session');
    }

    final address = session.accounts[0];
    if (cryptoType == CryptoType.eth || cryptoType == CryptoType.usdt || cryptoType == CryptoType.bnb || cryptoType == CryptoType.matic) {
      try {
        EthereumAddress.fromHex(address); // Validate EVM-compatible address
        _logger.i('Validated address for $cryptoType: $address');
      } catch (e) {
        _logger.e('Invalid address for $cryptoType: $address', error: e);
        throw Exception('Invalid address for $cryptoType: $address');
      }
    } else if (cryptoType == CryptoType.sol) {
      // Basic Solana address validation (Base58, 32-44 chars)
      if (address.length < 32 || address.length > 44 || !RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(address)) {
        _logger.e('Invalid Solana address: $address');
        throw Exception('Invalid Solana address: $address');
      }
      _logger.i('Validated Solana address: $address');
    } else if (cryptoType == CryptoType.dot) {
      // Basic Polkadot address validation (SS58, 46-48 chars)
      if (address.length < 46 || address.length > 48 || !RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(address)) {
        _logger.e('Invalid Polkadot address: $address');
        throw Exception('Invalid Polkadot address: $address');
      }
      _logger.i('Validated Polkadot address: $address');
    }

    return {
      'success': true,
      'address': address,
      'type': cryptoType.name,
    };
  }

  /// Validates and returns session data from stored session
  Map<String, dynamic> _validateAndReturnSession(CryptoType cryptoType, Map<String, dynamic> sessionData, int expectedChainId) {
    final chainId = sessionData['chainId'] as int?;
    if (chainId != expectedChainId) {
      throw Exception('Wrong network. Please switch to chain $expectedChainId');
    }

    final accounts = sessionData['accounts'] as List<dynamic>?;
    if (accounts == null || accounts.isEmpty) {
      throw Exception('No accounts found in session');
    }

    final address = accounts[0] as String;
    if (cryptoType == CryptoType.eth || cryptoType == CryptoType.usdt || cryptoType == CryptoType.bnb || cryptoType == CryptoType.matic) {
      try {
        EthereumAddress.fromHex(address); // Validate EVM-compatible address
        _logger.i('Validated stored address for $cryptoType: $address');
      } catch (e) {
        _logger.e('Invalid stored address for $cryptoType: $address', error: e);
        throw Exception('Invalid stored address for $cryptoType: $address');
      }
    } else if (cryptoType == CryptoType.sol) {
      if (address.length < 32 || address.length > 44 || !RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(address)) {
        _logger.e('Invalid stored Solana address: $address');
        throw Exception('Invalid stored Solana address: $address');
      }
      _logger.i('Validated stored Solana address: $address');
    } else if (cryptoType == CryptoType.dot) {
      if (address.length < 46 || address.length > 48 || !RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(address)) {
        _logger.e('Invalid stored Polkadot address: $address');
        throw Exception('Invalid stored Polkadot address: $address');
      }
      _logger.i('Validated stored Polkadot address: $address');
    }

    return {
      'success': true,
      'address': address,
      'type': cryptoType.name,
    };
  }

  /// Notifies UI to show QR code
  void _showQRCode(String uri) {
    _lastUri = uri;
    _logger.i('QR code URI generated: $uri');
    // Notify UI to display QR code (e.g., via a Stream or Provider)
  }

  /// Gets the last WalletConnect URI for QR code display
  String? get lastUri => _lastUri;
}