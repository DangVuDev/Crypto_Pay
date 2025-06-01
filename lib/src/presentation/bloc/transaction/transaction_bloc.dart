import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc({required this.transactionRepository}) : super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadRecentTransactions>(_onLoadRecentTransactions);
    on<CreateSendTransaction>(_onCreateSendTransaction);

    // Load transactions on initialization
    add(const LoadRecentTransactions());
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final transactions = await transactionRepository.getTransactions();

      emit(state.copyWith(
        transactions: transactions,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'load_transactions_failed: $e', // Use error key for localization
      ));
    }
  }

  Future<void> _onLoadRecentTransactions(LoadRecentTransactions event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final transactions = await transactionRepository.getRecentTransactions(
        limit: event.limit,
      );

      emit(state.copyWith(
        recentTransactions: transactions,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'load_recent_transactions_failed: $e', // Use error key for localization
      ));
    }
  }

  Future<void> _onCreateSendTransaction(CreateSendTransaction event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      final transaction = await transactionRepository.createSendTransaction(
        title: event.title,
        address: event.address,
        amount: event.amount,
        cryptoType: event.cryptoType,
        feeAmount: event.feeAmount,
      );

      // Refresh transactions
      add(const LoadRecentTransactions());

      emit(state.copyWith(
        lastTransaction: transaction,
        isSubmitting: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'create_transaction_failed: $e', // Use error key for localization
      ));
    }
  }
}