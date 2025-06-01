import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/wallet_repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;
  final _uuid = const Uuid();
  
  WalletBloc({required this.walletRepository}) : super(const WalletState()) {
    on<LoadWallets>(_onLoadWallets);
    on<AddWallet>(_onAddWallet);
    on<UpdateWallet>(_onUpdateWallet);
    on<DeleteWallet>(_onDeleteWallet);
    on<RefreshWalletBalances>(_onRefreshWalletBalances);
    
    // Load wallets on initialization
    add(LoadWallets());
  }
  
  Future<void> _onLoadWallets(LoadWallets event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final wallets = await walletRepository.getWallets();
      double totalBalance = 0;
      
      for (final wallet in wallets) {
        totalBalance += wallet.usdValue;
      }
      
      emit(state.copyWith(
        wallets: wallets,
        totalBalance: totalBalance,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Không thể tải danh sách ví: $e',
      ));
    }
  }
  
  Future<void> _onAddWallet(AddWallet event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    
    try {
      final newWallet = WalletModel(
        id: _uuid.v4(),
        name: event.name,
        address: event.address,
        type: event.type,
        balance: 0.0,
        usdValue: 0.0,
        status: WalletStatus.active,
        createdAt: DateTime.now(),
      );
      
      final success = await walletRepository.addWallet(newWallet);
      
      if (success) {
        add(LoadWallets());
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          error: 'Ví đã tồn tại hoặc địa chỉ không hợp lệ',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Không thể thêm ví: $e',
      ));
    }
  }
  
  Future<void> _onUpdateWallet(UpdateWallet event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    
    try {
      final success = await walletRepository.updateWallet(event.wallet);
      
      if (success) {
        add(LoadWallets());
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          error: 'Không thể cập nhật ví',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Lỗi cập nhật ví: $e',
      ));
    }
  }
  
  Future<void> _onDeleteWallet(DeleteWallet event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    
    try {
      final success = await walletRepository.deleteWallet(event.walletId);
      
      if (success) {
        add(LoadWallets());
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          error: 'Không thể xóa ví',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Lỗi xóa ví: $e',
      ));
    }
  }
  
  Future<void> _onRefreshWalletBalances(RefreshWalletBalances event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isRefreshing: true));
    
    try {
      final success = await walletRepository.refreshWalletBalances();
      
      if (success) {
        add(LoadWallets());
      } else {
        emit(state.copyWith(
          isRefreshing: false,
          error: 'Không thể cập nhật số dư ví',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        error: 'Lỗi cập nhật số dư: $e',
      ));
    }
  }
}