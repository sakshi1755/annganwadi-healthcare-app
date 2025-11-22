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
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  //static const String API_BASE_URL = 'http://10.0.2.2:3000'; 
final String API_BASE_URL = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/landing');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Welcome Back",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Select your role to continue",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                // Test Mode Indicator
                if (_isTestMode) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.science, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          "TEST MODE",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                roleCard(
                  icon: Icons.person_outline,
                  title: "Anganwadi Worker",
                  subtitle: "Add children, track growth, upload photos",
                  testEmail: _isTestMode ? testUsers['Worker'] : null,
                  isSelected: selectedRole == "Anganwadi Worker",
                  onTap: () {
                    setState(() { selectedRole = "Anganwadi Worker"; });
                  },
                ),
                const SizedBox(height: 15),
                roleCard(
                  icon: Icons.shield_outlined,
                  title: "Administrator",
                  subtitle: "Manage Anganwadis, view reports",
                  testEmail: _isTestMode ? testUsers['Admin'] : null,
                  isSelected: selectedRole == "Administrator",
                  onTap: () {
                    setState(() { selectedRole = "Administrator"; });
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _isLoading 
                        ? null 
                        : () => _handleTestLogin(context, selectedRole),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _isTestMode ? Icons.bug_report : Icons.login,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isLoading 
                          ? "Signing in..." 
                          : (_isTestMode ? "Test Login" : "Continue with Google"),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isTestMode 
                      ? "Using test credentials for development"
                      : "Authentication data saved to MongoDB via Express",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget roleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? testEmail,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: isSelected ? Colors.green : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.green : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (testEmail != null && _isTestMode) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
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
            )
          ],
        ),
      ),
    );
  }
}