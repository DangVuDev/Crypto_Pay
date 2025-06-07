import 'dart:convert';
import 'package:crysta_pay/src/config/config.dart';
import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:web3dart/web3dart.dart';
import 'package:solana/solana.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:hex/hex.dart';

/// Service for retrieving wallet balances and USD values across multiple blockchains
class BalanceService {
  final http.Client _httpClient = http.Client();
  final Logger _logger = Logger();
  late final SolanaClient _solanaClient;
  late final Web3Client _web3Client;
  late final Web3Client _bnbClient;  
  late final Web3Client _polygonClient;

  BalanceService() {
    _solanaClient = SolanaClient(
      rpcUrl: Uri.parse(AppConfig.solanaRpcUrl),
      websocketUrl: Uri.parse(AppConfig.solanaWsUrl),
    );
    _web3Client = Web3Client(AppConfig.infuraUrl, _httpClient);
    _bnbClient = Web3Client(AppConfig.bnbChainRpcUrl, _httpClient);
    _polygonClient = Web3Client(AppConfig.polygonRpcUrl, _httpClient);
  }

  /// Retrieves the balance for a wallet address based on the cryptocurrency type.
  Future<double> getBalance(String address, CryptoType type) async {
    try {
      switch (type) {
        case CryptoType.eth:
          return await _getEthereumBalance(address);

        case CryptoType.btc:
          return await _getBitcoinBalance(address);

        case CryptoType.usdt:
          return await _getUsdtBalance(address);

        case CryptoType.sol:
          return await _getSolanaBalance(address);

        case CryptoType.bnb:
          return await _getBnbBalance(address);

        case CryptoType.ada:
          return await _getCardanoBalance(address);

        case CryptoType.matic:
          return await _getPolygonBalance(address);

        case CryptoType.trx:
          return await _getTronBalance(address);

        case CryptoType.xrp:
          return await _getXrpBalance(address);

        case CryptoType.dot:
          return await _getPolkadotBalance(address);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to fetch balance for $type', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch balance for $type: $e');
    }
  }

  /// Get Ethereum balance
  Future<double> _getEthereumBalance(String address) async {
    final balance = await _web3Client.getBalance(EthereumAddress.fromHex(address));
    final balanceEth = balance.getInEther.toDouble();
    _logger.i('Fetched ETH balance for $address: $balanceEth ETH');
    return balanceEth;
  }

