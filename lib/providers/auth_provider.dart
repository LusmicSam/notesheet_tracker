import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as AppUser;
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser.User? _user;
  bool _isLoading = false;
  String? _error;

  AppUser.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Get current user if already signed in
    _user = AuthService.getCurrentUser();

    // Listen to auth state changes
    AuthService.authStateStream.listen((AuthState state) {
      if (state.event == AuthChangeEvent.signedIn) {
        _user = AuthService.getCurrentUser();
        _error = null;
        notifyListeners();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _user = null;
        _error = null;
        notifyListeners();
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'user',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.signIn(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.signOut();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.resetPassword(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
