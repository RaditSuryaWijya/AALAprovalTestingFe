import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/lembur_model.dart';
import '../utils/storage_helper.dart';

class LemburService {
  // Helper untuk get headers dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET - List Lembur
  static Future<List<LemburModel>> getAllLembur() async {
    try {
      final url = Uri.parse(ApiConfig.lembur);
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<LemburModel> lemburList = [];

        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          if (success && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              for (final item in data) {
                if (item is Map<String, dynamic>) {
                  lemburList.add(LemburModel.fromJson(item));
                }
              }
            } else if (data is Map<String, dynamic>) {
              lemburList.add(LemburModel.fromJson(data));
            }
          }
        } else if (responseData is List) {
          for (final item in responseData) {
            if (item is Map<String, dynamic>) {
              lemburList.add(LemburModel.fromJson(item));
            }
          }
        }

        return lemburList;
      }
      return [];
    } catch (e) {
      print('Error getAllLembur: $e');
      return [];
    }
  }

  // GET - Detail Lembur
  static Future<LemburModel?> getLemburById(int id) async {
    try {
      final url = Uri.parse(ApiConfig.lemburDetail(id));
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          if (success && responseData['data'] != null) {
            return LemburModel.fromJson(responseData['data']);
          }
        } else if (responseData is Map<String, dynamic>) {
          return LemburModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('Error getLemburById: $e');
      return null;
    }
  }

  // POST - Create Lembur
  static Future<Map<String, dynamic>> createLembur({
    required String tanggal,
    required String keterangan,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.lembur);
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'tanggal': tanggal,
          'keterangan': keterangan,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          return {
            'success': success,
            'message': responseData['message'] ?? '',
            'data': success && responseData['data'] != null
                ? LemburModel.fromJson(responseData['data'])
                : null,
          };
        }
      }
      
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Gagal membuat request lembur',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // POST - Approve by Supervisor
  static Future<Map<String, dynamic>> approveSupervisor({
    required int id,
    required String action,
    String? rejectReason,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.lemburApproveSupervisor(id));
      final headers = await _getHeaders();
      
      final body = <String, dynamic>{'action': action};
      if (action == 'reject' && rejectReason != null) {
        body['reject_reason'] = rejectReason;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          return {
            'success': success,
            'message': responseData['message'] ?? '',
            'data': success && responseData['data'] != null
                ? LemburModel.fromJson(responseData['data'])
                : null,
          };
        }
      }
      
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Gagal approve/reject',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // POST - Approve by Manager
  static Future<Map<String, dynamic>> approveManager({
    required int id,
    required String action,
    String? rejectReason,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.lemburApproveManager(id));
      final headers = await _getHeaders();
      
      final body = <String, dynamic>{'action': action};
      if (action == 'reject' && rejectReason != null) {
        body['reject_reason'] = rejectReason;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          return {
            'success': success,
            'message': responseData['message'] ?? '',
            'data': success && responseData['data'] != null
                ? LemburModel.fromJson(responseData['data'])
                : null,
          };
        }
      }
      
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Gagal approve/reject',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}

