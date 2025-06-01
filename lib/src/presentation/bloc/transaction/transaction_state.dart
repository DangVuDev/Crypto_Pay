part of 'transaction_bloc.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final List<TransactionModel> recentTransactions;
  final TransactionModel? lastTransaction;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  
  const TransactionState({
    this.transactions = const [],
    this.recentTransactions = const [],
    this.lastTransaction,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });
  
  TransactionState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? recentTransactions,
    TransactionModel? lastTransaction,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      lastTransaction: lastTransaction ?? this.lastTransaction,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [
    transactions, recentTransactions, lastTransaction, 
    isLoading, isSubmitting, error
  ];
}