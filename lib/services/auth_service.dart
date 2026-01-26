import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/auth_user_model.dart';
import '../utils/storage_helper.dart';
import 'fcm_token_service.dart';
import 'fcm_service.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.login);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Version': ApiConfig.clientVersion,
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          
          if (success && responseData['data'] != null) {
            final data = responseData['data'];
            final String token = data['token'] ?? '';
            final userData = data['user'];
            
            // Simpan token dan user data
            if (token.isNotEmpty) {
              await StorageHelper.saveToken(token);
            }
            if (userData != null) {
              await StorageHelper.saveUserData(jsonEncode(userData));
            }
            
            // Kirim FCM token ke Laravel setelah login berhasil
            // (Token sudah diambil saat initialize, sekarang baru dikirim karena sudah ada auth token)
            await FCMService.sendTokenAfterLogin();
            
            return {
              'success': true,
              'message': responseData['message'] ?? 'Login berhasil',
              'user': AuthUserModel.fromJson(userData),
              'token': token,
            };
          }
        }
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Logout
  static Future<bool> logout() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        await StorageHelper.clearAuth();
        return true;
      }

      // IMPORTANT:
      // Hapus FCM token SEBELUM memanggil endpoint logout.
      // Banyak backend akan me-revoke token saat /logout, sehingga request berikutnya (delete fcm-token)
      // akan menjadi 401 Unauthorized.
      await FCMTokenService.deleteTokenFromLaravel();

      final url = Uri.parse(ApiConfig.logout);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Version': ApiConfig.clientVersion,
          'Authorization': 'Bearer $token',
        },
      );
      
      await StorageHelper.clearAuth();
      
      return response.statusCode == 200;
    } catch (e) {
      // Best effort cleanup
      await FCMTokenService.deleteTokenFromLaravel();
      await StorageHelper.clearAuth();
      return false;
    }
  }

  // Get Current User
  static Future<AuthUserModel?> getCurrentUser() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return null;

      final url = Uri.parse(ApiConfig.me);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Version': ApiConfig.clientVersion,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          
          if (success && responseData['data'] != null) {
            final userData = responseData['data'];
            final user = AuthUserModel.fromJson(userData);
            
            // Update stored user data
            await StorageHelper.saveUserData(jsonEncode(userData));
            
            return user;
          }
        }
      } else if (response.statusCode == 401) {
        // Token invalid, clear auth
        await StorageHelper.clearAuth();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await StorageHelper.getToken();
    if (token == null) return false;
    
    // Verify token dengan getCurrentUser
    final user = await getCurrentUser();
    return user != null;
  }
}

