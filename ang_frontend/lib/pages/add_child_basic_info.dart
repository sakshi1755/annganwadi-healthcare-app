// import 'package:flutter/material.dart';

// class AddChildBasicInfo extends StatefulWidget {
//   const AddChildBasicInfo({super.key});

//   @override
//   State<AddChildBasicInfo> createState() => _AddChildBasicInfoState();
// }

// class _AddChildBasicInfoState extends State<AddChildBasicInfo> {
//   final _nameController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _villageController = TextEditingController();
  
//   String? userId;
//   String? anganwadiId;
//   DateTime? selectedDate;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Get arguments passed from dashboard
//     final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     if (args != null) {
//       userId = args['userId'];
//       anganwadiId = args['anganwadiId'];
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _dobController.dispose();
//     _villageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Add New Child',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         actions: [
//           Container(
//             margin: const EdgeInsets.all(8),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: const Color(0xFF00C896),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Text(
//               '1/2',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Progress Bar
//           Container(
//             width: double.infinity,
//             height: 4,
//             color: Colors.grey[200],
//             child: FractionallySizedBox(
//               alignment: Alignment.centerLeft,
//               widthFactor: 0.5,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF00C896),
//                 ),
//               ),
//             ),
//           ),
          
//           Expanded(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 32),
                    
//                     // Header
//                     Center(
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: const BoxDecoration(
//                               color: Color(0xFFE8F8F5),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.person,
//                               color: Color(0xFF00C896),
//                               size: 30,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Basic Information',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             "Enter child's basic details",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     const SizedBox(height: 40),
                    
//                     // Child's Name Field
//                     const Text(
//                       "Child's Name",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter full name',
//                         hintStyle: const TextStyle(color: Colors.black38),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Color(0xFF00C896)),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 24),
                    
//                     // Date of Birth Field
//                     const Text(
//                       'Date of Birth',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _dobController,
//                       decoration: InputDecoration(
//                         hintText: 'DD/MM/YYYY',
//                         hintStyle: const TextStyle(color: Colors.black38),
//                         filled: true,
//                         fillColor: Colors.white,
//                         suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00C896)),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Color(0xFF00C896)),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                       ),
//                       onTap: () async {
//                         final DateTime? picked = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now().subtract(const Duration(days: 365)),
//                           firstDate: DateTime(2000),
//                           lastDate: DateTime.now(),
//                           builder: (context, child) {
//                             return Theme(
//                               data: Theme.of(context).copyWith(
//                                 colorScheme: const ColorScheme.light(
//                                   primary: Color(0xFF00C896),
//                                 ),
//                               ),
//                               child: child!,
//                             );
//                           },
//                         );
//                         if (picked != null) {
//                           selectedDate = picked;
//                           _dobController.text = 
//                               '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
//                         }
//                       },
//                       readOnly: true,
//                     ),
                    
//                     const SizedBox(height: 24),
                    
//                     // Village/Area Field
//                     const Text(
//                       'Village/Area Name',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _villageController,
//                       decoration: InputDecoration(
//                         hintText: 'Enter village or area name',
//                         hintStyle: const TextStyle(color: Colors.black38),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Color(0xFF00C896)),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 40),
                    
//                     // Next Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_nameController.text.trim().isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Please enter child\'s name'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }
                          
//                           if (_dobController.text.trim().isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Please select date of birth'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }
                          
//                           if (_villageController.text.trim().isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Please enter village/area name'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }
                          
//                           // Navigate to next screen with all data
//                           Navigator.pushNamed(
//                             context, 
//                             '/add-child-additional',
//                             arguments: {
//                               'name': _nameController.text.trim(),
//                               'dob': selectedDate!.toIso8601String(),
//                               'village': _villageController.text.trim(),
//                               'userId': userId,
//                               'anganwadiId': anganwadiId,
//                             },
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF00C896),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: const Text(
//                           'Next',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/custom_app_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class AddChildBasicInfo extends StatefulWidget {
  const AddChildBasicInfo({super.key});

  @override
  State<AddChildBasicInfo> createState() => _AddChildBasicInfoState();
}

