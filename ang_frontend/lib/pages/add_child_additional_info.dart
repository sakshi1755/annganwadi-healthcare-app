import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/custom_app_bar.dart';
class AddChildAdditionalInfo extends StatefulWidget {
  const AddChildAdditionalInfo({super.key});

  @override
  State<AddChildAdditionalInfo> createState() => _AddChildAdditionalInfoState();
}

class _AddChildAdditionalInfoState extends State<AddChildAdditionalInfo> {
  final _guardianController = TextEditingController();
  String selectedGender = 'Female';
  bool isLoading = false;
  
  // API Configuration
  //static const String API_BASE_URL = 'http://10.0.2.2:3000';
  final String API_BASE_URL = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
  // Data from previous screen
  String? childName;
  String? childDob;
  String? village;
  String? userId;
  String? anganwadiId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments from previous screen
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      childName = arguments['name'];
      childDob = arguments['dob'];
      village = arguments['village'];
      userId = arguments['userId'];
      anganwadiId = arguments['anganwadiId'];
    }
  }

  @override
  void dispose() {
    _guardianController.dispose();
    super.dispose();
  }

  Future<void> _createChildProfile() async {
    if (_guardianController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter guardian name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Prepare profile data
      final profileData = {
        'name': childName,
        'dob': childDob,
        'gender': selectedGender.toLowerCase(),
        'guardianName': _guardianController.text.trim(),
        'village': village,
        'anganwadiId': anganwadiId ?? 'AWC001',
        'createdByUserId': userId ?? 'test_user_1',
      };

      print('Creating profile with data: $profileData');

      // Send POST request to backend
      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/profiles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // Success! Navigate back to dashboard
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/dashboard', 
              (route) => false,
              arguments: {
                'userId': userId,
                'anganwadiId': anganwadiId,
              },
            );
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Child profile created successfully for ${responseData['profile']['name']}!'),
                backgroundColor: const Color(0xFF00C896),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create profile');
        }
      } else {
        throw Exception('Server error: HTTP ${response.statusCode}');
      }

    } catch (error) {
      print('Error creating profile: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Child',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00C896),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '2/2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar - Full
          Container(
            width: double.infinity,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF00C896),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F8F5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people,
                              color: Color(0xFF00C896),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Additional Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Complete the profile',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Gender Selection
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedGender = 'Male';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: selectedGender == 'Male' 
                                    ? const Color(0xFF00C896) 
                                    : Colors.white,
                                border: Border.all(
                                  color: selectedGender == 'Male' 
                                      ? const Color(0xFF00C896) 
                                      : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.male,
                                    color: selectedGender == 'Male' 
                                        ? Colors.white 
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Male',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: selectedGender == 'Male' 
                                          ? Colors.white 
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedGender = 'Female';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: selectedGender == 'Female' 
                                    ? const Color(0xFF00C896) 
                                    : Colors.white,
                                border: Border.all(
                                  color: selectedGender == 'Female' 
                                      ? const Color(0xFF00C896) 
                                      : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.female,
                                    color: selectedGender == 'Female' 
                                        ? Colors.white 
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Female',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: selectedGender == 'Female' 
                                          ? Colors.white 
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Guardian's Name Field
                    const Text(
                      "Guardian's Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _guardianController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Enter guardian/parent name',
                        hintStyle: const TextStyle(color: Colors.black38),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00C896)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00C896).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profile Summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00C896),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _summaryRow('Name', childName ?? '-'),
                          const SizedBox(height: 8),
                          _summaryRow('Village', village ?? '-'),
                          const SizedBox(height: 8),
                          _summaryRow('Gender', selectedGender),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Add Child Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _createChildProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Add Child',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}