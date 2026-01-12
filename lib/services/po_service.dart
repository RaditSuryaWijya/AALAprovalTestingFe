import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/po_model.dart';
import '../utils/storage_helper.dart';

class POService {
  // Helper untuk get headers dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET - List PO
  static Future<List<POModel>> getAllPO() async {
    try {
      final url = Uri.parse(ApiConfig.po);
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<POModel> poList = [];

        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          if (success && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              for (final item in data) {
                if (item is Map<String, dynamic>) {
                  poList.add(POModel.fromJson(item));
                }
              }
            } else if (data is Map<String, dynamic>) {
              poList.add(POModel.fromJson(data));
            }
          }
        } else if (responseData is List) {
          for (final item in responseData) {
            if (item is Map<String, dynamic>) {
              poList.add(POModel.fromJson(item));
            }
          }
        }

        return poList;
      }
      return [];
    } catch (e) {
      print('Error getAllPO: $e');
      return [];
    }
  }

  // GET - Detail PO
  static Future<POModel?> getPOById(int id) async {
    try {
      final url = Uri.parse(ApiConfig.poDetail(id));
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          if (success && responseData['data'] != null) {
            return POModel.fromJson(responseData['data']);
          }
        } else if (responseData is Map<String, dynamic>) {
          return POModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('Error getPOById: $e');
      return null;
    }
  }

  // POST - Create PO
  static Future<Map<String, dynamic>> createPO({
    required String namaBarang,
    required double totalHarga,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.po);
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'nama_barang': namaBarang,
          'total_harga': totalHarga,
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
                ? POModel.fromJson(responseData['data'])
                : null,
          };
        }
      }
      
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Gagal membuat request PO',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // POST - Approve PO
  static Future<Map<String, dynamic>> approvePO({
    required int id,
    required String action,
    String? rejectReason,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.poApprove(id));
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
                ? POModel.fromJson(responseData['data'])
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

