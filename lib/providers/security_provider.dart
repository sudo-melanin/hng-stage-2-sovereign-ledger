import 'package:flutter/foundation.dart';

/// Holds the current in-app security session state.
/// Unlock is intentionally session-only and resets when the app restarts.
class SecurityProvider extends ChangeNotifier {
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  void unlockSession() {
    _isUnlocked = true;
    notifyListeners();
  }

  void lockSession() {
    _isUnlocked = false;
    notifyListeners();
  }
}