// lib/providers/auth_provider.dart - REPLACE THE ENTIRE FILE
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null || _userProfile != null; // Modified for dummy login

  // Initialize auth state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = AuthService.currentUser;
      if (_user != null) {
        // Get user profile from backend
        _userProfile = await ApiService.getCurrentUser();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // DUMMY SIGN IN - Replace this with real Google sign-in later
  Future<bool> signInWithGoogle(String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Create dummy user profile
      _userProfile = {
        'id': 'dummy_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'dummy@example.com',
        'name': role == 'Administrator' ? 'Admin User' : 'Anganwadi Worker',
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
        'supabase_user_id': 'dummy_supabase_id',
      };

      // Create a minimal dummy user object for compatibility
      _user = null; // We'll keep this null since we can't create a real Supabase User
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('Error in dummy sign in: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Real Google sign-in method (commented out for now)
  /*
  Future<bool> signInWithGoogle(String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.signInWithGoogle(role);
      if (result != null) {
        _user = result['user'];
        _userProfile = result['backendUser'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
  */

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For dummy login, just clear the profile
      _user = null;
      _userProfile = null;
      
      // Uncomment when using real auth:
      // await AuthService.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update user profile
  void updateUserProfile(Map<String, dynamic> profile) {
    _userProfile = profile;
    notifyListeners();
  }
}