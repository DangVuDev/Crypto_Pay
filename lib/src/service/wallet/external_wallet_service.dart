import 'dart:convert';
import 'dart:math';
import 'package:crysta_pay/src/config/config.dart';
import 'package:crysta_pay/src/data/datasources/secure_storage.dart';
import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:crysta_pay/src/service/wallet/deep_link_service.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

/// Service for connecting to external wallets (MetaMask, Trust Wallet, Ledger) across multiple blockchains
class ExternalWalletService {
  final Random _random = Random.secure();
  final Logger _logger = Logger();
  final DeepLinkService _deepLinkService = DeepLinkService();
  String? _lastUri;

  /// Maps CryptoType to chain ID for WalletConnect
  int _getChainId(CryptoType type) {
    switch (type) {
      case CryptoType.eth:
      case CryptoType.usdt:
        return 1; // Ethereum Mainnet
      case CryptoType.sol:
        return 501; // Solana (custom, verify with Phantom)
      case CryptoType.bnb:
        return 56; // BNB Chain Mainnet
      case CryptoType.matic:
        return 137; // Polygon Mainnet
      case CryptoType.ada:
      case CryptoType.trx:
      case CryptoType.xrp:
        throw Exception('$type not supported via WalletConnect');
      case CryptoType.dot:
        return 354; // Polkadot (custom, verify with Fearless/Polkadot{.js})
      case CryptoType.btc:
        throw Exception('Bitcoin not supported via WalletConnect');
    }
  }

  /// Maps CryptoType to wallet-specific deep link prefix
  String _getWalletDeepLinkPrefix(CryptoType type, String walletType) {
    final lowerWalletType = walletType.toLowerCase();

    // Non-WalletConnect chains
    switch (type) {
      case CryptoType.btc:
        return 'bitcoin:'; // Bitcoin URI scheme
      case CryptoType.trx:
        return 'tronlink://'; // TronLink for Tron
      case CryptoType.xrp:
        return 'xumm://'; // Xumm for Ripple
      case CryptoType.ada:
        return 'yoroi://'; // Yoroi for Cardano
      default:
        break;
    }

    // WalletConnect-supported chains
    switch (type) {
      case CryptoType.eth:
      case CryptoType.usdt:
      case CryptoType.bnb:
      case CryptoType.matic:
        return lowerWalletType == 'metamask_mobile' ? 'metamask://wc?uri=' : 'trust://wc?uri=';
      case CryptoType.sol:
        return 'phantom://wc?uri=';
      case CryptoType.dot:
        return lowerWalletType == 'fearless' ? 'fearless://wc?uri=' : 'polkadot://wc?uri=';
      case CryptoType.ada:
      case CryptoType.trx:
      case CryptoType.xrp:
        throw Exception('$type not supported via WalletConnect');
      case CryptoType.btc:
        throw Exception('Bitcoin not supported via WalletConnect');
    }
  }

