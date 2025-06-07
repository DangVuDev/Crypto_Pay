import 'package:crysta_pay/src/data/models/crypto_type_extension.dart';
import 'package:crysta_pay/src/service/encryption_service.dart';
import 'package:crysta_pay/src/service/wallet/wallet_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/wallet_repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;
  final WalletService _walletService;
  final EncryptionService _encryptionService;
  final Uuid _uuid = const Uuid();

  WalletBloc({
    required WalletRepository walletRepository,
    required WalletService walletService,
    required EncryptionService encryptionService,
  })  : _walletRepository = walletRepository,
        _walletService = walletService,
        _encryptionService = encryptionService,
        super(const WalletState()) {
    on<LoadWallets>(_onLoadWallets);
    on<AddWallet>(_onAddWallet);
    on<UpdateWallet>(_onUpdateWallet);
    on<DeleteWallet>(_onDeleteWallet);
    on<RefreshWalletBalances>(_onRefreshWalletBalances);
  }

  Future<void> _onLoadWallets(LoadWallets event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final wallets = await _walletRepository.getAllWallets();
      double totalBalance = 0;

      // Update balances for all wallets
      final updatedWallets = <WalletModel>[];
      for (final wallet in wallets) {
        try {
          final balance = await _walletService.getBalance(wallet.address, wallet.type);
          final usdValue = await _walletService.getUsdValue(wallet.type, balance);
          final updatedWallet = wallet.copyWith(
            balance: balance,
            usdValue: usdValue,
            status: WalletStatus.active,
            updatedAt: DateTime.now(),
          );
          updatedWallets.add(updatedWallet);
          totalBalance += usdValue;
          await _walletRepository.updateWallet(updatedWallet);
        } catch (e) {
          updatedWallets.add(wallet.copyWith(
            status: WalletStatus.error,
            updatedAt: DateTime.now(),
          ));
        }
      }

      emit(state.copyWith(
        wallets: updatedWallets,
        totalBalance: totalBalance,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load wallets: ${e.toString()}',
      ));
    }
  }

 Future<void> _onAddWallet(AddWallet event, Emitter<WalletState> emit) async {
  emit(state.copyWith(isSubmitting: true, error: null));
  try {
    // Check if wallet already exists
    final existingWallets = await _walletRepository.getAllWallets();
    if (existingWallets.any((w) => w.address.toLowerCase() == event.address.toLowerCase())) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Wallet with this address already exists',
      ));
      return;
    }

    final wallet = WalletModel(
      id: _uuid.v4(),
      name: event.name,
      address: event.address,
      type: event.type,
      derivationPath: event.type.derivationPath,
      createdAt: DateTime.now(),
      status: WalletStatus.active,
      metadata: const {
        'creationMethod': 'generated',
      },
    );

    await _walletRepository.saveWallet(wallet);

    final currentWallets = List<WalletModel>.from(state.wallets)..add(wallet);
    final balance = await _walletService.getBalance(wallet.address, wallet.type);
    final usdValue = await _walletService.getUsdValue(wallet.type, balance);

    final updatedWallet = wallet.copyWith(balance: balance, usdValue: usdValue);
    await _walletRepository.updateWallet(updatedWallet);

    emit(state.copyWith(
      wallets: currentWallets.map((w) => w.id == wallet.id ? updatedWallet : w).toList(),
      totalBalance: state.totalBalance + usdValue,
      isSubmitting: false,
    ));
  } catch (e) {
    emit(state.copyWith(
      isSubmitting: false,
      error: 'Failed to add wallet: ${e.toString()}',
    ));
  }
}
  Future<void> _onUpdateWallet(UpdateWallet event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _walletRepository.updateWallet(event.wallet);
      final updatedWallets = state.wallets
          .map((w) => w.id == event.wallet.id ? event.wallet : w)
          .toList();
      final totalBalance = updatedWallets.fold<double>(
        0,
        (sum, w) => sum + w.usdValue,
      );

      emit(state.copyWith(
        wallets: updatedWallets,
        totalBalance: totalBalance,
        isSubmitting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Failed to update wallet: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteWallet(DeleteWallet event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _walletRepository.deleteWallet(event.walletId);
      final updatedWallets = state.wallets
          .where((wallet) => wallet.id != event.walletId)
          .toList();
      final totalBalance = updatedWallets.fold<double>(
        0,
        (sum, w) => sum + w.usdValue,
      );

      emit(state.copyWith(
        wallets: updatedWallets,
        totalBalance: totalBalance,
        isSubmitting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Failed to delete wallet: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshWalletBalances(RefreshWalletBalances event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isRefreshing: true, error: null));
    try {
      final wallets = List<WalletModel>.from(state.wallets);
      double totalBalance = 0;

      for (var i = 0; i < wallets.length; i++) {
        try {
          final balance = await _walletService.getBalance(wallets[i].address, wallets[i].type);
          final usdValue = await _walletService.getUsdValue(wallets[i].type, balance);
          wallets[i] = wallets[i].copyWith(
            balance: balance,
            usdValue: usdValue,
            status: WalletStatus.active,
            updatedAt: DateTime.now(),
          );
          totalBalance += usdValue;
          await _walletRepository.updateWallet(wallets[i]);
        } catch (e) {
          wallets[i] = wallets[i].copyWith(
            status: WalletStatus.error,
            updatedAt: DateTime.now(),
          );
        }
      }

      emit(state.copyWith(
        wallets: wallets,
        totalBalance: totalBalance,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh balances: ${e.toString()}',
      ));
    }
  }
}