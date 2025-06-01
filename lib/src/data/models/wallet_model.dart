import 'package:equatable/equatable.dart';
import 'package:flutter/src/widgets/icon_data.dart';

enum CryptoType { eth, btc, usdt, sol, bnb }

enum WalletStatus { active, locked, inactive }

class WalletModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final CryptoType type;
  final double balance;
  final double usdValue;
  final WalletStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const WalletModel({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.balance,
    required this.usdValue,
    this.status = WalletStatus.active,
    required this.createdAt,
    this.updatedAt,
  });
  
  WalletModel copyWith({
    String? name,
    double? balance,
    double? usdValue,
    WalletStatus? status,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id,
      name: name ?? this.name,
      address: address,
      type: type,
      balance: balance ?? this.balance,
      usdValue: usdValue ?? this.usdValue,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  String get formattedBalance {
    if (type == CryptoType.usdt) {
      return balance.toStringAsFixed(2);
    } else if (balance < 1) {
      return balance.toStringAsFixed(4);
    } else {
      return balance.toStringAsFixed(2);
    }
  }
  
  String get formattedUsdValue {
    return '\$${usdValue.toStringAsFixed(2)}';
  }
  
  String get typeName {
    return type.name.toUpperCase();
  }
  
  String get statusName {
    switch (status) {
      case WalletStatus.active:
        return 'Hoạt động';
      case WalletStatus.locked:
        return 'Khóa';
      case WalletStatus.inactive:
        return 'Không hoạt động';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type.name,
      'balance': balance,
      'usdValue': usdValue,
      'status': status.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
  
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      type: CryptoType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CryptoType.eth,
      ),
      balance: json['balance'],
      usdValue: json['usdValue'],
      status: WalletStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WalletStatus.active,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
        : null,
    );
  }
  
  @override
  List<Object?> get props => [
    id, name, address, type, balance, usdValue, status, createdAt, updatedAt
  ];
}