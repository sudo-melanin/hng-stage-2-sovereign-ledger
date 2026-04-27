import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';
import 'package:sovereign_ledger/core/constants/app_currencies.dart';
import 'package:sovereign_ledger/core/services/export_service.dart';
import 'package:sovereign_ledger/core/utils/security_guard.dart';
import 'package:sovereign_ledger/providers/settings_provider.dart';
import 'package:sovereign_ledger/providers/transaction_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportCsv(BuildContext context) async {
    final unlocked = await ensureSecurityUnlocked(context);
    if (!unlocked || !context.mounted) return;

    final transactions = context.read<TransactionProvider>().transactions;

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export yet.')),
      );
      return;
    }

    final file = await ExportService().exportTransactionsToCsv(transactions);

    if (!context.mounted) return;

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Sovereign Ledger transaction export',
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export ready.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = context.select<SettingsProvider, AppCurrency>(
      (provider) => provider.currency,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingsHeader(),
          const SizedBox(height: 18),

          _SettingsCard(
            title: 'Currency Formatting',
            subtitle: 'Choose how money values are displayed.',
            child: DropdownButtonFormField<AppCurrency>(
              initialValue: selectedCurrency,
              items: AppCurrencies.supported.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text('${currency.symbol} ${currency.code} — ${currency.name}'),
                );
              }).toList(),
              onChanged: (currency) {
                if (currency == null) return;
                context.read<SettingsProvider>().updateCurrency(currency);
              },
            ),
          ),

          const SizedBox(height: 14),

          _SettingsCard(
            title: 'Data Export',
            subtitle: 'Export your saved transactions as a CSV file.',
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () => _exportCsv(context),
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Export CSV'),
              ),
            ),
          ),

          const SizedBox(height: 14),

          const _SettingsCard(
            title: 'Security',
            subtitle:
                'Dashboard, insights, and export are protected by liveness verification for the current app session.',
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Session-based liveness protection enabled',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryLight,
          child: Icon(
            Icons.settings,
            color: AppColors.primary,
            size: 18,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Settings',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}