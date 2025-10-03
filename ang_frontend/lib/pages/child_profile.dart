import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _handleImageUpload(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    
    setState(() {
      isUploading = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        // User cancelled
        setState(() {
          isUploading = false;
        });
        return;
      }

      // Show picked image info
      print('Image picked: ${image.path}');
      print('Image size: ${await image.length()} bytes');

      // In a production app, you would:
      // 1. Upload the image file to cloud storage (Firebase Storage, AWS S3, Cloudinary)
      // 2. Get the public URL from the storage
      // 3. Run AI prediction on the image (send to ML model API)
      // 4. Send the URL and prediction to your backend

      // For now, we'll simulate the upload with the local file info
      await Future.delayed(const Duration(seconds: 1));

      final photoData = {
        'photoUrl': 'file://${image.path}', // In production, this would be the cloud storage URL
        'predictionResult': 'healthy', // This would come from your AI model
        'predictionConfidence': 0.92,
      };

      final response = await http.post(
        Uri.parse('$API_BASE_URL/api/profiles/$profileId/photos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(photoData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _loadChildProfile();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo uploaded successfully!'),
                backgroundColor: Color(0xFF00C896),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error uploading photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
        ),
        body: const Center(
          child: Text('Profile not found'),
        ),
      );
    }

    final gender = childData!['gender']?.toString().toLowerCase() ?? 'other';
    final aiPrediction = _getAIPrediction();

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
        actions: [
          IconButton(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
          ),
        ],
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
            
            const SizedBox(height: 24),
            
            // Upload New Photo Button
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
                          Icon(Icons.camera_alt, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Upload New Photo',
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
                'Upload Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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