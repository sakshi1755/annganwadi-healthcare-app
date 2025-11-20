import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_app_bar.dart';

class ChildProfile extends StatefulWidget {
  const ChildProfile({super.key});

  @override
  State<ChildProfile> createState() => _ChildProfileState();
}

class _ChildProfileState extends State<ChildProfile> {
  static const String API_BASE_URL = 'http://10.0.2.2:3000';
  
  Map<String, dynamic>? childData;
  bool isLoading = true;
  bool isUploading = false;
  String? profileId;
  String? userId;
  String? anganwadiId;
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      profileId = args['profileId'];
      userId = args['userId'];
      anganwadiId = args['anganwadiId'];
    }
  }

  Future<void> _loadChildProfile() async {
    if (profileId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/api/profiles/$profileId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            childData = data['profile'];
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _calculateAge() {
    if (childData == null || childData!['dob'] == null) return 'Unknown';
    try {
      final dob = DateTime.parse(childData!['dob']);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return '$age years old';
    } catch (e) {
      return 'Unknown';
    }
  }

  int _calculateAgeInMonths() {
    if (childData == null || childData!['dob'] == null) return 0;
    try {
      final dob = DateTime.parse(childData!['dob']);
      final now = DateTime.now();
      int months = (now.year - dob.year) * 12 + (now.month - dob.month);
      if (now.day < dob.day) {
        months--;
      }
      return months;
    } catch (e) {
      return 0;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getLastUpdated() {
    if (childData == null) return 'Unknown';
    
    final photos = childData!['photos'] as List?;
    if (photos != null && photos.isNotEmpty) {
      try {
        final lastPhoto = photos.last;
        final uploadDate = DateTime.parse(lastPhoto['uploadedAt']);
        final now = DateTime.now();
        final difference = now.difference(uploadDate);
        
        if (difference.inDays == 0) {
          if (difference.inHours == 0) {
            return '${difference.inMinutes} minutes ago';
          }
          return '${difference.inHours} hours ago';
        } else if (difference.inDays == 1) {
          return 'Yesterday';
        } else {
          return DateFormat('dd MMM yyyy').format(uploadDate);
        }
      } catch (e) {
        return 'Unknown';
      }
    }
    return 'No updates yet';
  }

  int _getAIPrediction() {
    if (childData == null) return 0;
    
    final photos = childData!['photos'] as List?;
    if (photos != null && photos.isNotEmpty) {
      final lastPhoto = photos.last;
      final confidence = lastPhoto['predictionConfidence'];
      if (confidence != null) {
        return (confidence * 100).round();
      }
    }
    return 0;
  }

  Map<String, dynamic>? _calculateAccuracy() {
    if (childData == null) return null;
    
    final predictedHeight = childData!['predictedHeight'];
    final actualHeight = childData!['actualHeight'];
    final predictedWeight = childData!['predictedWeight'];
    final actualWeight = childData!['actualWeight'];

    if (predictedHeight == null || actualHeight == null || 
        predictedWeight == null || actualWeight == null) {
      return null;
    }

    // Height accuracy
    final heightError = (predictedHeight - actualHeight).abs();
    final heightErrorPercent = (heightError / actualHeight) * 100;
    final heightAccuracy = 100 - heightErrorPercent;

    // Weight accuracy
    final weightError = (predictedWeight - actualWeight).abs();
    final weightErrorPercent = (weightError / actualWeight) * 100;
    final weightAccuracy = 100 - weightErrorPercent;

    return {
      'heightError': heightError,
      'heightErrorPercent': heightErrorPercent,
      'heightAccuracy': heightAccuracy,
      'weightError': weightError,
      'weightErrorPercent': weightErrorPercent,
      'weightAccuracy': weightAccuracy,
    };
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 95) return Colors.green;
    if (accuracy >= 85) return Colors.orange;
    return Colors.red;
  }

  Future<void> _handleImageUpload(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    
    try {
      final ImagePicker picker = ImagePicker();
      
      if (source == ImageSource.camera) {
        // Take photo with camera
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        
        if (image != null) {
          setState(() {
            _selectedImages.add(image);
          });
          
          // Check if we have 4 images
          if (_selectedImages.length == 4) {
            // Automatically proceed with prediction using profile data
            await _uploadImagesAndPredictAuto();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_selectedImages.length}/4 images captured. Take ${4 - _selectedImages.length} more.'),
                  backgroundColor: Colors.blue,
                  action: SnackBarAction(
                    label: 'Continue',
                    textColor: Colors.white,
                    onPressed: () {
                      _handleImageUpload(ImageSource.camera);
                    },
                  ),
                ),
              );
            }
          }
        }
      } else {
        // Pick multiple from gallery
        final List<XFile> images = await picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        
        if (images.isNotEmpty) {
          if (images.length != 4) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select exactly 4 images'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          
          setState(() {
            _selectedImages = images;
          });
          
          // Automatically proceed with prediction using profile data
          await _uploadImagesAndPredictAuto();
        }
      }
    } catch (e) {
      print('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // NEW METHOD: Automatically extracts DOB and gender from profile
  Future<void> _uploadImagesAndPredictAuto() async {
    // Validate profile data
    if (childData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile data not loaded'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _selectedImages.clear();
      });
      return;
    }

    final dob = childData!['dob'];
    final gender = childData!['gender'];

    if (dob == null || gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile missing DOB or gender information'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _selectedImages.clear();
      });
      return;
    }

    // Calculate age in months from DOB
    final ageInMonths = _calculateAgeInMonths();

    if (ageInMonths <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid date of birth'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _selectedImages.clear();
      });
      return;
    }

    // Show confirmation dialog with auto-extracted data
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF00C896)),
            SizedBox(width: 8),
            Text('Confirm Prediction'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Using profile information:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cake, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Age: $ageInMonths months',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        gender.toLowerCase() == 'male' ? Icons.boy : Icons.girl,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Gender: ${gender[0].toUpperCase()}${gender.substring(1)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.photo_library, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Images: ${_selectedImages.length}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Proceed with height prediction?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _uploadImagesAndPredict(ageInMonths.toDouble(), gender.toLowerCase());
    } else {
      setState(() {
        _selectedImages.clear();
      });
    }
  }

  Future<void> _uploadImagesAndPredict(double ageInMonths, String gender) async {
    setState(() {
      isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$API_BASE_URL/api/height/predict'),
      );

      // Add profileId, age, and gender
      request.fields['profileId'] = profileId!;
      request.fields['ageInMonths'] = ageInMonths.toString();
      request.fields['gender'] = gender;

      // Add all 4 images
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        final bytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: 'image_$i.jpg',
          ),
        );
      }

      print('Sending ${_selectedImages.length} images to ML model...');
      print('Age: $ageInMonths months, Gender: $gender');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final predictedHeight = data['predictedHeight'];
          
          // Clear selected images
          setState(() {
            _selectedImages.clear();
          });
          
          // Reload profile to get updated height
          await _loadChildProfile();
          
          if (mounted) {
            // Show success dialog with predicted height
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF00C896)),
                    SizedBox(width: 8),
                    Text('Height Predicted!'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predicted Height:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${predictedHeight.toStringAsFixed(1)} cm',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C896),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Based on:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Age: ${ageInMonths.round()} months',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '• Gender: ${gender[0].toUpperCase()}${gender.substring(1)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Prediction failed');
      }
    } catch (e) {
      print('Error uploading images: $e');
      setState(() {
        _selectedImages.clear();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _predictWeight() async {
    if (childData!['predictedHeight'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please predict height first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Calculate age in months from DOB
      final ageInMonths = _calculateAgeInMonths().toDouble();

      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/height/predict-weight'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'profileId': profileId,
          'heightCm': childData!['predictedHeight'],
          'ageInMonths': ageInMonths,
          'gender': childData!['gender'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _loadChildProfile();
          
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Weight Predicted!'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight: ${(data['predictedWeight'] / 1000).toStringAsFixed(2)} kg',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BMI: ${data['bmi'].toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        throw Exception('Weight prediction failed');
      }
    } catch (e) {
      print('Error predicting weight: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _showActualMeasurementsDialog() async {
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    
    // Pre-fill if actual measurements already exist
    if (childData!['actualHeight'] != null) {
      heightController.text = childData!['actualHeight'].toString();
    }
    if (childData!['actualWeight'] != null) {
      weightController.text = (childData!['actualWeight'] / 1000).toStringAsFixed(2);
    }
    
    final predictedHeight = childData!['predictedHeight'];
    final predictedWeight = childData!['predictedWeight'];
    
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Record Actual Measurements'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the child\'s actual measured values:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                
                // Predicted Height (for reference)
                if (predictedHeight != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Predicted Height: ${predictedHeight.toStringAsFixed(1)} cm',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Actual Height Input
                TextField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Actual Height (cm)',
                    border: const OutlineInputBorder(),
                    hintText: 'e.g., 105.5',
                    prefixIcon: const Icon(Icons.height),
                    helperText: 'Leave empty if not measured',
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Predicted Weight (for reference)
                if (predictedWeight != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Predicted Weight: ${(predictedWeight / 1000).toStringAsFixed(2)} kg',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Actual Weight Input
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Actual Weight (kg)',
                    border: const OutlineInputBorder(),
                    hintText: 'e.g., 15.5',
                    prefixIcon: const Icon(Icons.monitor_weight),
                    helperText: 'Leave empty if not measured',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final heightText = heightController.text.trim();
                final weightText = weightController.text.trim();
                
                // Check if at least one field has value
                if (heightText.isEmpty && weightText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter at least one measurement'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                double? height;
                double? weight;
                
                // Validate height if provided
                if (heightText.isNotEmpty) {
                  height = double.tryParse(heightText);
                  if (height == null || height <= 0 || height > 250) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid height (1-250 cm)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                
                // Validate weight if provided
                if (weightText.isNotEmpty) {
                  weight = double.tryParse(weightText);
                  if (weight == null || weight <= 0 || weight > 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid weight (0.1-200 kg)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                
                Navigator.pop(context, {
                  if (height != null) 'height': height,
                  if (weight != null) 'weight': weight,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C896),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    
    if (result != null) {
      await _saveActualMeasurements(result);
    }
  }

  Future<void> _saveActualMeasurements(Map<String, double> measurements) async {
    setState(() {
      isUploading = true;
    });

    try {
      bool heightSaved = false;
      bool weightSaved = false;
      String errorMessage = '';

      // Save actual height if provided
      if (measurements.containsKey('height')) {
        try {
          final heightResponse = await http.post(
            Uri.parse('$API_BASE_URL/api/profiles/$profileId/actualHeight'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'actualHeight': measurements['height']}),
          );

          if (heightResponse.statusCode == 200) {
            heightSaved = true;
          } else {
            errorMessage += 'Height save failed. ';
          }
        } catch (e) {
          errorMessage += 'Height error: ${e.toString()}. ';
        }
      }

      // Save actual weight if provided (convert kg to grams)
      if (measurements.containsKey('weight')) {
        try {
          final weightResponse = await http.post(
            Uri.parse('$API_BASE_URL/api/profiles/$profileId/actualWeight'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'actualWeight': measurements['weight']! * 1000}),
          );

          if (weightResponse.statusCode == 200) {
            weightSaved = true;
          } else {
            errorMessage += 'Weight save failed.';
          }
        } catch (e) {
          errorMessage += 'Weight error: ${e.toString()}.';
        }
      }

      // Reload profile to get updated data
      await _loadChildProfile();
      
      if (mounted) {
        if (heightSaved || weightSaved) {
          String successMsg = 'Saved: ';
          if (heightSaved) successMsg += 'Height ';
          if (weightSaved) successMsg += 'Weight';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMsg + (errorMessage.isNotEmpty ? '\n$errorMessage' : '')),
              backgroundColor: errorMessage.isEmpty ? const Color(0xFF00C896) : Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save measurements: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving actual measurements: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> _updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$API_BASE_URL/api/profiles/$profileId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _loadChildProfile();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Color(0xFF00C896),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          title: const Text(
            'Child Profile',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00C896),
          ),
        ),
      );
    }

    if (childData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          title: const Text(
            'Child Profile',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Profile not found'),
        ),
      );
    }

    final gender = childData!['gender']?.toString().toLowerCase() ?? 'other';
    final aiPrediction = _getAIPrediction();
    final accuracy = _calculateAccuracy();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          title: const Text(
            'Child Profile',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00C896).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF00C896).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      gender == 'male' ? Icons.boy : Icons.girl,
                      size: 40,
                      color: const Color(0xFF00C896).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Child Name
                  Text(
                    childData!['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Age
                  Text(
                    _calculateAge(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Birth Date and Guardian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Born: ${_formatDate(childData!['dob'])}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Guardian: ${childData!['guardianName'] ?? 'Unknown'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Village: ${childData!['village'] ?? 'Unknown'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Health Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Health Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (aiPrediction > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C896),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$aiPrediction%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Health Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _getHealthStatusColor(childData!['healthStatus']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getHealthStatusIcon(childData!['healthStatus']),
                          color: _getHealthStatusColor(childData!['healthStatus']),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getHealthStatusText(childData!['healthStatus']),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getHealthStatusColor(childData!['healthStatus']),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Photos Count
                  Row(
                    children: [
                      const Icon(Icons.photo_library, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${(childData!['photos'] as List?)?.length ?? 0} photos uploaded',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Last Updated
                  Text(
                    'Last updated: ${_getLastUpdated()}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Measurements Card (Height, Weight, BMI)
            if (childData!['predictedHeight'] != null || childData!['predictedWeight'] != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predicted Measurements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Predicted Height
                    if (childData!['predictedHeight'] != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.height, color: Color(0xFF00C896), size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Predicted Height', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                '${childData!['predictedHeight'].toStringAsFixed(1)} cm',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00C896),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    
                    // Predicted Weight
                    if (childData!['predictedWeight'] != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.monitor_weight, color: Colors.blue, size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Predicted Weight', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                '${(childData!['predictedWeight'] / 1000).toStringAsFixed(2)} kg',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    
                    // BMI
                    if (childData!['bmi'] != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.analytics, color: Colors.orange, size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BMI', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                childData!['bmi'].toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    if (childData!['lastHeightUpdate'] != null || childData!['lastWeightUpdate'] != null)
                      Text(
                        'Last updated: ${_formatDate(childData!['lastWeightUpdate'] ?? childData!['lastHeightUpdate'])}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    
                    // Actual Measurements Section
                    if (childData!['actualHeight'] != null || childData!['actualWeight'] != null) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Actual Measurements',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Actual Height
                      if (childData!['actualHeight'] != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.straighten, color: Colors.grey.shade600, size: 20),
                                const SizedBox(width: 8),
                                const Text('Actual Height:', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Text(
                              '${childData!['actualHeight'].toStringAsFixed(1)} cm',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Actual Weight
                      if (childData!['actualWeight'] != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.scale, color: Colors.grey.shade600, size: 20),
                                const SizedBox(width: 8),
                                const Text('Actual Weight:', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Text(
                              '${(childData!['actualWeight'] / 1000).toStringAsFixed(2)} kg',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ],
                        ),
                    ],
                    
                    // Accuracy Section
                    if (accuracy != null) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Model Accuracy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Height Accuracy
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getAccuracyColor(accuracy['heightAccuracy']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getAccuracyColor(accuracy['heightAccuracy']).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Height Accuracy',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${accuracy['heightAccuracy'].toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _getAccuracyColor(accuracy['heightAccuracy']),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Error: ${accuracy['heightError'].toStringAsFixed(1)} cm',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Weight Accuracy
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getAccuracyColor(accuracy['weightAccuracy']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getAccuracyColor(accuracy['weightAccuracy']).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Weight Accuracy',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${accuracy['weightAccuracy'].toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _getAccuracyColor(accuracy['weightAccuracy']),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Error: ${(accuracy['weightError'] / 1000).toStringAsFixed(2)} kg',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Predict Height Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isUploading ? null : _showUploadPhotoDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C896),
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.height, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Predict Height',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Predict Weight Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (isUploading || childData!['predictedHeight'] == null) ? null : _predictWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monitor_weight, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Predict Weight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Record Actual Measurements Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (isUploading || 
                            childData!['predictedHeight'] == null || 
                            childData!['predictedWeight'] == null) 
                    ? null 
                    : _showActualMeasurementsDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.straighten, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Record Actual Measurements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'at_risk':
        return Colors.orange;
      case 'malnourished':
        return Colors.red;
      case 'needs_attention':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getHealthStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return Icons.check_circle;
      case 'at_risk':
        return Icons.warning;
      case 'malnourished':
        return Icons.error;
      case 'needs_attention':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  String _getHealthStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return 'Healthy';
      case 'at_risk':
        return 'At Risk';
      case 'malnourished':
        return 'Malnourished';
      case 'needs_attention':
        return 'Needs Attention';
      default:
        return 'Unknown';
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: childData!['name']);
    final guardianController = TextEditingController(text: childData!['guardianName']);
    final villageController = TextEditingController(text: childData!['village']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Child Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: guardianController,
                  decoration: const InputDecoration(
                    labelText: 'Guardian Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: villageController,
                  decoration: const InputDecoration(
                    labelText: 'Village',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                guardianController.dispose();
                villageController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updates = {
                  'name': nameController.text.trim(),
                  'guardianName': guardianController.text.trim(),
                  'village': villageController.text.trim(),
                };
                
                Navigator.pop(context);
                await _updateProfile(updates);
                
                nameController.dispose();
                guardianController.dispose();
                villageController.dispose();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showUploadPhotoDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Upload 4 Photos for Height Prediction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'DOB and gender will be automatically extracted from profile',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleImageUpload(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C896),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleImageUpload(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}