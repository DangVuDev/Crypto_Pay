import 'dart:math';
import 'package:crysta_pay/src/data/datasources/app_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/logger.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final AppPreferences preferences;
  static const String _walletsKey = 'user_wallets';
  final _uuid = const Uuid();
  
  WalletRepository({
    required this.preferences,
  });
  
  Future<List<WalletModel>> getWallets() async {
    try {
      final walletsList = preferences.getObjectList(_walletsKey);
      
      if (walletsList == null || walletsList.isEmpty) {
        // Generate sample wallets for demo
        final sampleWallets = _generateSampleWallets();
        await saveWallets(sampleWallets);
        return sampleWallets;
      }
      
      return walletsList.map((e) => WalletModel.fromJson(e)).toList();
    } catch (e) {
      AppLogger.error('Error getting wallets: $e');
      return [];
    }
  }
  
  Future<bool> addWallet(WalletModel wallet) async {
    try {
      final wallets = await getWallets();
      
      // Check if wallet with the same address already exists
      if (wallets.any((w) => w.address.toLowerCase() == wallet.address.toLowerCase())) {
        return false;
      }
      
      wallets.add(wallet);
      await saveWallets(wallets);
      return true;
    } catch (e) {
      AppLogger.error('Error adding wallet: $e');
      return false;
    }
  }
  
  Future<bool> updateWallet(WalletModel wallet) async {
    try {
      final wallets = await getWallets();
      final index = wallets.indexWhere((w) => w.id == wallet.id);
      
      if (index == -1) return false;
      
      wallets[index] = wallet;
      await saveWallets(wallets);
      return true;
    } catch (e) {
      AppLogger.error('Error updating wallet: $e');
      return false;
    }
  }
  
  Future<bool> deleteWallet(String walletId) async {
    try {
      final wallets = await getWallets();
      final filteredWallets = wallets.where((w) => w.id != walletId).toList();
      
      if (wallets.length == filteredWallets.length) return false;
      
      await saveWallets(filteredWallets);
      return true;
    } catch (e) {
      AppLogger.error('Error deleting wallet: $e');
      return false;
    }
  }
  
  Future<void> saveWallets(List<WalletModel> wallets) async {
    final walletJsonList = wallets.map((w) => w.toJson()).toList();
    await preferences.setObjectList(_walletsKey, walletJsonList);
  }
  
  List<WalletModel> _generateSampleWallets() {
    final now = DateTime.now();
    final rng = Random();
    
    return [
      WalletModel(
        id: _uuid.v4(),
        name: 'Ví Ethereum',
        address: '0x1234567890abcdef1234567890abcdef12345678',
        type: CryptoType.eth,
        balance: 0.5 + (rng.nextDouble() * 0.1),
        usdValue: 1750.00 + (rng.nextDouble() * 100),
        status: WalletStatus.active,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      WalletModel(
        id: _uuid.v4(),
        name: 'Ví Bitcoin',
        address: '1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
        type: CryptoType.btc,
        balance: 0.02 + (rng.nextDouble() * 0.01),
        usdValue: 1200.00 + (rng.nextDouble() * 100),
        status: WalletStatus.locked,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      WalletModel(
        id: _uuid.v4(),
        name: 'Ví USDT',
        address: '0xabcdef1234567890abcdef1234567890abcdef12',
        type: CryptoType.usdt,
        balance: 500.0 + (rng.nextDouble() * 50),
        usdValue: 500.00 + (rng.nextDouble() * 50),
        status: WalletStatus.active,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }
  
  Future<bool> refreshWalletBalances() async {
    try {
      final wallets = await getWallets();
      final rng = Random();
      
      // Simulate balance updates
      for (int i = 0; i < wallets.length; i++) {
        final variation = rng.nextDouble() * 0.05 * (rng.nextBool() ? 1 : -1);
        final newBalance = wallets[i].balance * (1 + variation);
        final newUsdValue = wallets[i].usdValue * (1 + variation);
        
        wallets[i] = wallets[i].copyWith(
          balance: newBalance,
          usdValue: newUsdValue,
          updatedAt: DateTime.now(),
        );
      }
      
      await saveWallets(wallets);
      return true;
    } catch (e) {
      AppLogger.error('Error refreshing wallet balances: $e');
      return false;
    }
  }
}