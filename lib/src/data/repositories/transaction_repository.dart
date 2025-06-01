import 'dart:math';
import 'package:crysta_pay/src/core/utils/logger.dart';
import 'package:crysta_pay/src/data/datasources/app_preferences.dart';
import 'package:uuid/uuid.dart';


import '../models/transaction_model.dart';

class TransactionRepository {
  final AppPreferences preferences;
  static const String _transactionsKey = 'user_transactions';
  final _uuid = const Uuid();
  
  TransactionRepository({
    required this.preferences,
  });
  
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final transactionsList = preferences.getObjectList(_transactionsKey);
      
      if (transactionsList == null || transactionsList.isEmpty) {
        // Generate sample transactions for demo
        final sampleTransactions = _generateSampleTransactions();
        await saveTransactions(sampleTransactions);
        return sampleTransactions;
      }
      
      return transactionsList.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      AppLogger.error('Error getting transactions: $e');
      return [];
    }
  }
  
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    final transactions = await getTransactions();
    
    // Sort by timestamp descending and limit to requested count
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return transactions.take(limit).toList();
  }
  
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final transactions = await getTransactions();
      transactions.add(transaction);
      await saveTransactions(transactions);
      return true;
    } catch (e) {
      AppLogger.error('Error adding transaction: $e');
      return false;
    }
  }
  
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final transactions = await getTransactions();
      return transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      AppLogger.error('Error getting transaction by ID: $e');
      return null;
    }
  }
  
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final transactionJsonList = transactions.map((t) => t.toJson()).toList();
    await preferences.setObjectList(_transactionsKey, transactionJsonList);
  }
  
  List<TransactionModel> _generateSampleTransactions() {
    final now = DateTime.now();
    final rng = Random();
    
    return [
      TransactionModel(
        id: _uuid.v4(),
        title: 'Gửi tới 0x123...456',
        address: '0x1234567890abcdef1234567890abcdef12345678',
        amount: 0.1,
        cryptoType: 'ETH',
        feeAmount: 0.001,
        type: TransactionType.send,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(hours: 3)),
        hash: '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Nhận từ 0x789...012',
        address: '0x7890123456abcdef7890123456abcdef78901234',
        amount: 0.2,
        cryptoType: 'ETH',
        feeAmount: 0.0,
        type: TransactionType.receive,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        hash: '0x7890123456abcdef7890123456abcdef7890123456abcdef7890123456abcdef',
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Mua BTC',
        address: '1BoatSLRHtKNngkdXEeobR76b53LETtpyT',
        amount: 0.01,
        cryptoType: 'BTC',
        feeAmount: 0.0,
        type: TransactionType.buy,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(days: 2, hours: 8)),
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Staking ETH',
        address: '0x1234567890abcdef1234567890abcdef12345678',
        amount: 0.05,
        cryptoType: 'ETH',
        feeAmount: 0.001,
        type: TransactionType.buy,
        status: TransactionStatus.pending,
        timestamp: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Swap ETH to USDT',
        address: '0xabcdef1234567890abcdef1234567890abcdef12',
        amount: 100,
        cryptoType: 'USDT',
        feeAmount: 0.002,
        type: TransactionType.receive,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(days: 3, hours: 12)),
      ),
    ];
  }
  
  Future<TransactionModel> createSendTransaction({
    required String title,
    required String address,
    required double amount,
    required String cryptoType,
    required double feeAmount,
  }) async {
    final transaction = TransactionModel(
      id: _uuid.v4(),
      title: title,
      address: address,
      amount: amount,
      cryptoType: cryptoType,
      feeAmount: feeAmount,
      type: TransactionType.send,
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
    );
    
    await addTransaction(transaction);
    
    // Simulate transaction processing
    await Future.delayed(const Duration(seconds: 2));
    
    // Update to completed status
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    
    if (index != -1) {
      final updatedTransaction = TransactionModel(
        id: transaction.id,
        title: transaction.title,
        address: transaction.address,
        amount: transaction.amount,
        cryptoType: transaction.cryptoType,
        feeAmount: transaction.feeAmount,
        type: transaction.type,
        status: TransactionStatus.completed,
        timestamp: transaction.timestamp,
        hash: '0x${_uuid.v4().replaceAll('-', '')}',
      );
      
      transactions[index] = updatedTransaction;
      await saveTransactions(transactions);
      
      return updatedTransaction;
    }
    
    return transaction;
  }
}