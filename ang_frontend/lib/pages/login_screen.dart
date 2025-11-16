// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   String selectedRole = "Anganwadi Worker";
//   bool _isLoading = false;

//   // CRITICAL: Update this to your Express server's address
//   static const String API_BASE_URL = 'http://10.0.2.2:3000'; 

//   Future<void> _processLoginWithBackend(
//       BuildContext context, GoogleSignInAuthentication auth, GoogleSignInAccount user, String role) async {
    
//     try {
//       if (auth.idToken == null) {
//         throw Exception('No ID Token received from Google');
//       }

//       final userData = {
//         'idToken': auth.idToken,
//         'email': user.email,
//         'name': user.displayName ?? 'Anganwadi User',
//         'selectedRole': role.toLowerCase().replaceAll(' ', '_'), 
//       };

//       final response = await http.post(
//         Uri.parse('$API_BASE_URL/api/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(userData),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         if (responseData['success'] == true) {
//           final confirmedRole = responseData['role'];
          
//           if (context.mounted) {
//             // Navigate based on the role confirmed by the server
//             if (confirmedRole == "admin") {
//               Navigator.pushReplacementNamed(context, '/admin-dashboard');
//             } else {
//               Navigator.pushReplacementNamed(context, '/admin-dashboard');
//             }
//           }
//         } else {
//           throw Exception(responseData['message'] ?? 'Login failed due to server error.');
//         }

//       } else {
//         throw Exception('Server error: HTTP ${response.statusCode}');
//       }

//     } catch (error) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login failed: ${error.toString()}')),
//         );
//       }
//       await GoogleSignIn().signOut();

//     } finally {
//       if(mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _signInWithGoogle(BuildContext context, String role) async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     final GoogleSignIn googleSignIn = GoogleSignIn(
//       // CRITICAL: Replace with your Web Client ID
//      clientId: '1008474113405-s0sfvp4u21vjruah4do3e01vr6cdoioj.apps.googleusercontent.com',
//       scopes: ['email', 'profile'],
//     );

//     try {
//       await googleSignIn.signOut();
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (googleUser == null) return;

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
//       await _processLoginWithBackend(context, googleAuth, googleUser, role);

//     } catch (error) {
//       if(mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Google Sign-In failed: ${error.toString()}')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
//           child: Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 10),
//                 Text(
//                   "Welcome Back",
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   "Select your role to continue",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 roleCard(
//                   icon: Icons.person_outline,
//                   title: "Anganwadi Worker",
//                   subtitle: "Add children, track growth, upload photos",
//                   isSelected: selectedRole == "Anganwadi Worker",
//                   onTap: () {
//                     setState(() { selectedRole = "Anganwadi Worker"; });
//                   },
//                 ),
//                 const SizedBox(height: 15),
//                 roleCard(
//                   icon: Icons.shield_outlined,
//                   title: "Administrator",
//                   subtitle: "Manage Anganwadis, view reports",
//                   isSelected: selectedRole == "Administrator",
//                   onTap: () {
//                     setState(() { selectedRole = "Administrator"; });
//                   },
//                 ),
//                 const Spacer(),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       backgroundColor: Colors.green,
//                     ),
//                     onPressed: _isLoading ? null : () => _signInWithGoogle(context, selectedRole),
//                     icon: _isLoading
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const Icon(Icons.login, color: Colors.white),
//                     label: Text(
//                       _isLoading ? "Signing in..." : "Continue with Google",
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Authentication data saved to MongoDB via Express",
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.grey[500],
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget roleCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Colors.green : Colors.grey.shade300,
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 28, color: isSelected ? Colors.green : Colors.grey),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected ? Colors.green : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

//last dummy login screen code
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; 
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../widgets/app_logo.dart';
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   String selectedRole = "Anganwadi Worker";
//   bool _isLoading = false;
//   bool _isTestMode = true; // Toggle this for test mode

//   // CRITICAL: Update this to your Express server's address
//   // For Android Emulator: use 10.0.2.2
//   // For iOS Simulator: use localhost
//   // For Physical Device: use your computer's IP (e.g., 192.168.1.100)
//   static const String API_BASE_URL = 'http://10.0.2.2:3000'; 