  /// Get Bitcoin balance using bitcoin_base
  Future<double> _getBitcoinBalance(String address) async {
    try {
      // Using BlockCypher API as bitcoin_base doesn't provide direct balance query
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.blockcypherApi}/addrs/$address/balance'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balanceSatoshis = data['balance'] as int;
        final balanceBtc = balanceSatoshis / 100000000; // Convert satoshis to BTC
        _logger.i('Fetched BTC balance for $address: $balanceBtc BTC');
        return balanceBtc;
      } else {
        throw Exception('Failed to fetch BTC balance: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching BTC balance: $e');
      rethrow;
    }
  }

  /// Get USDT balance (ERC-20 token)
  Future<double> _getUsdtBalance(String address) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(AppConfig.usdtAbi, 'USDT'),
      EthereumAddress.fromHex(AppConfig.usdtContractAddress),
    );
    
    final balanceFunction = contract.function('balanceOf');
    final result = await _web3Client.call(
      contract: contract,
      function: balanceFunction,
      params: [EthereumAddress.fromHex(address)],
    );
    
    final balanceUsdt = (result[0] as BigInt) / BigInt.from(1000000); // USDT has 6 decimals
    _logger.i('Fetched USDT balance for $address: $balanceUsdt USDT');
    return balanceUsdt.toDouble();
  }

  /// Get Solana balance using HTTP RPC call
  Future<double> _getSolanaBalance(String address) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(AppConfig.solanaRpcUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'getBalance',
          'params': [address],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['error'] != null) {
          throw Exception('RPC Error: ${data['error']['message']}');
        }
        
        final lamports = data['result']['value'] as int;
        final sol = lamports / 1000000000; // Convert lamports to SOL
        
        _logger.i('Fetched SOL balance for $address: $sol SOL');
        return sol;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to fetch SOL balance for $address', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch SOL balance: $e');
    }
  }

  /// Get BNB balance
  Future<double> _getBnbBalance(String address) async {
    final balance = await _bnbClient.getBalance(EthereumAddress.fromHex(address));
    final balanceBnb = balance.getInEther.toDouble();
    _logger.i('Fetched BNB balance for $address: $balanceBnb BNB');
    return balanceBnb;
  }

  /// Get Cardano balance
  Future<double> _getCardanoBalance(String address) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.blockfrostApi}/addresses/$address'),
        headers: {'project_id': AppConfig.blockfrostApiKey},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle case where amount might be empty or different structure
        final amounts = data['amount'] as List;
        if (amounts.isNotEmpty) {
          final balanceLovelace = int.parse(amounts[0]['quantity'].toString());
          final balanceAda = balanceLovelace / 1000000; // Convert Lovelace to ADA
          _logger.i('Fetched ADA balance for $address: $balanceAda ADA');
          return balanceAda.toDouble();
        }
        return 0.0;
      } else {
        throw Exception('Failed to fetch ADA balance: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching ADA balance: $e');
      return 0.0;
    }
  }

  /// Get Polygon (MATIC) balance
  Future<double> _getPolygonBalance(String address) async {
    final balance = await _polygonClient.getBalance(EthereumAddress.fromHex(address));
    final balanceMatic = balance.getInEther.toDouble();
    _logger.i('Fetched MATIC balance for $address: $balanceMatic MATIC');
    return balanceMatic;
  }

  /// Get Tron balance
  Future<double> _getTronBalance(String address) async {
    try {
      // Using TronGrid API with proper POST request
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.tronGridApi}/wallet/getaccount'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'address': address}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balanceSun = data['balance'] ?? 0;
        final balanceTrx = balanceSun / 1000000; // Convert Sun to TRX
        _logger.i('Fetched TRX balance for $address: $balanceTrx TRX');
        return balanceTrx.toDouble();
      } else {
        throw Exception('Failed to fetch TRX balance: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching TRX balance: $e');
      return 0.0; // Return 0 if error occurs
    }
  }

  /// Get XRP balance
  Future<double> _getXrpBalance(String address) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('https://api.xrpscan.com/api/v1/account/$address'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balanceDrops = int.parse(data['account_data']['Balance'].toString());
        final balanceXrp = balanceDrops / 1000000; // Convert Drops to XRP
        _logger.i('Fetched XRP balance for $address: $balanceXrp XRP');
        return balanceXrp.toDouble();
      } else {
        throw Exception('Failed to fetch XRP balance: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching XRP balance: $e');
      return 0.0;
    }
  }

  /// Get Polkadot balance
  Future<double> _getPolkadotBalance(String address) async {
    try {
      // Using Polkadot API with correct method name
      final response = await _httpClient.post(
        Uri.parse(AppConfig.polkadotRpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'system_account',
          'params': [address],
          'id': 1,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['data'] != null) {
          final balancePlanck = int.parse(data['result']['data']['free'].toString());
          final balanceDot = balancePlanck / 10000000000; // Convert Planck to DOT
          _logger.i('Fetched DOT balance for $address: $balanceDot DOT');
          return balanceDot.toDouble();
        }
        return 0.0;
      } else {
        throw Exception('Failed to fetch DOT balance: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching DOT balance: $e');
      return 0.0; // Return 0 if error occurs
    }
  }

  /// Retrieves the USD value for a given amount of cryptocurrency.
  Future<double> getUsdValue(CryptoType type, double amount) async {
    try {
      final cryptoId = _getCoinGeckoId(type);
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.coingeckoApi}?ids=$cryptoId&vs_currencies=usd'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usdPrice = data[cryptoId]['usd'] as double;
        _logger.i('Fetched USD price for $type: $usdPrice');
        return amount * usdPrice;
      } else {
        throw Exception('Failed to fetch USD value: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to fetch USD value for $type', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch USD value for $type: $e');
    }
  }

  /// Gets the current price of a cryptocurrency in USD.
  Future<double> getCryptoPrice(CryptoType type) async {
    try {
      final cryptoId = _getCoinGeckoId(type);
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.coingeckoApi}?ids=$cryptoId&vs_currencies=usd'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usdPrice = data[cryptoId]['usd'] as double;
        _logger.i('Fetched current $type price: $usdPrice USD');
        return usdPrice;
      } else {
        throw Exception('Failed to fetch crypto price: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to fetch crypto price for $type', error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch crypto price for $type: $e');
    }
  }

  /// Maps CryptoType to CoinGecko API IDs.
  String _getCoinGeckoId(CryptoType type) {
    switch (type) {
      case CryptoType.eth: return 'ethereum';
      case CryptoType.btc: return 'bitcoin';
      case CryptoType.usdt: return 'tether';
      case CryptoType.sol: return 'solana';
      case CryptoType.bnb: return 'binancecoin';
      case CryptoType.ada: return 'cardano';
      case CryptoType.matic: return 'matic-network';
      case CryptoType.trx: return 'tron';
      case CryptoType.xrp: return 'ripple';
      case CryptoType.dot: return 'polkadot';
    }
  }

  /// Disposes of the HTTP client and other resources.
  void dispose() {
    _httpClient.close();
  }
}