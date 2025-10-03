// lib/services/auth_service.dart - REPLACE THE ENTIRE FILE
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Commented out for dummy login
import 'api_service.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Commented out Google Sign-In for dummy login
  // static final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ['email', 'profile'],
  // );

  // Check if user is logged in
  static bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  // DUMMY SIGN IN - This won't be used, but keeping for compatibility
  static Future<Map<String, dynamic>?> signInWithGoogle(String role) async {
    // This method is not used in dummy login mode
    // The AuthProvider handles dummy authentication directly
    debugPrint('AuthService.signInWithGoogle called but not implemented in dummy mode');
    return null;
  }

  // Real Google Sign-In method (commented out for now)
  /*
  static Future<Map<String, dynamic>?> signInWithGoogle(String role) async {
    try {
      // Sign out from Google first to force account selection
      await _googleSignIn.disconnect();
      
      // Sign in with Google using the correct method for v7.x
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google sign-in was cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Check if we have the required token
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      debugPrint('Google sign-in successful, attempting Supabase auth...');

      // Sign in with Supabase using Google credentials
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      if (response.user != null) {
        debugPrint('Supabase auth successful, registering with backend...');
        
        // Register/login user in your backend
        final backendResponse = await ApiService.login(
          supabaseUserId: response.user!.id,
          email: response.user!.email ?? googleUser.email,
          name: response.user!.userMetadata?['full_name'] ?? googleUser.displayName ?? 'Unknown User',
          role: role,
        );

        debugPrint('Backend registration successful');

        return {
          'user': response.user,
          'backendUser': backendResponse['user'],
        };
      } else {
        throw Exception('Supabase authentication failed');
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      throw Exception('Google sign-in failed: $e');
    }
  }
  */

  // Sign out
  static Future<void> signOut() async {
    try {
      // Only sign out from Supabase for now
      await _supabase.auth.signOut();
      
      // Uncomment when using real Google Sign-In:
      // await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}