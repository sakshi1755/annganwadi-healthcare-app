import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/login_screen.dart';
// import 'pages/second_page.dart'; // Example — replace or add more pages here

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // Set up routes
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        //'/second': (context) => const SecondPage(), // Example route
        '/login': (context) => const LoginScreen(),

      },
    );
  }
}
