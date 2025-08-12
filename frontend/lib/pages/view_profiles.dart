import 'package:flutter/material.dart';

class ViewProfiles extends StatefulWidget {
  const ViewProfiles({super.key});

  @override
  State<ViewProfiles> createState() => _ViewProfilesState();
}

class _ViewProfilesState extends State<ViewProfiles> {
  String searchQuery = '';
  
  // Mock data for children profiles - in real app, this would come from database
  final List<Map<String, dynamic>> childrenProfiles = [
    {
      'id': '1',
      'name': 'Aarav Sharma',
      'age': '4 years',
      'dob': '15/03/2020',
      'guardian': 'Sunita Sharma',
      'gender': 'Male',
      'lastCheckup': '2 days ago',
      'healthStatus': 'Good',
      'profileImage': null,
    },
    {
      'id': '2',
      'name': 'Priya Singh',
      'age': '3 years',
      'dob': '22/08/2021',
      'guardian': 'Rakesh Singh',
      'gender': 'Female',
      'lastCheckup': '1 week ago',
      'healthStatus': 'Needs Attention',
      'profileImage': null,
    },
    {
      'id': '3',
      'name': 'Arjun Patel',
      'age': '5 years',
      'dob': '10/01/2019',
      'guardian': 'Meera Patel',
      'gender': 'Male',
      'lastCheckup': '3 days ago',
      'healthStatus': 'Excellent',
      'profileImage': null,
    },
    {
      'id': '4',
      'name': 'Kavya Reddy',
      'age': '2 years',
      'dob': '05/12/2022',
      'guardian': 'Sanjay Reddy',
      'gender': 'Female',
      'lastCheckup': '5 days ago',
      'healthStatus': 'Good',
      'profileImage': null,
    },
    {
      'id': '5',
      'name': 'Rohan Kumar',
      'age': '4 years',
      'dob': '18/06/2020',
      'guardian': 'Anjali Kumar',
      'gender': 'Male',
      'lastCheckup': '1 day ago',
      'healthStatus': 'Good',
      'profileImage': null,
    },
  ];

  List<Map<String, dynamic>> get filteredProfiles {
    if (searchQuery.isEmpty) {
      return childrenProfiles;
    }
    return childrenProfiles.where((profile) {
      return profile['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
             profile['guardian'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
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
              Navigator.pushNamed(context, '/add-child-basic');
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
            child: filteredProfiles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredProfiles.length,
                    itemBuilder: (context, index) {
                      return _buildProfileCard(filteredProfiles[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    Color statusColor = _getStatusColor(profile['healthStatus']);
    
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
              arguments: profile,
            );
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
                  child: profile['profileImage'] != null
                      ? ClipOval(
                          child: Image.asset(
                            profile['profileImage'],
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          profile['gender'] == 'Male' 
                              ? Icons.boy 
                              : Icons.girl,
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
                              profile['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            profile['age'],
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
                        'Guardian: ${profile['guardian']}',
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
                              'Last checkup: ${profile['lastCheckup']}',
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
                              profile['healthStatus'],
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
                Navigator.pushNamed(context, '/add-child-basic');
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
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Needs Attention':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}