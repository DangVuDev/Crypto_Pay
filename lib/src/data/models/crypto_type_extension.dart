import 'package:flutter/material.dart';
import 'wallet_model.dart';

/// Extension to provide metadata for CryptoType enum
extension CryptoTypeExtension on CryptoType {
  String get displayName {
    switch (this) {
      case CryptoType.eth:
        return 'Ethereum';
      case CryptoType.btc:
        return 'Bitcoin';
      case CryptoType.usdt:
        return 'USDT';
      case CryptoType.sol:
        return 'Solana';
      case CryptoType.bnb:
        return 'BNB';
      case CryptoType.ada:
        return 'Cardano';
      case CryptoType.matic:
        return 'Polygon';
      case CryptoType.trx:
        return 'Tron';
      case CryptoType.xrp:
        return 'Ripple';
      case CryptoType.dot:
        return 'Polkadot';
    }
  }

  String get symbol {
    switch (this) {
      case CryptoType.eth:
        return 'ETH';
      case CryptoType.btc:
        return 'BTC';
      case CryptoType.usdt:
        return 'USDT';
      case CryptoType.sol:
        return 'SOL';
      case CryptoType.bnb:
        return 'BNB';
      case CryptoType.ada:
        return 'ADA';
      case CryptoType.matic:
        return 'MATIC';
      case CryptoType.trx:
        return 'TRX';
      case CryptoType.xrp:
        return 'XRP';
      case CryptoType.dot:
        return 'DOT';
    }
  }

  Color get color {
    switch (this) {
      case CryptoType.eth:
        return const Color(0xFF627EEA); // Ethereum blue
      case CryptoType.btc:
        return const Color(0xFFF7931A); // Bitcoin orange
      case CryptoType.usdt:
        return const Color(0xFF26A17B); // Tether green
      case CryptoType.sol:
        return const Color(0xFF9945FF); // Solana purple
      case CryptoType.bnb:
        return const Color(0xFFF3BA2F); // BNB yellow
      case CryptoType.ada:
        return const Color(0xFF0033AD); // Cardano dark blue
      case CryptoType.matic:
        return const Color(0xFF8247E5); // Polygon purple
      case CryptoType.trx:
        return const Color(0xFFEF0027); // Tron red
      case CryptoType.xrp:
        return const Color(0xFF23292F); // Ripple black
      case CryptoType.dot:
        return const Color(0xFFE6007A); // Polkadot pink
    }
  }

  IconData get icon {
    switch (this) {
      case CryptoType.eth:
        return Icons.diamond;
      case CryptoType.btc:
        return Icons.currency_bitcoin;
      case CryptoType.usdt:
        return Icons.attach_money;
      case CryptoType.sol:
        return Icons.flash_on;
      case CryptoType.bnb:
        return Icons.token;
      case CryptoType.ada:
        return Icons.eco;
      case CryptoType.matic:
        return Icons.layers;
      case CryptoType.trx:
        return Icons.movie;
      case CryptoType.xrp:
        return Icons.water;
      case CryptoType.dot:
        return Icons.hub;
    }
  }

  String get networkName {
    switch (this) {
      case CryptoType.eth:
        return 'Ethereum Mainnet';
      case CryptoType.btc:
        return 'Bitcoin Network';
      case CryptoType.usdt:
        return 'Ethereum (ERC-20)';
      case CryptoType.sol:
        return 'Solana Mainnet';
      case CryptoType.bnb:
        return 'BNB Smart Chain';
      case CryptoType.ada:
        return 'Cardano Mainnet';
      case CryptoType.matic:
        return 'Polygon Mainnet';
      case CryptoType.trx:
        return 'Tron Mainnet';
      case CryptoType.xrp:
        return 'Ripple Network';
      case CryptoType.dot:
        return 'Polkadot Mainnet';
    }
    }

  String get derivationPath {
    switch (this) {
      case CryptoType.eth:
      case CryptoType.usdt:
      case CryptoType.bnb:
      case CryptoType.matic:
        return "m/44'/60'/0'/0/0"; // EVM-compatible
      case CryptoType.btc:
        return "m/44'/0'/0'/0/0";
      case CryptoType.sol:
        return "m/44'/501'/0'/0'";
      case CryptoType.ada:
        return "m/44'/1815'/0'/0/0";
      case CryptoType.trx:
        return "m/44'/195'/0'/0/0";
      case CryptoType.xrp:
        return "m/44'/144'/0'/0/0";
      case CryptoType.dot:
        return "m/44'/354'/0'/0/0";
    }
  }

  int get decimals {
    switch (this) {
      case CryptoType.eth:
        return 18;
      case CryptoType.btc:
        return 8;
      case CryptoType.usdt:
        return 6;
      case CryptoType.sol:
        return 9;
      case CryptoType.bnb:
        return 18;
      case CryptoType.ada:
        return 6;
      case CryptoType.matic:
        return 18;
      case CryptoType.trx:
        return 6;
      case CryptoType.xrp:
        return 6;
      case CryptoType.dot:
        return 10;
    }
  }

  bool get isEVMCompatible {
    switch (this) {
      case CryptoType.eth:
      case CryptoType.usdt:
      case CryptoType.bnb:
      case CryptoType.matic:
        return true;
      case CryptoType.btc:
      case CryptoType.sol:
      case CryptoType.ada:
      case CryptoType.trx:
      case CryptoType.xrp:
      case CryptoType.dot:
        return false;
    }
  }
}