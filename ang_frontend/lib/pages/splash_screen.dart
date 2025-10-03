import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user is logged in
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final userId = prefs.getString('userId');
      final role = prefs.getString('role');
      final anganwadiId = prefs.getString('anganwadiId');
      
      if (isLoggedIn && userId != null && role != null) {
        // User is logged in, navigate to appropriate dashboard
        if (role == 'admin') {
          Navigator.pushReplacementNamed(
            context, 
            '/admin-dashboard',
            arguments: {'userId': userId},
          );
        } else {
          Navigator.pushReplacementNamed(
            context, 
            '/dashboard',
            arguments: {
              'userId': userId,
              'anganwadiId': anganwadiId,
            },
          );
        }
      } else {
        // User not logged in, show login page
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // On error, navigate to login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C896),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "आंगनवाड़ी स्वास्थ्य",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Anganwadi Health Tracker",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}