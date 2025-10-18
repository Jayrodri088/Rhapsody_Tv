import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: Update baseUrl based on your testing environment:
  // - iOS Simulator: use 'http://localhost/rtv/rtv-backend/api'
  // - Android Emulator: use 'http://10.0.2.2/rtv/rtv-backend/api'
  // - Physical Device (iOS/Android): use 'http://192.168.1.189/rtv/rtv-backend/api'

  // Current setting for Production:
  static const String baseUrl = 'https://movortech.com/rtv-backend/api';

  // Android Emulator URL:
  // static const String baseUrl = 'http://10.0.2.2/rtv/rtv-backend/api';

  // Auth endpoints
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Comments endpoints
  static Future<Map<String, dynamic>> addComment({
    required String userId,
    required String username,
    required String channelId,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/comments/add.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'username': username,
          'channel_id': channelId,
          'comment': comment,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getComments({required String channelId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments/get.php?channel_id=$channelId'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // User profile endpoints
  static Future<Map<String, dynamic>> getUserProfile({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'phone_number': phoneNumber,
          'profile_image': profileImage,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> logout({
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Channels endpoints
  static Future<Map<String, dynamic>> getChannels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/channels/get.php'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Categories endpoints
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/get.php'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Notifications endpoints
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/get.php'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Viewing History endpoints
  static Future<Map<String, dynamic>> getViewingHistory({
    required String token,
    int limit = 50,
    String? contentType,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        if (contentType != null) 'content_type': contentType,
      };

      final uri = Uri.parse('$baseUrl/history/get.php').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> clearViewingHistory({
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/history/clear.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> addToViewingHistory({
    required String token,
    required String contentId,
    required String contentType,
    String? contentTitle,
    String? thumbnailUrl,
    int? duration,
    int? watchTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/history/add.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'content_id': contentId,
          'content_type': contentType,
          'content_title': contentTitle,
          'thumbnail_url': thumbnailUrl,
          'duration': duration,
          'watch_time': watchTime,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
