// lib/main.dart
import 'package:flutter/material.dart';


import 'pages/splash_screen.dart';
import 'pages/landing_page.dart';
import 'pages/login_screen.dart';
import 'pages/dashboard.dart';
import 'pages/add_child_basic_info.dart';
import 'pages/add_child_additional_info.dart';
import 'pages/child_profile.dart';
import 'pages/view_profiles.dart';
 import 'pages/admin_dashboard.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  
      return MaterialApp(
        title: 'Anganwadi Healthcare App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C896)),
          useMaterial3: true,
          primaryColor: const Color(0xFF00C896),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        
        // Set up routes
        initialRoute: '/landing',
        routes: {
          '/': (context) => const SplashScreen(),
          '/landing': (context) => const LandingPage(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const Dashboard(),
          '/add-child-basic': (context) => const AddChildBasicInfo(),
          '/add-child-additional': (context) => const AddChildAdditionalInfo(),
          '/child-profile': (context) => const ChildProfile(),
          '/view-profiles': (context) => const ViewProfiles(),
          '/admin-dashboard': (context) => const AdminDashboard(),
        },
      );
    
  }
}