  /// Connects to an external wallet for the specified CryptoType and wallet type
  Future<Map<String, dynamic>> connectExternalWallet(
    CryptoType cryptoType,
    String walletType, {
    Map<String, dynamic> params = const {},
  }) async {
    try {
      _logger.i('Connecting to $walletType for $cryptoType with params: $params');
      switch (walletType.toLowerCase()) {
        case 'metamask_mobile':
          if (cryptoType == CryptoType.btc) {
            throw Exception('MetaMask does not support Bitcoin');
          }
          return await _connectWalletConnect(cryptoType, 'metamask_mobile', params);
        case 'trustwallet':
          return cryptoType == CryptoType.btc
              ? await _connectBitcoinWallet(params)
              : await _connectWalletConnect(cryptoType, 'trustwallet', params);
        case 'phantom': // Thêm hỗ trợ Phantom wallet cho Solana
          if (cryptoType != CryptoType.sol) {
            throw Exception('Phantom wallet only supports Solana');
          }
          return await _connectWalletConnect(cryptoType, 'phantom', params);
        case 'ledger':
          return await _connectLedger(cryptoType, params);
        default:
          throw Exception('Unsupported wallet type: $walletType');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to connect to $walletType for $cryptoType', error: e, stackTrace: stackTrace);
      return {
        'success': false,
        'error': 'Failed to connect to $walletType for $cryptoType: $e',
      };
    }
  }

  /// Reconnects to a saved external wallet session
  Future<Map<String, dynamic>> reconnectExternalWallet(CryptoType cryptoType, String walletType) async {
    final walletKey = '${cryptoType.name}_${walletType.toLowerCase()}'; // Sửa lỗi toString().split('.').last
    try {
      final storedSession = await GetIt.I<SecureStorage>().getWalletSession(walletKey);
      if (storedSession == null) {
        throw Exception('No saved session for $walletType ($cryptoType)');
      }

      final sessionData = jsonDecode(storedSession) as Map<String, dynamic>;
      _logger.i('Reconnected to $walletType session for $cryptoType');
      return _validateAndReturnSession(cryptoType, sessionData, _getChainId(cryptoType));
    } catch (e, stackTrace) {
      _logger.e('Failed to reconnect to $walletType for $cryptoType', error: e, stackTrace: stackTrace);
      return { // Sửa lỗi throw Exception thành return Map
        'success': false,
        'error': 'Failed to reconnect to $walletType for $cryptoType: $e',
      };
    }
  }

  /// Connects to a wallet via WalletConnect
  Future<Map<String, dynamic>> _connectWalletConnect(
    CryptoType cryptoType,
    String walletType,
    Map<String, dynamic> params,
  ) async {
    try {
      final connector = _createConnector();
      final chainId = params['chainId'] as int? ?? _getChainId(cryptoType);
      final walletKey = '${cryptoType.name}_${walletType.toLowerCase()}'; // Sửa lỗi toString().split('.').last

      // Check for stored session
      final storedSession = await GetIt.I<SecureStorage>().getWalletSession(walletKey);
      if (storedSession != null) {
        final sessionData = jsonDecode(storedSession) as Map<String, dynamic>;
        _logger.i('Reusing $walletType session for $cryptoType');
        return _validateAndReturnSession(cryptoType, sessionData, chainId);
      }

      // Create new session
      final session = await connector.createSession(
        chainId: chainId,
        onDisplayUri: (uri) async {
          _lastUri = uri;
          final deepLink = _getWalletDeepLinkPrefix(cryptoType, walletType) + Uri.encodeComponent(uri);
          await _deepLinkService.launchDeepLink(cryptoType, deepLink);
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
      _logger.i('Connected to $walletType for $cryptoType: ${result['address']}');

      return result;
    } catch (e, stackTrace) {
      _logger.e('$walletType connection failed for $cryptoType', error: e, stackTrace: stackTrace);
      return { // Sửa lỗi throw Exception thành return Map
        'success': false,
        'error': '$walletType connection failed for $cryptoType: $e',
      };
    }
  }

  /// Connects to a Bitcoin wallet (non-WalletConnect)
  Future<Map<String, dynamic>> _connectBitcoinWallet(Map<String, dynamic> params) async {
    try {
      final address = params['address'] as String? ?? _generateMockBitcoinAddress();
      final deepLink = 'bitcoin:$address';
      await _deepLinkService.launchDeepLink(CryptoType.btc, deepLink);
      _logger.i('Launched Bitcoin wallet deep link for address: $address');
      return {
        'success': true,
        'address': address,
        'type': CryptoType.btc.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Bitcoin wallet connection failed', error: e, stackTrace: stackTrace);
      return { // Sửa lỗi throw Exception thành return Map
        'success': false,
        'error': 'Bitcoin wallet connection failed: $e',
      };
    }
  }

  /// Generates a mock Bech32 Bitcoin address (for testing purposes)
  String _generateMockBitcoinAddress() {
    const bech32Chars = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
    const length = 39;
    final buffer = StringBuffer('bc1');

    for (var i = 0; i < length; i++) {
      buffer.write(bech32Chars[_random.nextInt(bech32Chars.length)]);
    }

    return buffer.toString();
  }

  /// Connects to Ledger for the specified CryptoType
  Future<Map<String, dynamic>> _connectLedger(CryptoType cryptoType, Map<String, dynamic> params) async {
    try {
      // TODO: Replace with actual Ledger integration using ledger_flutter
      _logger.w('Ledger connection for $cryptoType not implemented, using mock response');
      String mockAddress;
      const hexChars = '0123456789abcdef';
      const base58Chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

      switch (cryptoType) {
        case CryptoType.eth:
        case CryptoType.usdt:
        case CryptoType.bnb:
        case CryptoType.matic:
          mockAddress = '0x${_generateRandomString(hexChars, 40)}';
          break;
        case CryptoType.btc:
          mockAddress = 'bc1${_generateRandomString(base58Chars, 39)}';
          break;
        case CryptoType.sol:
          mockAddress = _generateRandomString(base58Chars, 44);
          break;
        case CryptoType.ada:
          mockAddress = 'addr1${_generateRandomString(base58Chars, 58)}';
          break;
        case CryptoType.trx:
          mockAddress = 'T${_generateRandomString(base58Chars, 33)}';
          break;
        case CryptoType.xrp:
          mockAddress = 'r${_generateRandomString(base58Chars, 33)}';
          break;
        case CryptoType.dot:
          mockAddress = '1${_generateRandomString(base58Chars, 46)}';
          break;
      }
      _logger.i('Generated mock Ledger address for $cryptoType: $mockAddress');
      return {
        'success': true,
        'address': mockAddress,
        'type': cryptoType.name,
      };
    } catch (e, stackTrace) {
      _logger.e('Ledger connection failed for $cryptoType', error: e, stackTrace: stackTrace);
      return { // Sửa lỗi throw Exception thành return Map
        'success': false,
        'error': 'Ledger connection failed for $cryptoType: $e',
      };
    }
  }

  /// Generates a random string of specified length from a character set
  String _generateRandomString(String chars, int length) {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  /// Creates a WalletConnect connector with standard configuration
  WalletConnect _createConnector() {
    return WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'Crysta Pay',
        description: 'Crysta Pay Wallet Connector',
        url: 'https://crystapay.com',
        icons: ['https://crystapay.com/logo.png'],
      ),
    );
  }

  /// Validates a WalletConnect session and returns connection details
  Future<Map<String, dynamic>> _validateSession(CryptoType cryptoType, SessionStatus session, int expectedChainId) async {
    // Kiểm tra chain ID chỉ cho các blockchain hỗ trợ WalletConnect
    if (cryptoType != CryptoType.btc && 
        cryptoType != CryptoType.ada && 
        cryptoType != CryptoType.trx && 
        cryptoType != CryptoType.xrp && 
        session.chainId != expectedChainId) {
      throw Exception('Wrong network. Please switch to chain $expectedChainId');
    }

    if (session.accounts.isEmpty) {
      throw Exception('No accounts found in session');
    }

    final address = session.accounts[0];
    
    // Validate address format based on crypto type
    if (_isEVMChain(cryptoType)) {
      try {
        EthereumAddress.fromHex(address);
        _logger.i('Validated EVM address for $cryptoType: $address');
      } catch (e) {
        _logger.e('Invalid EVM address for $cryptoType: $address', error: e);
        throw Exception('Invalid address for $cryptoType: $address');
      }
    } else if (cryptoType == CryptoType.sol) {
      if (!_isValidSolanaAddress(address)) {
        _logger.e('Invalid Solana address: $address');
        throw Exception('Invalid Solana address: $address');
      }
      _logger.i('Validated Solana address: $address');
    }
    // Thêm validation cho các blockchain khác nếu cần

    return {
      'success': true,
      'address': address,
      'type': cryptoType.name,
    };
  }

  /// Validates and returns session data from stored session
  Map<String, dynamic> _validateAndReturnSession(CryptoType cryptoType, Map<String, dynamic> sessionData, int expectedChainId) {
    final chainId = sessionData['chainId'] as int?;
    
    // Kiểm tra chain ID chỉ cho các blockchain hỗ trợ WalletConnect
    if (cryptoType != CryptoType.btc && 
        cryptoType != CryptoType.ada && 
        cryptoType != CryptoType.trx && 
        cryptoType != CryptoType.xrp && 
        chainId != expectedChainId) {
      throw Exception('Wrong network. Please switch to chain $expectedChainId');
    }

    final accounts = sessionData['accounts'] as List<dynamic>?;
    if (accounts == null || accounts.isEmpty) {
      throw Exception('No accounts found in session');
    }

    final address = accounts[0] as String;
    
    // Validate address format based on crypto type
    if (_isEVMChain(cryptoType)) {
      try {
        EthereumAddress.fromHex(address);
        _logger.i('Validated stored EVM address for $cryptoType: $address');
      } catch (e) {
        _logger.e('Invalid stored EVM address for $cryptoType: $address', error: e);
        throw Exception('Invalid stored address for $cryptoType: $address');
      }
    } else if (cryptoType == CryptoType.sol) {
      if (!_isValidSolanaAddress(address)) {
        _logger.e('Invalid stored Solana address: $address');
        throw Exception('Invalid stored Solana address: $address');
      }
      _logger.i('Validated stored Solana address: $address');
    }
    // Thêm validation cho các blockchain khác nếu cần

    return {
      'success': true,
      'address': address,
      'type': cryptoType.name,
    };
  }

  /// Helper method to check if a crypto type is EVM-compatible
  bool _isEVMChain(CryptoType cryptoType) {
    return [
      CryptoType.eth,
      CryptoType.usdt,
      CryptoType.bnb,
      CryptoType.matic,
    ].contains(cryptoType);
  }

  /// Helper method to validate Solana address format
  bool _isValidSolanaAddress(String address) {
    return address.length >= 32 && 
           address.length <= 44 && 
           RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(address);
  }

  /// Gets the last WalletConnect URI for QR code display
  String? get lastUri => _lastUri;

  /// Disconnects from a wallet and clears stored session
  Future<bool> disconnectWallet(CryptoType cryptoType, String walletType) async {
    try {
      final walletKey = '${cryptoType.name}_${walletType.toLowerCase()}';
      await GetIt.I<SecureStorage>().deleteWalletSession(walletKey);
      _logger.i('Disconnected from $walletType for $cryptoType');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Failed to disconnect from $walletType for $cryptoType', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Gets list of supported wallet types for a specific crypto type
  List<String> getSupportedWallets(CryptoType cryptoType) {
    switch (cryptoType) {
      case CryptoType.btc:
        return ['trustwallet', 'ledger'];
      case CryptoType.sol:
        return ['phantom', 'ledger'];
      case CryptoType.eth:
      case CryptoType.usdt:
      case CryptoType.bnb:
      case CryptoType.matic:
        return ['metamask_mobile', 'trustwallet', 'ledger'];
      case CryptoType.ada:
      case CryptoType.trx:
      case CryptoType.xrp:
      case CryptoType.dot:
        return ['ledger']; // Chỉ hỗ trợ Ledger cho các blockchain này
    }
  }
}