//   // Test user credentials
//   final Map<String, String> testUsers = {
//     'Worker': 'priya.sharma@test.com',
//     'Admin': 'admin.patel@test.com',
//   };

//   Future<void> _processLoginWithBackend(
//       BuildContext context, String email, String name, String role) async {
    
//     try {
//       final userData = {
//         'idToken': null, // null indicates test mode
//         'email': email,
//         'name': name,
//         'selectedRole': role.toLowerCase().replaceAll(' ', '_'), 
//       };

//       final response = await http.post(
//         Uri.parse('$API_BASE_URL/api/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(userData),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         if (responseData['success'] == true) {
//           final confirmedRole = responseData['role'];
//           final userId = responseData['userId'];
//           final anganwadiId = responseData['anganwadiId'];
          
//           if (context.mounted) {
//             // Show success message
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Welcome ${responseData['name']}!'),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             // Navigate based on role
//             if (confirmedRole == "admin") {
//               Navigator.pushReplacementNamed(
//                 context, 
//                 '/admin-dashboard',
//                 arguments: {'userId': userId}
//               );
//             } else {
//               Navigator.pushReplacementNamed(
//                 context, 
//                 '/dashboard',
//                 arguments: {
//                   'userId': userId,
//                   'anganwadiId': anganwadiId
//                 }
//               );
//             }
//           }
//         } else {
//           throw Exception(responseData['message'] ?? 'Login failed due to server error.');
//         }

//       } else {
//         throw Exception('Server error: HTTP ${response.statusCode}');
//       }

//     } catch (error) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Login failed: ${error.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if(mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _handleTestLogin(BuildContext context, String role) async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 800));

//     // Determine test user based on role
//     String email;
//     String name;
    
//     if (role == "Administrator") {
//       email = testUsers['Admin']!;
//       name = 'Admin Patel';
//     } else {
//       email = testUsers['Worker']!;
//       name = 'Priya Sharma';
//     }

//     await _processLoginWithBackend(context, email, name, role);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
//           child: Center(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 10),
                
//                 Text(
//                   "Welcome Back",
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   "Select your role to continue",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
                
//                 // Test Mode Indicator
//                 if (_isTestMode) ...[
//                   const SizedBox(height: 10),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Colors.orange),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.science, size: 16, color: Colors.orange),
//                         const SizedBox(width: 6),
//                         Text(
//                           "TEST MODE",
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.orange[800],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
                
