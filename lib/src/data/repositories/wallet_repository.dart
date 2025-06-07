// lib/src/data/repositories/wallet_repository.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/wallet_model.dart';

abstract class WalletRepository {
  Future<List<WalletModel>> getAllWallets();
  Future<WalletModel?> getWalletById(String id);
  Future<void> saveWallet(WalletModel wallet);
  Future<void> updateWallet(WalletModel wallet);
  Future<void> deleteWallet(String id);
  Future<void> clearAllWallets();
}

class WalletRepositoryImpl implements WalletRepository {
  static const String _walletsKey = 'wallets';
  late SharedPreferences _prefs;
  bool _initialized = false;

  WalletRepositoryImpl(){}

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  @override
  Future<List<WalletModel>> getAllWallets() async {
    await _ensureInitialized();
    
    try {
      final walletsJson = _prefs.getStringList(_walletsKey) ?? [];
      return walletsJson
          .map((json) => WalletModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load wallets: $e');
    }
  }

  @override
  Future<WalletModel?> getWalletById(String id) async {
    await _ensureInitialized();
    
    try {
      final wallets = await getAllWallets();
      return wallets.firstWhere(
        (wallet) => wallet.id == id,
        orElse: () => throw StateError('Wallet not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveWallet(WalletModel wallet) async {
    await _ensureInitialized();
    
    try {
      final wallets = await getAllWallets();
      
      // Check if wallet already exists
      final existingIndex = wallets.indexWhere((w) => w.id == wallet.id);
      if (existingIndex != -1) {
        throw Exception('Wallet with ID ${wallet.id} already exists');
      }
      
      wallets.add(wallet);
      await _saveWallets(wallets);
    } catch (e) {
      throw Exception('Failed to save wallet: $e');
    }
  }

  @override
  Future<void> updateWallet(WalletModel wallet) async {
    await _ensureInitialized();
    
    try {
      final wallets = await getAllWallets();
      final index = wallets.indexWhere((w) => w.id == wallet.id);
      
      if (index == -1) {
        throw Exception('Wallet with ID ${wallet.id} not found');
      }
      
      wallets[index] = wallet;
      await _saveWallets(wallets);
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  @override
  Future<void> deleteWallet(String id) async {
    await _ensureInitialized();
    
    try {
      final wallets = await getAllWallets();
      wallets.removeWhere((wallet) => wallet.id == id);
      await _saveWallets(wallets);
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }

  @override
  Future<void> clearAllWallets() async {
    await _ensureInitialized();
    
    try {
      await _prefs.remove(_walletsKey);
    } catch (e) {
      throw Exception('Failed to clear wallets: $e');
    }
  }

  Future<void> _saveWallets(List<WalletModel> wallets) async {
    try {
      final walletsJson = wallets
          .map((wallet) => jsonEncode(wallet.toJson()))
          .toList();
      await _prefs.setStringList(_walletsKey, walletsJson);
    } catch (e) {
      throw Exception('Failed to save wallets to storage: $e');
    }
  }

  // Additional utility methods
  Future<List<WalletModel>> getWalletsByType(CryptoType type) async {
    final wallets = await getAllWallets();
    return wallets.where((wallet) => wallet.type == type).toList();
  }

  Future<List<WalletModel>> getActiveWallets() async {
    final wallets = await getAllWallets();
    return wallets.where((wallet) => wallet.status == WalletStatus.active).toList();
  }

  Future<List<WalletModel>> getHardwareWallets() async {
    final wallets = await getAllWallets();
    return wallets.where((wallet) => wallet.isHardwareWallet).toList();
  }

  Future<double> getTotalUsdValue() async {
    final wallets = await getAllWallets();
    return wallets.fold<double>(0, (sum, wallet) => sum + wallet.usdValue);
  }

  Future<Map<CryptoType, int>> getWalletCountByType() async {
    final wallets = await getAllWallets();
    final Map<CryptoType, int> counts = {};
    
    for (final type in CryptoType.values) {
      counts[type] = wallets.where((w) => w.type == type).length;
    }
    
    return counts;
  }

  Future<bool> walletExistsByAddress(String address) async {
    final wallets = await getAllWallets();
    return wallets.any((wallet) => wallet.address.toLowerCase() == address.toLowerCase());
  }

  Future<List<WalletModel>> getRecentWallets({int limit = 5}) async {
    final wallets = await getAllWallets();
    wallets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return wallets.take(limit).toList();
  }
}