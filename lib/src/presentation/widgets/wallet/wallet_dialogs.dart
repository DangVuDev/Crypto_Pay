import 'package:crysta_pay/src/core/di/service_locator.dart';
import 'package:crysta_pay/src/data/models/crypto_type_extension.dart';
import 'package:crysta_pay/src/data/models/wallet_model.dart';
import 'package:crysta_pay/src/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:crysta_pay/src/service/wallet/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Configuration class for consistent styling and constants
class WalletDialogConfig {
  static const Color dialogBackground = Color(0xFF2D2D2D);
  static const Color gradientStart = Color(0xFF2D2D2D);
  static const Color gradientEnd = Color(0xFF1A1A1A);
  static const double borderRadius = 20.0;
  static const double fieldSpacing = 16.0;
  static const String fontFamily = 'Poppins';
  static const Color textColor = Colors.white;
  static const Color disabledTextColor = Color(0xFFB0B0B0);
}

// Shows a dialog to create a new wallet
void showCreateWalletDialog(BuildContext context) {
  final nameController = TextEditingController();
  CryptoType selectedCryptoType = CryptoType.eth;
  bool isLoading = false;

  showGeneralDialog(
    context: context,
    barrierDismissible: !isLoading,
    barrierLabel: 'CreateWalletDialog',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: WalletDialogConfig.dialogBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WalletDialogConfig.borderRadius)),
        title: const Text('Create New Wallet',
            style: TextStyle(
                color: WalletDialogConfig.textColor,
                fontFamily: WalletDialogConfig.fontFamily)),
        content: isLoading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: Colors.blue)),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWalletNameField(nameController, selectedCryptoType),
                  const SizedBox(height: WalletDialogConfig.fieldSpacing),
                  _buildCryptoTypeDropdown(context, selectedCryptoType,
                      (CryptoType? value) {
                    setState(() => selectedCryptoType = value!);
                  }),
                ],
              ),
        actions: isLoading
            ? []
            : [
                _buildCancelButton(context),
                _buildActionButton(
                  context: context,
                  label: 'Create',
                  color: selectedCryptoType.color,
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      _showErrorSnackBar(context, 'Please enter a wallet name');
                      return;
                    }
                    setState(() => isLoading = true);
                    try {
                      final walletService = GetIt.I<WalletService>();
                      final seedPhrase = await walletService.generateSeedPhrase();
                      final walletData = await walletService.createWalletFromSeed(
                          seedPhrase, selectedCryptoType);
                      context.read<WalletBloc>().add(AddWallet(
                            name: nameController.text,
                            address: walletData['address'] as String,
                            type: selectedCryptoType,
                          ));
                      Navigator.pop(context);
                      _showSeedPhraseConfirmation(
                          context, seedPhrase, nameController.text);
                    } catch (e) {
                      setState(() => isLoading = false);
                      _showErrorSnackBar(context, 'Failed to create wallet: $e');
                    }
                  },
                ),
              ],
      ),
    ),
    transitionBuilder: (context, anim1, anim2, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(anim1),
      child: child,
    ),
  );
}

// Shows a dialog to import an existing wallet using a seed phrase
void showImportWalletDialog(BuildContext context) {
  final nameController = TextEditingController();
  final mnemonicController = TextEditingController();
  CryptoType selectedCryptoType = CryptoType.eth;
  bool isLoading = false;

  showGeneralDialog(
    context: context,
    barrierDismissible: !isLoading,
    barrierLabel: 'ImportWalletDialog',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: WalletDialogConfig.dialogBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WalletDialogConfig.borderRadius)),
        title: const Text('Import Wallet',
            style: TextStyle(
                color: WalletDialogConfig.textColor,
                fontFamily: WalletDialogConfig.fontFamily)),
        content: isLoading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: Colors.green)),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWalletNameField(nameController, selectedCryptoType),
                  const SizedBox(height: WalletDialogConfig.fieldSpacing),
                  _buildSeedPhraseField(mnemonicController, selectedCryptoType),
                  const SizedBox(height: WalletDialogConfig.fieldSpacing),
                  _buildCryptoTypeDropdown(context, selectedCryptoType,
                      (CryptoType? value) {
                    setState(() => selectedCryptoType = value!);
                  }),
                ],
              ),
        actions: isLoading
            ? []
            : [
                _buildCancelButton(context),
                _buildActionButton(
                  context: context,
                  label: 'Import',
                  color: Colors.green,
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        mnemonicController.text.isEmpty) {
                      _showErrorSnackBar(
                          context, 'Please enter wallet name and seed phrase');
                      return;
                    }
                    setState(() => isLoading = true);
                    try {
                      final walletService = GetIt.I<WalletService>();
                      if (await walletService
                          .validateSeedPhrase(mnemonicController.text)) {
                        final walletData =
                            await walletService.createWalletFromSeed(
                                mnemonicController.text, selectedCryptoType);
                        context.read<WalletBloc>().add(AddWallet(
                              name: nameController.text,
                              address: walletData['address'] as String,
                              type: selectedCryptoType,
                            ));
                        Navigator.pop(context);
                        _showSeedPhraseConfirmation(context, mnemonicController.text,
                            nameController.text,
                            isImport: true);
                      } else {
                        setState(() => isLoading = false);
                        _showErrorSnackBar(context, 'Invalid seed phrase');
                      }
                    } catch (e) {
                      setState(() => isLoading = false);
                      _showErrorSnackBar(context, 'Failed to import wallet: $e');
                    }
                  },
                ),
              ],
      ),
    ),
    transitionBuilder: (context, anim1, anim2, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(anim1),
      child: child,
    ),
  );
}

