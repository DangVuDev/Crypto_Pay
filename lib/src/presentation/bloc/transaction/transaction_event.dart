part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class LoadRecentTransactions extends TransactionEvent {
  final int limit;
  
  const LoadRecentTransactions({this.limit = 5});
  
  @override
  List<Object> get props => [limit];
}

class CreateSendTransaction extends TransactionEvent {
  final String title;
  final String address;
  final double amount;
  final String cryptoType;
  final double feeAmount;
  
  const CreateSendTransaction({
    required this.title,
    required this.address,
    required this.amount,
    required this.cryptoType,
    required this.feeAmount,
  });
  
  @override
  List<Object> get props => [title, address, amount, cryptoType, feeAmount];
}