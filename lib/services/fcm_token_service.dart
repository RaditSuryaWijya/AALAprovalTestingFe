import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../utils/storage_helper.dart';

/// Service untuk mengirim FCM Token ke Laravel backend
class FCMTokenService {
  /// Mengirim FCM token ke Laravel untuk disimpan di database
  /// Endpoint: POST /api/fcm-token
  /// Body: { "fcm_token": "token_string" }
  static Future<bool> saveTokenToLaravel(String token) async {
    try {
      final url = Uri.parse(ApiConfig.saveFcmToken);
      final headers = await _getHeaders();

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'fcm_token': token,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          if (success) {
            print('FCM Token berhasil disimpan ke Laravel');
            // Simpan token juga di local storage untuk referensi
            await StorageHelper.saveFcmToken(token);
            return true;
          }
        }
      } else if (response.statusCode == 401) {
        // Token invalid, mungkin perlu re-login
        print('Unauthorized saat menyimpan FCM token');
        await StorageHelper.clearAuth();
      } else {
        print(
            'Error menyimpan FCM token: ${response.statusCode} - ${response.body}');
      }

      return false;
    } catch (e) {
      print('Error saveTokenToLaravel: $e');
      return false;
    }
  }

  /// Helper untuk mendapatkan headers dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Version': ApiConfig.clientVersion,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Hapus FCM token dari Laravel (saat logout)
  static Future<bool> deleteTokenFromLaravel() async {
    try {
      final url = Uri.parse(ApiConfig.saveFcmToken);
      final headers = await _getHeaders();

      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('FCM Token berhasil dihapus dari Laravel');
        await StorageHelper.removeFcmToken();
        return true;
      }

      return false;
    } catch (e) {
      print('Error deleteTokenFromLaravel: $e');
      return false;
    }
  }
}
