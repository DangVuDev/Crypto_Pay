import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? phone;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
  });
  
  UserModel copyWith({
    String? name,
    String? email,
    String? avatar,
    String? phone,
    bool? isVerified,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'phone': phone,
      'isVerified': isVerified,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      phone: json['phone'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
        : null,
    );
  }
  
  @override
  List<Object?> get props => [
    id, name, email, avatar, phone, isVerified, createdAt, updatedAt
  ];
}