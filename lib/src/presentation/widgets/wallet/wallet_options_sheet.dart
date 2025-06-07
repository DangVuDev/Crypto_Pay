import 'package:flutter/material.dart';
import 'wallet_dialogs.dart';

void showWalletOptionsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Wallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildOptionButton(
              icon: Icons.add_circle_outline,
              title: 'Create New Wallet',
              subtitle: 'Generate a new wallet with seed phrase',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                showCreateWalletDialog(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOptionButton(
              icon: Icons.download_outlined,
              title: 'Import Wallet',
              subtitle: 'Import existing wallet with seed phrase',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                showImportWalletDialog(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOptionButton(
              icon: Icons.link,
              title: 'Connect Wallet',
              subtitle: 'Connect MetaMask, WalletConnect, etc.',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                showConnectWalletDialog(context);
              },
            ),
            const SizedBox(height: 16),
            _buildOptionButton(
              icon: Icons.security,
              title: 'Hardware Wallet',
              subtitle: 'Connect Ledger or Trezor device',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                showHardwareWalletDialog(context);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

Widget _buildOptionButton({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    ),
  );
}