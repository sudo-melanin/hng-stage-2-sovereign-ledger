import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sovereign_ledger/features/security/screens/liveness_verification_screen.dart';
import 'package:sovereign_ledger/providers/security_provider.dart';

/// Requests liveness verification once per app session.
/// Returns true when access is already unlocked or verification succeeds.
Future<bool> ensureSecurityUnlocked(BuildContext context) async {
  final securityProvider = context.read<SecurityProvider>();

  if (securityProvider.isUnlocked) return true;

  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const LivenessVerificationScreen(),
    ),
  );

  if (result == true) {
    securityProvider.unlockSession();
    return true;
  }

  return false;
}