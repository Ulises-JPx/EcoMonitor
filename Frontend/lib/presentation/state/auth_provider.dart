import 'package:flutter/material.dart';

/// AuthProvider
/// -------------
/// Simple mock authentication state.
/// Later, you can connect it to a real backend.
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login(String email, String password) {
    // For now, accept any credentials
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}