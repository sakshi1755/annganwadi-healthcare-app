import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:intl/intl.dart';

class ViewProfiles extends StatefulWidget {
  const ViewProfiles({super.key});

  @override
  State<ViewProfiles> createState() => _ViewProfilesState();
}

class _ViewProfilesState extends State<ViewProfiles> {
  static const String API_BASE_URL = 'http://10.0.2.2:3000';
  
  String searchQuery = '';
  List<Map<String, dynamic>> allProfiles = [];
  bool isLoading = true;
  String? userId;
  String? anganwadiId;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChildren();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      userId = args['userId'];
      anganwadiId = args['anganwadiId'];
    }
  }

  Future<void> _loadChildren() async {
    setState(() {
      isLoading = true;
    });

    try {
      String url = '$API_BASE_URL/api/profiles';
      if (anganwadiId != null) {
        url += '?anganwadiId=$anganwadiId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            allProfiles = List<Map<String, dynamic>>.from(data['profiles']);
          });
        }
      }
    } catch (e) {
      print('Error loading profiles: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profiles: ${e.toString()}'),
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

  List<Map<String, dynamic>> get filteredProfiles {
    if (searchQuery.isEmpty) {
      return allProfiles;
    }
    return allProfiles.where((profile) {
      final name = profile['name']?.toString().toLowerCase() ?? '';
      final guardian = profile['guardianName']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) || guardian.contains(query);
    }).toList();
  }

  String _calculateAge(String dobString) {
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return '$age years';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getLastCheckup(Map<String, dynamic> child) {
    if (child['photos'] != null && (child['photos'] as List).isNotEmpty) {
      final photos = child['photos'] as List;
      final lastPhoto = photos.last;
      try {
        final uploadDate = DateTime.parse(lastPhoto['uploadedAt']);
        final now = DateTime.now();
        final difference = now.difference(uploadDate);
        
        if (difference.inDays == 0) {
          return 'Today';
        } else if (difference.inDays == 1) {
          return '1 day ago';
        } else if (difference.inDays < 7) {
          return '${difference.inDays} days ago';
        } else if (difference.inDays < 30) {
          final weeks = (difference.inDays / 7).floor();
          return '$weeks week${weeks > 1 ? 's' : ''} ago';
        } else {
          final months = (difference.inDays / 30).floor();
          return '$months month${months > 1 ? 's' : ''} ago';
        }
      } catch (e) {
        return 'Unknown';
      }
    }
    return 'No checkups yet';
  }

  String _getHealthStatus(Map<String, dynamic> child) {
    final healthStatus = child['healthStatus']?.toString().toLowerCase();
    
    switch (healthStatus) {
      case 'healthy':
        return 'Healthy';
      case 'at_risk':
        return 'At Risk';
      case 'malnourished':
        return 'Malnourished';
      case 'needs_attention':
        return 'Needs Attention';
      default:
        return 'No data';
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: const Text(
          'View Profiles',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context, 
                '/add-child-basic',
                arguments: {
                  'userId': userId,
                  'anganwadiId': anganwadiId,
                },
              ).then((_) => _loadChildren());
            },
            icon: const Icon(Icons.add, color: Colors.black87),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search children or guardians...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          // Profiles List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00C896),
                    ),
                  )
                : filteredProfiles.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadChildren,
                        color: const Color(0xFF00C896),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredProfiles.length,
                          itemBuilder: (context, index) {
                            return _buildProfileCard(filteredProfiles[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final healthStatus = _getHealthStatus(profile);
    Color statusColor = _getStatusColor(healthStatus);
    final gender = profile['gender']?.toString().toLowerCase() ?? 'other';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/child-profile',
              arguments: {
                'profileId': profile['profileId'],
                'userId': userId,
                'anganwadiId': anganwadiId,
              },
            ).then((_) => _loadChildren());
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Profile Picture
                Container(
                  width: 60,
                  height: 60,
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
                    size: 28,
                    color: const Color(0xFF00C896).withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Profile Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Age
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              profile['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            _calculateAge(profile['dob']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Guardian
                      Text(
                        'Guardian: ${profile['guardianName'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Last Checkup and Health Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Last checkup: ${_getLastCheckup(profile)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              healthStatus,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 40,
              color: const Color(0xFF00C896).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No profiles found'
                : 'No results for "$searchQuery"',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Add your first child profile to get started'
                : 'Try searching with a different name',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context, 
                  '/add-child-basic',
                  arguments: {
                    'userId': userId,
                    'anganwadiId': anganwadiId,
                  },
                ).then((_) => _loadChildren());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Child Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C896),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Healthy':
        return Colors.green;
      case 'At Risk':
        return Colors.orange;
      case 'Malnourished':
        return Colors.red;
      case 'Needs Attention':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}