// Shows a bottom sheet to connect an external wallet
void showConnectWalletDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [WalletDialogConfig.gradientStart, WalletDialogConfig.gradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WalletDialogConfig.borderRadius)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 16),
            const Text(
              'Connect Wallet',
              style: TextStyle(
                color: WalletDialogConfig.textColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontFamily: WalletDialogConfig.fontFamily,
              ),
            ),
            const SizedBox(height: 24),
            _buildWalletOption(
              context,
              title: 'MetaMask Mobile',
              subtitle: 'Connect using MetaMask Mobile app',
              color: Colors.orange,
              icon: Icons.account_balance_wallet,
              onTap: () => _connectWallet(
                context,
                CryptoType.eth,
                'metamask_mobile',
                params: {}, // Truyền params mặc định
              ),
            ),
            const SizedBox(height: 16),
            _buildWalletOption(
              context,
              title: 'WalletConnect',
              subtitle: 'Connect using any WalletConnect-compatible wallet',
              color: Colors.blue,
              icon: Icons.qr_code,
              onTap: () => _connectWallet(
                context,
                CryptoType.eth,
                'walletconnect',
                params: {},
              ),
            ),
            const SizedBox(height: 16),
            _buildWalletOption(
              context,
              title: 'Trust Wallet',
              subtitle: 'Connect using Trust Wallet app',
              color: Colors.purple,
              icon: Icons.account_balance_wallet,
              onTap: () => _connectWallet(
                context,
                CryptoType.eth,
                'trustwallet',
                params: {},
              ),
            ),
            const SizedBox(height: 16),
            _buildWalletOption(
              context,
              title: 'Phantom',
              subtitle: 'Connect using Phantom wallet for Solana',
              color: Colors.purpleAccent,
              icon: Icons.account_balance_wallet,
              onTap: () => _connectWallet(
                context,
                CryptoType.sol,
                'phantom',
                params: {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
// Shows a dialog to connect a hardware wallet
void showHardwareWalletDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'HardwareWalletDialog',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => AlertDialog(
      backgroundColor: WalletDialogConfig.dialogBackground,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WalletDialogConfig.borderRadius)),
      title: const Text('Connect Hardware Wallet',
          style: TextStyle(
              color: WalletDialogConfig.textColor,
              fontFamily: WalletDialogConfig.fontFamily)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Connect your hardware wallet device',
            style: TextStyle(
                color: WalletDialogConfig.textColor.withOpacity(0.7),
                fontFamily: WalletDialogConfig.fontFamily),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHardwareOption(
                context,
                'Ledger',
                Icons.memory,
                Colors.blue,
                () => _connectWallet(
                  context,
                  CryptoType.eth,
                  'ledger',
                  params: {}, // Truyền params mặc định
                ),
              ),
              _buildHardwareOption(
                context,
                'Trezor',
                Icons.security,
                Colors.green,
                () => _connectWallet(
                  context,
                  CryptoType.eth,
                  'trezor',
                  params: {},
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _buildCancelButton(context),
      ],
    ),
    transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim1),
      child: child,
    ),
  );
}

// Shows a bottom sheet with wallet details
void showWalletDetails(BuildContext context, WalletModel wallet) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [WalletDialogConfig.gradientStart, WalletDialogConfig.gradientEnd]),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(WalletDialogConfig.borderRadius)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 24),
            _buildWalletHeader(wallet),
            const SizedBox(height: 24),
            _buildBalanceCard(wallet),
            const SizedBox(height: 24),
            _buildAddressCard(context, wallet),
            const Spacer(),
            _buildActionButtons(context, wallet),
          ],
        ),
      ),
    ),
  );
}

