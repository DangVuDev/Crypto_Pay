import 'package:crysta_pay/src/config/config.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crysta_pay/src/data/models/wallet_model.dart';

/// Service for handling deep links to external wallet applications
class DeepLinkService {
  final Logger _logger = Logger();

  /// Generates a deep link URI based on the CryptoType and wallet address.
  String _generateDeepLink(CryptoType type, String address, {String? amount, String? contractAddress}) {
    try {
      switch (type) {
        case CryptoType.eth:
          // MetaMask deep link for Ethereum (view address or send transaction)
          return amount != null
              ? 'metamask://wc?uri=ethereum:$address@1?value=${(double.parse(amount) * 1e18).toStringAsFixed(0)}'
              : 'metamask://wc?uri=ethereum:$address@1';

        case CryptoType.btc:
          // Bitcoin deep link (e.g., Trust Wallet or generic Bitcoin wallet)
          return amount != null
              ? 'bitcoin:$address?amount=$amount'
              : 'bitcoin:$address';

        case CryptoType.usdt:
          // USDT as ERC-20 on Ethereum or Tron
          if (contractAddress == null) {
            throw Exception('USDT requires a contract address for deep linking');
          }
          if (contractAddress == AppConfig.usdtTronContractAddress) {
            // USDT on Tron, using TronLink
            return amount != null
                ? 'tronlink://transfer?address=$address&amount=${(double.parse(amount) * 1e6).toStringAsFixed(0)}&contract=$contractAddress'
                : 'tronlink://wallet?address=$address';
          }
          // Default to Ethereum USDT, using MetaMask
          return amount != null
              ? 'metamask://wc?uri=ethereum:$contractAddress@1/transfer?address=$address&uint256=${(double.parse(amount) * 1e6).toStringAsFixed(0)}'
              : 'metamask://wc?uri=ethereum:$address@1';

        case CryptoType.sol:
          // Phantom wallet deep link for Solana
          return amount != null
              ? 'phantom://wallet?network=mainnet&address=$address&amount=$amount'
              : 'phantom://wallet?network=mainnet&address=$address';

        case CryptoType.bnb:
          // BNB Chain (EVM-compatible), using MetaMask
          return amount != null
              ? 'metamask://wc?uri=binance:$address@56?value=${(double.parse(amount) * 1e18).toStringAsFixed(0)}'
              : 'metamask://wc?uri=binance:$address@56';

        case CryptoType.ada:
          // Yoroi wallet deep link for Cardano
          return amount != null
              ? 'yoroi://send?address=$address&amount=$amount'
              : 'yoroi://wallet?address=$address';

        case CryptoType.matic:
          // Polygon (EVM-compatible), using MetaMask
          return amount != null
              ? 'metamask://wc?uri=polygon:$address@137?value=${(double.parse(amount) * 1e18).toStringAsFixed(0)}'
              : 'metamask://wc?uri=polygon:$address@137';

        case CryptoType.trx:
          // TronLink wallet deep link for Tron
          return amount != null
              ? 'tronlink://transfer?address=$address&amount=${(double.parse(amount) * 1e6).toStringAsFixed(0)}'
              : 'tronlink://wallet?address=$address';

        case CryptoType.xrp:
          // Xumm wallet deep link for Ripple
          return amount != null
              ? 'xumm://pay?destination=$address&amount=$amount'
              : 'xumm://account?address=$address';

        case CryptoType.dot:
          // Polkadot{.js} or Fearless wallet deep link for Polkadot
          return amount != null
              ? 'polkadot://transfer?address=$address&amount=${(double.parse(amount) * 1e10).toStringAsFixed(0)}'
              : 'polkadot://wallet?address=$address';
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to generate deep link for $type', error: e, stackTrace: stackTrace);
      throw Exception('Failed to generate deep link for $type: $e');
    }
  }

  /// Launches a deep link to open a wallet app for a specific CryptoType and address.
  Future<void> launchDeepLink(CryptoType type, String address, {String? amount, String? contractAddress}) async {
    try {
      final uri = _generateDeepLink(type, address, amount: amount, contractAddress: contractAddress);
      final url = Uri.parse(uri);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        _logger.i('Launched deep link for $type: $uri');
      } else {
        _logger.w('Cannot launch deep link: $uri. Ensure the wallet app is installed and deep link scheme is configured.');
        throw Exception('Failed to open wallet app for $type. Ensure the wallet app is installed.');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to launch deep link for $type', error: e, stackTrace: stackTrace);
      throw Exception('Failed to launch deep link for $type: $e');
    }
  }
}