import 'package:flutter/material.dart';
import 'package:sovereign_ledger/core/constants/app_colors.dart';

class CaptureTransactionTab extends StatelessWidget {
  const CaptureTransactionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CaptureLikePlaceholder(
      title: 'Capture something',
      subtitle: 'Figure this one out to!!!',
      buttonText: 'Save Up!',
    );
  }
}

class _CaptureLikePlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;

  const _CaptureLikePlaceholder({
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Capture flow is reserved for future upgrade.'),
                  ),
                );
              },
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}