// Shows a dialog to confirm wallet deletion
void showDeleteWalletDialog(BuildContext context, WalletModel wallet) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'DeleteWalletDialog',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => AlertDialog(
      backgroundColor: WalletDialogConfig.dialogBackground,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WalletDialogConfig.borderRadius)),
      title: const Text('Delete Wallet',
          style: TextStyle(
              color: WalletDialogConfig.textColor,
              fontFamily: WalletDialogConfig.fontFamily)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to delete "${wallet.name}"?',
            style: TextStyle(
                color: WalletDialogConfig.textColor.withOpacity(0.7),
                fontFamily: WalletDialogConfig.fontFamily),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'This action cannot be undone. Ensure you have backed up your seed phrase.',
            style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: WalletDialogConfig.fontFamily),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        _buildCancelButton(context),
        _buildActionButton(
          context: context,
          label: 'Delete',
          color: Colors.red,
          onPressed: () {
            context.read<WalletBloc>().add(DeleteWallet(wallet.id));
            Navigator.pop(context);
          },
        ),
      ],
    ),
    transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim1),
      child: child,
    ),
  );
}

// Helper method to show seed phrase confirmation
void _showSeedPhraseConfirmation(BuildContext context, String seedPhrase,
    String walletName, {bool isImport = false}) {
  bool hasCopied = false;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'SeedPhraseConfirmation',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: WalletDialogConfig.dialogBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WalletDialogConfig.borderRadius)),
        title: Text(
          isImport ? 'Imported Wallet' : 'New Wallet Created',
          style: const TextStyle(
              color: WalletDialogConfig.textColor,
              fontFamily: WalletDialogConfig.fontFamily),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet "$walletName" has been ${isImport ? 'imported' : 'created'}. '
              'Back it up securely!',
              style: TextStyle(
                  color: WalletDialogConfig.textColor.withOpacity(0.7),
                  fontFamily: WalletDialogConfig.fontFamily),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                seedPhrase,
                style: const TextStyle(
                  color: WalletDialogConfig.textColor,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  hasCopied ? Icons.check_circle : Icons.copy,
                  color: hasCopied
                      ? Colors.green
                      : WalletDialogConfig.textColor.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: seedPhrase));
                    setState(() => hasCopied = true);
                    _showSnackBar(context, 'Seed phrase copied');
                  },
                  child: Text(
                    hasCopied ? 'Copied' : 'Copy Seed Phrase',
                    style: TextStyle(
                        color: WalletDialogConfig.textColor.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: WalletDialogConfig.fontFamily),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Warning: Do not share this seed phrase. Anyone with it can access your funds.',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: WalletDialogConfig.fontFamily),
            ),
          ],
        ),
        actions: [
          _buildActionButton(
            context: context,
            label: 'Done',
            color: Colors.blue,
            onPressed: hasCopied ? () => Navigator.pop(context) : null,
          ),
        ],
      ),
    ),
    transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim1),
      child: child,
    ),
  );
}

// Helper method to show edit wallet dialog
void _showEditWalletDialog(BuildContext context, WalletModel wallet) {
  final nameController = TextEditingController(text: wallet.name);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'EditWalletDialog',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => AlertDialog(
      backgroundColor: WalletDialogConfig.dialogBackground,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WalletDialogConfig.borderRadius)),
      title: const Text('Edit Wallet',
          style: TextStyle(
              color: WalletDialogConfig.textColor,
              fontFamily: WalletDialogConfig.fontFamily)),
      content: _buildWalletNameField(nameController, wallet.type),
      actions: [
        _buildCancelButton(context),
        _buildActionButton(
          context: context,
          label: 'Save',
          color: Colors.blue,
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              context.read<WalletBloc>().add(
                  UpdateWallet(wallet.copyWith(name: nameController.text)));
              Navigator.pop(context);
            } else {
              _showErrorSnackBar(context, 'Please enter a wallet name');
            }
          },
        ),
      ],
    ),
    transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim1),
      child: child,
    ),
  );
}

