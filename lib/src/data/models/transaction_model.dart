import 'package:equatable/equatable.dart';

enum TransactionType { send, receive, sell, buy }

enum TransactionStatus { completed, pending, failed }

class TransactionModel extends Equatable {
  final String id;
  final String title;
  final String address;
  final double amount;
  final String cryptoType;
  final double feeAmount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? hash;
  final String? notes;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.address,
    required this.amount,
    required this.cryptoType,
    required this.feeAmount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.hash,
    this.notes,
  });
  
  bool get isSent => type == TransactionType.send || type == TransactionType.sell;
  
  String get formattedAmount {
    final prefix = isSent ? '-' : '+';
    final value = amount < 1 ? amount.toStringAsFixed(4) : amount.toStringAsFixed(2);
    return '$prefix$value $cryptoType';
  }
  
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final txDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (txDate == today) {
      return 'Hôm nay, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (txDate == yesterday) {
      return 'Hôm qua, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
  
  String get statusName {
    switch (status) {
      case TransactionStatus.pending:
        return 'Đang xử lý';
      case TransactionStatus.completed:
        return 'Hoàn thành';
      case TransactionStatus.failed:
        return 'Thất bại';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'amount': amount,
      'cryptoType': cryptoType,
      'feeAmount': feeAmount,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'hash': hash,
      'notes': notes,
    };
  }
  
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      amount: json['amount'],
      cryptoType: json['cryptoType'],
      feeAmount: json['feeAmount'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.send,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      hash: json['hash'],
      notes: json['notes'],
    );
  }
  
  @override
  List<Object?> get props => [
    id, title, address, amount, cryptoType, feeAmount, 
    type, status, timestamp, hash, notes
  ];

}