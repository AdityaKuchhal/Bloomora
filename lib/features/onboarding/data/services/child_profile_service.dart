import 'package:amazing_path_kids/core/api/api_client.dart';

class ChildProfileService {
  // Create child profile
  static Future<Map<String, dynamic>> createChild({
    required String name,
    required String dateOfBirth,
    required String gender,
    required String relationship,
  }) async {
    try {
      final response = await ApiClient.post('/children', {
        'name': name,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'relationship': relationship,
      });

      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  // Get all children for current user
  static Future<List<Map<String, dynamic>>> getChildren() async {
    try {
      final response = await ApiClient.get('/children');
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Get specific child
  static Future<Map<String, dynamic>> getChild(String childId) async {
    try {
      final response = await ApiClient.get('/children/$childId');
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  // Update child profile
  static Future<Map<String, dynamic>> updateChild({
    required String childId,
    String? name,
    String? dateOfBirth,
    String? gender,
    String? relationship,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;
      if (gender != null) data['gender'] = gender;
      if (relationship != null) data['relationship'] = relationship;

      final response = await ApiClient.put('/children/$childId', data);
      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  // Delete child profile
  static Future<void> deleteChild(String childId) async {
    try {
      await ApiClient.delete('/children/$childId');
    } catch (e) {
      rethrow;
    }
  }
}
