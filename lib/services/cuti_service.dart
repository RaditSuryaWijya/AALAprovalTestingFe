import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/cuti_model.dart';
import '../utils/storage_helper.dart';

class CutiService {
  // Helper untuk get headers dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET - List cuti
  static Future<List<CutiModel>> getAllcuti() async {
    try {
      final url = Uri.parse(ApiConfig.cuti);
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<CutiModel> cutiList = [];

        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          if (success && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              for (final item in data) {
                if (item is Map<String, dynamic>) {
                  cutiList.add(CutiModel.fromJson(item));
                }
              }
            } else if (data is Map<String, dynamic>) {
              cutiList.add(CutiModel.fromJson(data));
            }
          }
        } else if (responseData is List) {
          for (final item in responseData) {
            if (item is Map<String, dynamic>) {
              cutiList.add(CutiModel.fromJson(item));
            }
          }
        }

        return cutiList;
      }
      return [];
    } catch (e) {
      print('Error getAllcuti: $e');
      return [];
    }
  }

  // GET - Detail cuti
  static Future<CutiModel?> getcutiById(int id) async {
    try {
      final url = Uri.parse(ApiConfig.cutiDetail(id));
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          if (success && responseData['data'] != null) {
            return CutiModel.fromJson(responseData['data']);
          }
        } else if (responseData is Map<String, dynamic>) {
          return CutiModel.fromJson(responseData);
        }
      }
      return null;
    } catch (e) {
      print('Error getcutiById: $e');
      return null;
    }
  }

  // POST - Create cuti
  static Future<Map<String, dynamic>> createcuti({
    required String tanggal,
    required String keterangan,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.cuti);
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
                ? CutiModel.fromJson(responseData['data'])
                : null,
          };
        }
      }

      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Gagal membuat request cuti',
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
      final url = Uri.parse(ApiConfig.cutiApproveSupervisor(id));
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
                ? CutiModel.fromJson(responseData['data'])
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
      final url = Uri.parse(ApiConfig.cutiApproveManager(id));
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
                ? CutiModel.fromJson(responseData['data'])
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

