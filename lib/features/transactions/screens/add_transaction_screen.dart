import 'package:flutter/material.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';
import 'package:sovereign_ledger/features/transactions/widgets/capture_transaction_tab.dart';
import 'package:sovereign_ledger/features/transactions/widgets/manual_transaction_tab.dart';
import 'package:sovereign_ledger/features/transactions/widgets/upload_transaction_tab.dart';

class AddTransactionScreen extends StatefulWidget {
  final int initialTab;

  const AddTransactionScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _title {
    switch (_tabController.index) {
      case 1:
        return 'Capture Transaction';
      case 2:
        return 'Upload Data';
      default:
        return 'Add Transaction';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(_title),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.mutedText,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const [
                      Tab(text: 'Manual'),
                      Tab(text: 'Capture'),
                      Tab(text: 'Upload Data'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    ManualTransactionTab(),
                    CaptureTransactionTab(),
                    UploadTransactionTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}