class _AddChildBasicInfoState extends State<AddChildBasicInfo> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _awcController = TextEditingController();
  final String API_BASE_URL = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
  String? userId;
  String? anganwadiId;
  DateTime? selectedDate;
  
  // Autocomplete related
  List<dynamic> awcSuggestions = [];
  bool isSearching = false;
  Timer? _debounce;
  String? selectedAwcCode;
  String? selectedAwcName;
  String? selectedVillage;
  bool showSuggestions = false;
  final FocusNode _awcFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Listen to focus changes to hide suggestions when field loses focus
    _awcFocusNode.addListener(() {
      if (!_awcFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              showSuggestions = false;
            });
          }
        });
      }
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

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _awcController.dispose();
    _awcFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // AUTOCOMPLETE SEARCH FUNCTION
  Future<void> _searchAnganwadi(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        awcSuggestions = [];
        isSearching = false;
        showSuggestions = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      showSuggestions = true;
    });

    try {
      // Determine if user is typing code (numbers) or name (text)
      final isNumeric = RegExp(r'^[0-9]+$').hasMatch(query);
      final searchBy = isNumeric ? 'code' : 'name';
      
      final response = await http.get(
        Uri.parse(
          '$API_BASE_URL/api/anganwadis/search?query=$query&searchBy=$searchBy&limit=10'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          awcSuggestions = data['results'] ?? [];
          isSearching = false;
        });
      } else {
        setState(() {
          awcSuggestions = [];
          isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        isSearching = false;
        awcSuggestions = [];
      });
      print('Error searching: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // SELECT SUGGESTION
  void _selectSuggestion(dynamic item) {
    setState(() {
      selectedAwcCode = item['AWC_Code'];
      selectedAwcName = item['AWC_Name'];
      selectedVillage = item['Sector_name'] ?? item['AWC_Name'];
      _awcController.text = '${item['AWC_Code']} - ${item['AWC_Name']}';
      awcSuggestions = [];
      showSuggestions = false;
    });
    _awcFocusNode.unfocus();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Child',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            width: double.infinity,
            height: 4,
            color: Colors.grey[200],
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF00C896),
                ),
              ),
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
                              Icons.person,
                              color: Color(0xFF00C896),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Enter child's basic details",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Child's Name Field
                    const Text(
                      "Child's Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter full name',
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
                    
                    const SizedBox(height: 24),
                    
                    // Date of Birth Field
                    const Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        hintText: 'DD/MM/YYYY',
                        hintStyle: const TextStyle(color: Colors.black38),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF00C896)),
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
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF00C896),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          selectedDate = picked;
                          _dobController.text = 
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                        }
                      },
                      readOnly: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // AWC AUTOCOMPLETE FIELD
                    const Text(
                      'Anganwadi Center',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // AUTOCOMPLETE INPUT WITH SUGGESTIONS
                    Column(
                      children: [
                        TextField(
                          controller: _awcController,
                          focusNode: _awcFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Type AWC code or name (e.g., ANG001 or Village Name)',
                            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00C896)),
                            suffixIcon: isSearching 
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C896)),
                                    ),
                                  ),
                                )
                              : Icon(
                                  selectedAwcCode != null ? Icons.check_circle : Icons.search,
                                  color: selectedAwcCode != null ? Colors.green : const Color(0xFF00C896),
                                ),
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
                              borderSide: const BorderSide(color: Color(0xFF00C896), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            // Clear selection when user types
                            if (selectedAwcCode != null) {
                              setState(() {
                                selectedAwcCode = null;
                                selectedAwcName = null;
                                selectedVillage = null;
                              });
                            }
                            
                            // Debounce search
                            if (_debounce?.isActive ?? false) _debounce!.cancel();
                            _debounce = Timer(const Duration(milliseconds: 400), () {
                              _searchAnganwadi(value);
                            });
                          },
                        ),
                        
                        // SUGGESTIONS DROPDOWN
                        if (showSuggestions && awcSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            constraints: const BoxConstraints(maxHeight: 300),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: awcSuggestions.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey[200],
                              ),
                              itemBuilder: (context, index) {
                                final item = awcSuggestions[index];
                                return InkWell(
                                  onTap: () => _selectSuggestion(item),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['AWC_Name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00C896).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item['AWC_Code'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF00C896),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item['Sector_name'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (item['District_Name'] != null) ...[
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(Icons.location_city, size: 12, color: Colors.grey[500]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${item['District_Name']}${item['Project_Name'] != null ? " • ${item['Project_Name']}" : ""}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[500],
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        // NO RESULTS MESSAGE
                        if (showSuggestions && !isSearching && awcSuggestions.isEmpty && _awcController.text.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No Anganwadi centers found. Try searching by code or name.',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validation
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter child\'s name'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          if (_dobController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select date of birth'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          if (selectedAwcCode == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select an Anganwadi center from suggestions'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          
                          // Navigate to next screen with all data
                          Navigator.pushNamed(
                            context, 
                            '/add-child-additional',
                            arguments: {
                              'name': _nameController.text.trim(),
                              'dob': selectedDate!.toIso8601String(),
                              'awcCode': selectedAwcCode,
                              'awcName': selectedAwcName,
                              'village': selectedVillage ?? selectedAwcName,
                              'userId': userId,
                              'anganwadiId': selectedAwcCode, // Use selected AWC code
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Next',
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
}