//                 const SizedBox(height: 20),
//                 roleCard(
//                   icon: Icons.person_outline,
//                   title: "Anganwadi Worker",
//                   subtitle: "Add children, track growth, upload photos",
//                   testEmail: _isTestMode ? testUsers['Worker'] : null,
//                   isSelected: selectedRole == "Anganwadi Worker",
//                   onTap: () {
//                     setState(() { selectedRole = "Anganwadi Worker"; });
//                   },
//                 ),
//                 const SizedBox(height: 15),
//                 roleCard(
//                   icon: Icons.shield_outlined,
//                   title: "Administrator",
//                   subtitle: "Manage Anganwadis, view reports",
//                   testEmail: _isTestMode ? testUsers['Admin'] : null,
//                   isSelected: selectedRole == "Administrator",
//                   onTap: () {
//                     setState(() { selectedRole = "Administrator"; });
//                   },
//                 ),
//                 const Spacer(),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       backgroundColor: Colors.green,
//                     ),
//                     onPressed: _isLoading 
//                         ? null 
//                         : () => _handleTestLogin(context, selectedRole),
//                     icon: _isLoading
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : Icon(
//                             _isTestMode ? Icons.bug_report : Icons.login,
//                             color: Colors.white,
//                           ),
//                     label: Text(
//                       _isLoading 
//                           ? "Signing in..." 
//                           : (_isTestMode ? "Test Login" : "Continue with Google"),
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   _isTestMode 
//                       ? "Using test credentials for development"
//                       : "Authentication data saved to MongoDB via Express",
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.grey[500],
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget roleCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     String? testEmail,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Colors.green : Colors.grey.shade300,
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 28, color: isSelected ? Colors.green : Colors.grey),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: isSelected ? Colors.green : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   if (testEmail != null && _isTestMode) ...[
//                     const SizedBox(height: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         testEmail,
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: Colors.orange[800],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = "Anganwadi Worker";
  bool _isLoading = false;
  bool _isTestMode = true; // Toggle this for test mode

  // CRITICAL: Update this to your Express server's address
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use localhost
  // For Physical Device: use your computer's IP (e.g., 192.168.1.100)
  static const String API_BASE_URL = 'http://10.0.2.2:3000'; 

  // Test user credentials
  final Map<String, String> testUsers = {
    'Worker': 'priya.sharma@test.com',
    'Admin': 'admin.patel@test.com',
  };

  Future<void> _processLoginWithBackend(
      BuildContext context, String email, String name, String role) async {
    
    try {
      final userData = {
        'idToken': null, // null indicates test mode
        'email': email,
        'name': name,
        'selectedRole': role.toLowerCase().replaceAll(' ', '_'), 
      };

      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          final confirmedRole = responseData['role'];
          final userId = responseData['userId'];
          final anganwadiId = responseData['anganwadiId'];
          
          if (context.mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome ${responseData['name']}!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate based on role
            if (confirmedRole == "admin") {
              Navigator.pushReplacementNamed(
                context, 
                '/admin-dashboard',
                arguments: {'userId': userId}
              );
            } else {
              Navigator.pushReplacementNamed(
                context, 
                '/dashboard',
                arguments: {
                  'userId': userId,
                  'anganwadiId': anganwadiId
                }
              );
            }
          }
        } else {
          throw Exception(responseData['message'] ?? 'Login failed due to server error.');
        }

      } else {
        throw Exception('Server error: HTTP ${response.statusCode}');
      }

    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleTestLogin(BuildContext context, String role) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Determine test user based on role
    String email;
    String name;
    
    if (role == "Administrator") {
      email = testUsers['Admin']!;
      name = 'Admin Patel';
    } else {
      email = testUsers['Worker']!;
      name = 'Priya Sharma';
    }

    await _processLoginWithBackend(context, email, name, role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // LOGO - Add your logo image here
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // If logo image is not found, show instructions
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[400]!, width: 2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, 
                                size: 40, 
                                color: Colors.grey[600]
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add logo at:\nassets/images/logo.png',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App Name in Hindi
                  Text(
                    'आंगनवाड़ी',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // App Name in English
                  Text(
                    'Anganwadi Care',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Welcome Text
                  Text(
                    "Welcome Back",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select your role to continue",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // Test Mode Indicator
                  if (_isTestMode) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.science, size: 18, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text(
                            "TEST MODE",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Role Cards
                  _roleCard(
                    title: "Anganwadi Worker",
                    subtitle: "Add children, track growth, upload photos",
                    testEmail: _isTestMode ? testUsers['Worker'] : null,
                    isSelected: selectedRole == "Anganwadi Worker",
                    onTap: () {
                      setState(() { selectedRole = "Anganwadi Worker"; });
                    },
                  ),
                  const SizedBox(height: 16),
                  _roleCard(
                    title: "Administrator",
                    subtitle: "Manage Anganwadis, view reports",
                    testEmail: _isTestMode ? testUsers['Admin'] : null,
                    isSelected: selectedRole == "Administrator",
                    onTap: () {
                      setState(() { selectedRole = "Administrator"; });
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _isLoading 
                          ? null 
                          : () => _handleTestLogin(context, selectedRole),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _isTestMode ? "Test Login" : "Continue with Google",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Footer Text
                  Text(
                    _isTestMode 
                        ? "Using test credentials for development"
                        : "Authentication data saved to MongoDB via Express",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Role Card Widget - NO ICONS
  Widget _roleCard({
    required String title,
    required String subtitle,
    String? testEmail,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.08) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.green.shade700 : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            if (testEmail != null && _isTestMode) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 1,
                  ),
                ),
                child: Text(
                  testEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}