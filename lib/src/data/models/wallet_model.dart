// import 'dart:ffi';

// import 'package:equatable/equatable.dart';
// import 'package:flutter/src/widgets/icon_data.dart';

// enum CryptoType { eth, btc, usdt, sol, bnb }

// enum WalletStatus { active, locked, inactive }

// class WalletModel extends Equatable {
//   final String id;
//   final String name;
//   final String address;
//   final CryptoType type;
//   final double balance;
//   final double usdValue;
//   final WalletStatus status;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//   final bool isHardwareWallet;
  
//   const WalletModel({
//     required this.id,
//     required this.name,
//     required this.address,
//     required this.type,
//     required this.balance,
//     required this.usdValue,
//     this.status = WalletStatus.active,
//     required this.createdAt,
//     this.updatedAt,
//     this.isHardwareWallet = false
//   });
  
//   WalletModel copyWith({
//     String? name,
//     double? balance,
//     double? usdValue,
//     WalletStatus? status,
//     DateTime? updatedAt,
//   }) {
//     return WalletModel(
//       id: id,
//       name: name ?? this.name,
//       address: address,
//       type: type,
//       balance: balance ?? this.balance,
//       usdValue: usdValue ?? this.usdValue,
//       status: status ?? this.status,
//       createdAt: createdAt,
//       updatedAt: updatedAt ?? DateTime.now(),
//     );
//   }
  
//   String get formattedBalance {
//     if (type == CryptoType.usdt) {
//       return balance.toStringAsFixed(2);
//     } else if (balance < 1) {
//       return balance.toStringAsFixed(4);
//     } else {
//       return balance.toStringAsFixed(2);
//     }
//   }
  
//   String get formattedUsdValue {
//     return '\$${usdValue.toStringAsFixed(2)}';
//   }
  
//   String get typeName {
//     return type.name.toUpperCase();
//   }
  
//   String get statusName {
//     switch (status) {
//       case WalletStatus.active:
//         return 'Hoạt động';
//       case WalletStatus.locked:
//         return 'Khóa';
//       case WalletStatus.inactive:
//         return 'Không hoạt động';
//     }
//   }
  
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'address': address,
//       'type': type.name,
//       'balance': balance,
//       'usdValue': usdValue,
//       'status': status.name,
//       'createdAt': createdAt.millisecondsSinceEpoch,
//       'updatedAt': updatedAt?.millisecondsSinceEpoch,
//     };
//   }
  
//   factory WalletModel.fromJson(Map<String, dynamic> json) {
//     return WalletModel(
//       id: json['id'],
//       name: json['name'],
//       address: json['address'],
//       type: CryptoType.values.firstWhere(
//         (e) => e.name == json['type'],
//         orElse: () => CryptoType.eth,
//       ),
//       balance: json['balance'],
//       usdValue: json['usdValue'],
//       status: WalletStatus.values.firstWhere(
//         (e) => e.name == json['status'],
//         orElse: () => WalletStatus.active,
//       ),
//       createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
//       updatedAt: json['updatedAt'] != null 
//         ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
//         : null,
//     );
//   }
  
//   @override
//   List<Object?> get props => [
//     id, name, address, type, balance, usdValue, status, createdAt, updatedAt
//   ];
// }
// lib/src/data/models/wallet_model.dart
import 'package:equatable/equatable.dart';

enum CryptoType {
  eth,   // Ethereum
  btc,   // Bitcoin
  usdt,  // Tether (on Ethereum, BNB Chain, or Tron)
  sol,   // Solana
  bnb,   // BNB Chain
  ada,   // Cardano
  matic, // Polygon
  trx,   // Tron
  xrp,   // Ripple
  dot,   // Polkadot
}

enum WalletStatus {
  active,
  locked,
  pending,
  error,
}

class WalletModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final CryptoType type;
  final double balance;
  final double usdValue;
  final WalletStatus status;
  final bool isHardwareWallet;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? derivationPath;
  final String? publicKey;
  final Map<String, dynamic>? metadata;

  const WalletModel({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    this.balance = 0.0,
    this.usdValue = 0.0,
    this.status = WalletStatus.pending,
    this.isHardwareWallet = false,
    required this.createdAt,
    this.updatedAt,
    this.derivationPath,
    this.publicKey,
    this.metadata,
  });

  WalletModel copyWith({
    String? id,
    String? name,
    String? address,
    CryptoType? type,
    double? balance,
    double? usdValue,
    WalletStatus? status,
    bool? isHardwareWallet,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? derivationPath,
    String? publicKey,
    Map<String, dynamic>? metadata,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      usdValue: usdValue ?? this.usdValue,
      status: status ?? this.status,
      isHardwareWallet: isHardwareWallet ?? this.isHardwareWallet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      derivationPath: derivationPath ?? this.derivationPath,
      publicKey: publicKey ?? this.publicKey,
      metadata: metadata ?? this.metadata,
    );
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
      'isHardwareWallet': isHardwareWallet,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'derivationPath': derivationPath,
      'publicKey': publicKey,
      'metadata': metadata,
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      type: CryptoType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CryptoType.eth,
      ),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      usdValue: (json['usdValue'] as num?)?.toDouble() ?? 0.0,
      status: WalletStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WalletStatus.pending,
      ),
      isHardwareWallet: json['isHardwareWallet'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      derivationPath: json['derivationPath'] as String?,
      publicKey: json['publicKey'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    type,
    balance,
    usdValue,
    status,
    isHardwareWallet,
    createdAt,
    updatedAt,
    derivationPath,
    publicKey,
    metadata,
  ];

  @override
  String toString() {
    return 'WalletModel(id: $id, name: $name, type: $type, balance: $balance)';
  }
}