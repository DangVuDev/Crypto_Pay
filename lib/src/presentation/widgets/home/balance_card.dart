import 'package:crysta_pay/src/presentation/widgets/wallet/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/wallet_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../common/wallet_card.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final List<WalletModel> wallets;
  final bool isLoading;
  final VoidCallback onViewAll;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.wallets,
    this.isLoading = false,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('total_balance'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey,
                ),
              ),
              Icon(
                Icons.remove_red_eye_outlined,
                size: 20,
                color: theme.textTheme.bodySmall?.color ?? Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(height: 8),
          isLoading
              ? _buildLoadingBalance(theme)
              : Text(
                  '\$${totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.displayLarge?.color ?? Colors.black87,
                  ),
                ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('wallets'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  l10n.translate('view_all'),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: isLoading
                ? _buildLoadingWallets(theme)
                : wallets.isEmpty
                    ? _buildEmptyWallets(context, theme)
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = wallets[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: WalletCard(wallet: wallet),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBalance(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.disabledColor,
      highlightColor: theme.highlightColor,
      child: Container(
        width: 150,
        height: 36,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildLoadingWallets(ThemeData theme) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Shimmer.fromColors(
            baseColor: theme.disabledColor,
            highlightColor: theme.highlightColor,
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWallets(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.translate('no_wallets'),
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              l10n.translate('add_wallet'),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}