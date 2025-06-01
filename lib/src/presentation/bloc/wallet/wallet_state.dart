part of 'wallet_bloc.dart';

class WalletState extends Equatable {
  final List<WalletModel> wallets;
  final double totalBalance;
  final bool isLoading;
  final bool isSubmitting;
  final bool isRefreshing;
  final String? error;
  
  const WalletState({
    this.wallets = const [],
    this.totalBalance = 0.0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isRefreshing = false,
    this.error,
  });
  
  WalletState copyWith({
    List<WalletModel>? wallets,
    double? totalBalance,
    bool? isLoading,
    bool? isSubmitting,
    bool? isRefreshing,
    String? error,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      totalBalance: totalBalance ?? this.totalBalance,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [
    wallets, totalBalance, isLoading, isSubmitting, isRefreshing, error
  ];
}