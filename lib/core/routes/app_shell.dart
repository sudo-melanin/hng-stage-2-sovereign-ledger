import 'package:flutter/material.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';
import 'package:sovereign_ledger/features/budgets/screens/budgets_screen.dart';
import 'package:sovereign_ledger/features/insights/screens/insights_screen.dart';
import 'package:sovereign_ledger/features/overview/screens/overview_screen.dart';
import 'package:sovereign_ledger/features/settings/screens/settings_screen.dart';
import 'package:sovereign_ledger/features/transactions/screens/add_transaction_screen.dart';
import 'package:sovereign_ledger/core/utils/security_guard.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _isFabOpen = false;

  final List<Widget> _screens = const [
    OverviewScreen(),
    BudgetsScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  Future<void> _onTabSelected(int index) async {
    if (index == 2) {
      final unlocked = await ensureSecurityUnlocked(context);
      if (!unlocked) return;
    }

    setState(() {
      _currentIndex = index;
      _isFabOpen = false;
    });
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
    });
  }

  Future<void> _openAddTransaction(int initialTab) async {
    setState(() => _isFabOpen = false);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialTab: initialTab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_currentIndex]),
      floatingActionButton: _QuickActionFab(
        isOpen: _isFabOpen,
        onToggle: _toggleFab,
        onManual: () => _openAddTransaction(0),
        onCapture: () => _openAddTransaction(1),
        onUpload: () => _openAddTransaction(2),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _QuickActionFab extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onManual;
  final VoidCallback onCapture;
  final VoidCallback onUpload;

  const _QuickActionFab({
    required this.isOpen,
    required this.onToggle,
    required this.onManual,
    required this.onCapture,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) {
      return FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: onToggle,
        child: const Icon(Icons.add),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF94A3B8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniActionButton(
            icon: Icons.edit_note_outlined,
            tooltip: 'Manual',
            onTap: onManual,
          ),
          const SizedBox(width: 8),
          _MiniActionButton(
            icon: Icons.document_scanner_outlined,
            tooltip: 'Capture',
            onTap: onCapture,
          ),
          const SizedBox(width: 8),
          _MiniActionButton(
            icon: Icons.upload_file_outlined,
            tooltip: 'Upload',
            onTap: onUpload,
          ),
          const SizedBox(width: 8),
          _MiniActionButton(
            icon: Icons.close,
            tooltip: 'Close',
            isPrimary: true,
            onTap: onToggle,
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MiniActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 19,
            color: isPrimary ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}