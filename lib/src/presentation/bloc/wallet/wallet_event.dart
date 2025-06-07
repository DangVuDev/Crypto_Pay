part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallets extends WalletEvent {}

class AddWallet extends WalletEvent {
  final String name;
  final String address;
  final CryptoType type;

  const AddWallet({
    required this.name,
    required this.address,
    required this.type,
  });

  @override
  List<Object> get props => [name, address, type];
}

class UpdateWallet extends WalletEvent {
  final WalletModel wallet;

  const UpdateWallet(this.wallet);

  @override
  List<Object> get props => [wallet];
}

class DeleteWallet extends WalletEvent {
  final String walletId;

  const DeleteWallet(this.walletId);

  @override
  List<Object> get props => [walletId];
}

class RefreshWalletBalances extends WalletEvent {}