// Initiates wallet connection and displays QR code or deep link dialog
// Initiates wallet connection and displays QR code or deep link dialog
Future<void> _connectWallet(
  BuildContext context,
  CryptoType cryptoType,
  String walletType, {
  Map<String, dynamic> params = const {}, // Thêm params
}) async {
  try {
    final walletService = GetIt.I<WalletService>();
    bool isConnecting = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ConnectWalletDialog',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          backgroundColor: WalletDialogConfig.dialogBackground,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WalletDialogConfig.borderRadius)),
          title: Text(
            'Connect $walletType',
            style: const TextStyle(
              color: WalletDialogConfig.textColor,
              fontWeight: FontWeight.w600,
              fontFamily: WalletDialogConfig.fontFamily,
            ),
          ),
          content: isConnecting
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator(color: Colors.blue)),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (walletService.lastUri != null)
                      QrImageView(
                        data: walletService.lastUri!,
                        size: 200,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan with $walletType or open app',
                      style: TextStyle(
                        color: WalletDialogConfig.textColor.withOpacity(0.7),
                        fontFamily: WalletDialogConfig.fontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
          actions: [
            _buildCancelButton(dialogContext),
          ],
        ),
      ),
      transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim1),
        child: child,
      ),
    );

    // Gọi connectExternalWallet với params
    final result = await walletService.connectExternalWallet(
      cryptoType,
      walletType,
      params
    );
    isConnecting = false;

    Navigator.pop(context); // Close QR dialog

    if (result['success'] == true && result['address'] != null) {
      context.read<WalletBloc>().add(AddWallet(
            name: '$walletType Wallet',
            address: result['address'] as String,
            type: cryptoType,
          ));
      Navigator.pop(context); // Close bottom sheet
      _showSnackBar(context, 'Connected $walletType successfully');
    } else {
      _showErrorSnackBar(
          context, result['error'] ?? 'Failed to connect $walletType');
    }
  } catch (e) {
    Navigator.pop(context); // Close QR dialog
    _showErrorSnackBar(context, 'Error: $e');
  }
}


// Reusable widget for wallet name input field
Widget _buildWalletNameField(
    TextEditingController controller, CryptoType cryptoType) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(
        color: WalletDialogConfig.textColor,
        fontFamily: WalletDialogConfig.fontFamily),
    decoration: InputDecoration(
      labelText: 'Wallet Name',
      labelStyle: TextStyle(
          color: WalletDialogConfig.textColor.withOpacity(0.7),
          fontFamily: WalletDialogConfig.fontFamily),
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: WalletDialogConfig.textColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: cryptoType.color),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    validator: (value) =>
        value!.isEmpty ? 'Please enter a wallet name' : null,
  );
}

// Reusable widget for seed phrase input field
Widget _buildSeedPhraseField(
    TextEditingController controller, CryptoType cryptoType) {
  return TextFormField(
    controller: controller,
    style: const TextStyle(
        color: WalletDialogConfig.textColor,
        fontFamily: WalletDialogConfig.fontFamily),
    maxLines: 3,
    decoration: InputDecoration(
      labelText: 'Seed Phrase (12 or 24 words)',
      labelStyle: TextStyle(
          color: WalletDialogConfig.textColor.withOpacity(0.7),
          fontFamily: WalletDialogConfig.fontFamily),
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: WalletDialogConfig.textColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: cryptoType.color),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    validator: (value) =>
        value!.isEmpty ? 'Please enter a seed phrase' : null,
  );
}

// Reusable widget for crypto type dropdown
Widget _buildCryptoTypeDropdown(BuildContext context, CryptoType selectedType,
    ValueChanged<CryptoType?> onChanged) {
  return DropdownButtonFormField<CryptoType>(
    value: selectedType,
    dropdownColor: WalletDialogConfig.dialogBackground,
    style: const TextStyle(
        color: WalletDialogConfig.textColor,
        fontFamily: WalletDialogConfig.fontFamily),
    decoration: InputDecoration(
      labelText: 'Blockchain',
      labelStyle: TextStyle(
          color: WalletDialogConfig.textColor.withOpacity(0.7),
          fontFamily: WalletDialogConfig.fontFamily),
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: WalletDialogConfig.textColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: selectedType.color),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    items: CryptoType.values.map((type) {
      return DropdownMenuItem<CryptoType>(
        value: type,
        child: Row(
          children: [
            Icon(type.icon, color: type.color, size: 20),
            const SizedBox(width: 8),
            Text(type.displayName),
          ],
        ),
      );
    }).toList(),
    onChanged: onChanged,
  );
}

