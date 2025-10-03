// lib/providers/child_provider.dart - REPLACE THE ENTIRE FILE
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChildProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic>? _selectedChild;
  bool _isLoading = false;
  Map<String, dynamic>? _dashboardStats;

  List<Map<String, dynamic>> get children => _children;
  Map<String, dynamic>? get selectedChild => _selectedChild;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  // Load all children
  Future<void> loadChildren() async {
    _isLoading = true;
    notifyListeners();

    try {
      _children = await ApiService.getChildren();
      debugPrint('Loaded ${_children.length} children');
    } catch (e) {
      debugPrint('Error loading children: $e');
      _children = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create new child
  Future<bool> createChild({
    required String name,
    required String dob,
    required String gender,
    required String guardian,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Creating child: $name, $dob, $gender, $guardian');
      
      final result = await ApiService.createChild(
        name: name,
        dob: dob,
        gender: gender,
        guardian: guardian,
      );

      debugPrint('Create child result: $result');

      // Check if we got a successful response
      if (result['success'] == true && result['child'] != null) {
        // Add the new child to the local list immediately
        final newChild = result['child'];
        _children.add(newChild);
        
        debugPrint('Child created successfully: ${newChild['name']}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Create child failed - no success flag or child data');
      }
    } catch (e) {
      debugPrint('Error creating child: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update child
  Future<bool> updateChild({
    required String childId,
    required String name,
    required String dob,
    required String gender,
    required String guardian,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.updateChild(
        childId: childId,
        name: name,
        dob: dob,
        gender: gender,
        guardian: guardian,
      );

      if (result['success'] == true && result['child'] != null) {
        // Update local data
        final updatedChild = result['child'];
        final index = _children.indexWhere((child) => 
          child['id'] == childId || child['_id'] == childId);
        
        if (index != -1) {
          _children[index] = updatedChild;
        }
        
        if (_selectedChild?['id'] == childId || _selectedChild?['_id'] == childId) {
          _selectedChild = updatedChild;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating child: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Load specific child
  Future<void> loadChild(String childId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedChild = await ApiService.getChild(childId);
    } catch (e) {
      debugPrint('Error loading child: $e');
      _selectedChild = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add measurement to child
  Future<bool> addMeasurement({
    required String childId,
    required double height,
    required double weight,
    int? aiPrediction,
    String? photoUrl,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.addMeasurement(
        childId: childId,
        height: height,
        weight: weight,
        aiPrediction: aiPrediction,
        photoUrl: photoUrl,
        notes: notes,
      );

      if (result['success'] == true) {
        // For dummy mode, just update the stats
        await loadDashboardStats();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error adding measurement: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Load dashboard stats
  Future<void> loadDashboardStats() async {
    try {
      _dashboardStats = await ApiService.getDashboardStats();
      
      // Update stats based on current children count
      if (_dashboardStats != null) {
        _dashboardStats!['totalChildren'] = _children.length;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
    }
  }

  // Set selected child
  void setSelectedChild(Map<String, dynamic>? child) {
    _selectedChild = child;
    notifyListeners();
  }

  // Clear data
  void clearData() {
    _children = [];
    _selectedChild = null;
    _dashboardStats = null;
    notifyListeners();
  }

  // Get child by ID
  Map<String, dynamic>? getChildById(String childId) {
    try {
      return _children.firstWhere((child) => 
        child['id'] == childId || child['_id'] == childId);
    } catch (e) {
      return null;
    }
  }

  // Delete child (for testing)
  Future<bool> deleteChild(String childId) async {
    try {
      _children.removeWhere((child) => 
        child['id'] == childId || child['_id'] == childId);
      
      if (_selectedChild?['id'] == childId || _selectedChild?['_id'] == childId) {
        _selectedChild = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting child: $e');
      return false;
    }
  }
}