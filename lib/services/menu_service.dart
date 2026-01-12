import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/menu_model.dart';
import '../utils/storage_helper.dart';

class MenuService {
  // Helper untuk get headers dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET - Get menus dari API
  static Future<MenuResponseModel?> getMenus() async {
    try {
      final url = Uri.parse(ApiConfig.menus);
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;

          if (success && responseData['data'] != null) {
            return MenuResponseModel.fromJson(responseData);
          }
        }
      } else if (response.statusCode == 401) {
        // Token invalid
        await StorageHelper.clearAuth();
      }

      return null;
    } catch (e) {
      print('Error getMenus: $e');
      return null;
    }
  }
}