// Reusable widget for wallet option
Widget _buildWalletOption(
  BuildContext context, {
  required String title,
  required String subtitle,
  required Color color,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: WalletDialogConfig.textColor,
        fontWeight: FontWeight.w500,
        fontFamily: WalletDialogConfig.fontFamily,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(
        color: WalletDialogConfig.textColor.withOpacity(0.7),
        fontFamily: WalletDialogConfig.fontFamily,
      ),
    ),
    onTap: onTap,
    tileColor: WalletDialogConfig.textColor.withOpacity(0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

// Reusable widget for hardware wallet option
Widget _buildHardwareOption(
  BuildContext context,
  String name,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(name,
              style: const TextStyle(
                  color: WalletDialogConfig.textColor,
                  fontFamily: WalletDialogConfig.fontFamily)),
        ],
      ),
    ),
  );
}

// Reusable widget for drag handle
Widget _buildDragHandle() {
  return Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: WalletDialogConfig.textColor.withOpacity(0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

// Reusable widget for wallet header
Widget _buildWalletHeader(WalletModel wallet) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              wallet.type.color.withOpacity(0.8),
              wallet.type.color.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(wallet.type.icon, color: WalletDialogConfig.textColor, size: 24),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wallet.name,
              style: const TextStyle(
                color: WalletDialogConfig.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: WalletDialogConfig.fontFamily,
              ),
            ),
            Text(
              wallet.type.displayName,
              style: TextStyle(
                  color: WalletDialogConfig.textColor.withOpacity(0.7),
                  fontSize: 14,
                  fontFamily: WalletDialogConfig.fontFamily),
            ),
          ],
        ),
      ),
      if (wallet.status == WalletStatus.active)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: const Text(
            'Connected',
            style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontFamily: WalletDialogConfig.fontFamily),
          ),
        ),
    ],
  );
}

// Reusable widget for balance card
Widget _buildBalanceCard(WalletModel wallet) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          WalletDialogConfig.textColor.withOpacity(0.1),
          WalletDialogConfig.textColor.withOpacity(0.05)
        ],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balance',
          style: TextStyle(
              color: WalletDialogConfig.textColor.withOpacity(0.7),
              fontSize: 14,
              fontFamily: WalletDialogConfig.fontFamily),
        ),
        const SizedBox(height: 8),
        Text(
          '${wallet.balance.toStringAsFixed(4)} ${wallet.type.symbol}',
          style: const TextStyle(
            color: WalletDialogConfig.textColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: WalletDialogConfig.fontFamily,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${wallet.usdValue.toStringAsFixed(2)}',
          style: TextStyle(
              color: WalletDialogConfig.textColor.withOpacity(0.7),
              fontSize: 16,
              fontFamily: WalletDialogConfig.fontFamily),
        ),
      ],
    ),
  );
}

// Reusable widget for address card
Widget _buildAddressCard(BuildContext context, WalletModel wallet) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Address',
        style: TextStyle(
            color: WalletDialogConfig.textColor.withOpacity(0.7),
            fontSize: 14,
            fontFamily: WalletDialogConfig.fontFamily),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WalletDialogConfig.textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${wallet.address.substring(0, 6)}...${wallet.address.substring(wallet.address.length - 4)}',
                style: const TextStyle(
                  color: WalletDialogConfig.textColor,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy,
                  color: WalletDialogConfig.textColor.withOpacity(0.7)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: wallet.address));
                _showSnackBar(context, 'Address copied to clipboard');
              },
            ),
          ],
        ),
      ),
    ],
  );
}

// Reusable widget for action buttons in wallet details
Widget _buildActionButtons(BuildContext context, WalletModel wallet) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.pop(context);
            _showEditWalletDialog(context, wallet);
          },
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.pop(context);
            showDeleteWalletDialog(context, wallet);
          },
        ),
      ),
    ],
  );
}

// Reusable cancel button
Widget _buildCancelButton(BuildContext context) {
  return TextButton(
    onPressed: () => Navigator.pop(context),
    child: Text(
      'Cancel',
      style: TextStyle(
          color: WalletDialogConfig.textColor.withOpacity(0.7),
          fontFamily: WalletDialogConfig.fontFamily),
    ),
  );
}

// Reusable action button
Widget _buildActionButton({
  required BuildContext context,
  required String label,
  required Color color,
  required VoidCallback? onPressed,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: onPressed,
    child: Text(
      label,
      style: const TextStyle(
          color: WalletDialogConfig.textColor,
          fontFamily: WalletDialogConfig.fontFamily),
    ),
  );
}

// Helper method to show snackbar
void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message,
          style: const TextStyle(fontFamily: WalletDialogConfig.fontFamily)),
      backgroundColor: Colors.green,
    ),
  );
}

// Helper method to show error snackbar
void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message,
          style: const TextStyle(fontFamily: WalletDialogConfig.fontFamily)),
      backgroundColor: Colors.red,
    ),
  );
}