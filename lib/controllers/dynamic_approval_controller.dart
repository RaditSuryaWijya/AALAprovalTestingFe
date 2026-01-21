import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/approval_item.dart';
import '../controllers/approval_controller.dart';
import '../utils/storage_helper.dart';

/// DynamicApprovalController
/// Controller yang dapat bekerja dengan API dinamis berdasarkan config
/// 
/// Controller ini menerima apiUrl saat inisialisasi dan akan:
/// 1. GET request ke apiUrl untuk mendapatkan data dan config
/// 2. Membaca config untuk mendapatkan pageTitle dan mapping
/// 3. Mapping data JSON mentah menjadi List<ApprovalItem>
/// 4. Handle approve/reject dengan endpoint dinamis
class DynamicApprovalController implements ApprovalController {
  /// URL API untuk load items
  final String apiUrl;

  /// Master name (untuk export PDF, dll)
  /// Contoh: 'cuti', 'lembur', 'po'
  final String masterName;

  /// Config yang didapat dari API response
  Map<String, dynamic>? _config;

  /// Mapping field dari config
  Map<String, String>? _mapping;

  /// Page title dari config
  String? _pageTitle;

  /// Constructor
  /// [apiUrl] adalah URL endpoint untuk GET data (contoh: '/api/approval/cuti')
  /// [masterName] adalah nama master (contoh: 'cuti', 'lembur', 'po')
  DynamicApprovalController({
    required this.apiUrl,
    required this.masterName,
  });

  /// Generate correlation id (UUID-like) per request
  String _generateCorrelationId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1 << 32);
    return '${millis.toRadixString(16)}-${random.toRadixString(16)}';
  }

  /// Helper untuk mendapatkan headers dengan token
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    final deviceId = await StorageHelper.getOrCreateDeviceId();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Correlation-Id': _generateCorrelationId(),
      'X-Device-Id': deviceId,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Helper POST with retry & backoff for network issues (no retry on 4xx)
  Future<http.Response> _postWithRetry(
    Uri url, {
    required Map<String, String> headers,
    required Object body,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(milliseconds: 700);

    while (true) {
      attempt++;
      try {
        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 10));
        // Retry only on network/timeouts; not on 4xx (including 409) or 5xx unless network error
        return response;
      } on SocketException catch (_) {
        if (attempt >= maxRetries) rethrow;
      } on TimeoutException catch (_) {
        if (attempt >= maxRetries) rethrow;
      }

      await Future.delayed(delay);
      delay *= 2; // exponential backoff
    }
  }

  /// Helper GET with retry for network issues
  Future<http.Response> _getWithRetry(
    Uri url, {
    required Map<String, String> headers,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    Duration delay = const Duration(milliseconds: 700);

    while (true) {
      attempt++;
      try {
        final response = await http
            .get(url, headers: headers)
            .timeout(const Duration(seconds: 10));
        return response;
      } on SocketException catch (_) {
        if (attempt >= maxRetries) rethrow;
      } on TimeoutException catch (_) {
        if (attempt >= maxRetries) rethrow;
      }
      await Future.delayed(delay);
      delay *= 2;
    }
  }

  /// Load items dari API
  /// 
  /// Flow:
  /// 1. GET request ke apiUrl
  /// 2. Baca object config dari JSON response untuk mendapatkan pageTitle
  /// 3. Baca object config['mapping'] untuk mengetahui key mapping
  /// 4. Mapping data JSON mentah menjadi List<ApprovalItem>
  @override
  Future<List<ApprovalItem>> loadItems() async {
    try {
      final url = Uri.parse(apiUrl);
      final headers = await _getHeaders();
      final response = await _getWithRetry(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to load items: ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Cek apakah response success
      final bool success = responseData['success'] ?? false;
      if (!success) {
        throw Exception('API returned success: false');
      }

      // Baca config dari response
      if (responseData['config'] != null) {
        _config = responseData['config'] as Map<String, dynamic>;

        // Baca page_title dari config
        _pageTitle = _config!['page_title']?.toString();

        // Baca mapping dari config
        if (_config!['mapping'] != null) {
          final mappingData = _config!['mapping'] as Map<String, dynamic>;
          _mapping = {};
          mappingData.forEach((key, value) {
            _mapping![key] = value.toString();
          });
        }
      }

      // Baca data dari response
      final List<ApprovalItem> items = [];
      if (responseData['data'] != null) {
        final data = responseData['data'];
        if (data is List) {
          // Jika data adalah array
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              // Mapping menggunakan config mapping
              if (_mapping != null) {
                items.add(ApprovalItem.fromJson(item, _mapping!));
              } else {
                // Fallback jika tidak ada mapping, gunakan field default
                items.add(ApprovalItem(
                  id: item['id'] ?? 0,
                  title: item['title']?.toString() ?? '',
                  subtitle: item['subtitle']?.toString() ?? '',
                  date: item['date']?.toString(),
                  status: item['status']?.toString(),
                  rawData: item,
                ));
              }
            }
          }
        } else if (data is Map<String, dynamic>) {
          // Jika data adalah single object
          if (_mapping != null) {
            items.add(ApprovalItem.fromJson(data, _mapping!));
          } else {
            items.add(ApprovalItem(
              id: data['id'] ?? 0,
              title: data['title']?.toString() ?? '',
              subtitle: data['subtitle']?.toString() ?? '',
              date: data['date']?.toString(),
              status: data['status']?.toString(),
              rawData: data,
            ));
          }
        }
      }

      return items;
    } catch (e) {
      throw Exception('Error loading items: $e');
    }
  }

  /// Approve item dengan ID tertentu
  /// 
  /// Endpoint yang digunakan: {apiUrl}/{id}/approve
  /// Method: POST
  /// Body: { "action": "approve" }
  /// 
  /// Backend akan menentukan level approval (supervisor/manager/dll) 
  /// berdasarkan role user dari token Authorization header
  /// Frontend tidak perlu tahu level approval - semua di-handle oleh backend
  @override
  Future<Map<String, dynamic>> approve(int id) async {
    try {
      // Construct approve URL: {apiUrl}/{id}/approve
      // Contoh: /api/lembur/5/approve
      // Backend akan membaca token dan menentukan apakah approve sebagai supervisor/manager
      final approveUrl = '$apiUrl/$id/approve';
      final url = Uri.parse(approveUrl);
      final headers = await _getHeaders();

      final response = await _postWithRetry(
        url,
        headers: headers,
        body: jsonEncode({
          'action': 'approve',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message']?.toString() ?? 'Approved successfully',
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 409) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'conflict': true,
          'statusCode': response.statusCode,
          'message': responseData['message']?.toString() ??
              'Data sudah diproses, silakan refresh',
        };
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': errorData['message']?.toString() ?? 'Failed to approve: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'statusCode': null,
        'message': 'Error approving: $e',
      };
    }
  }

  /// Reject item dengan ID tertentu
  /// 
  /// Endpoint yang digunakan: {apiUrl}/{id}/reject
  /// Method: POST
  /// Body: { "action": "reject", "reject_reason": rejectReason }
  /// 
  /// Backend akan menentukan level approval (supervisor/manager/dll) 
  /// berdasarkan role user dari token Authorization header
  /// Frontend tidak perlu tahu level approval - semua di-handle oleh backend
  @override
  Future<Map<String, dynamic>> reject(int id, {String? rejectReason}) async {
    try {
      // Construct reject URL: {apiUrl}/{id}/reject
      // Contoh: /api/lembur/5/reject
      // Backend akan membaca token dan menentukan apakah reject sebagai supervisor/manager
      final rejectUrl = '$apiUrl/$id/reject';
      final url = Uri.parse(rejectUrl);
      final headers = await _getHeaders();

      final response = await _postWithRetry(
        url,
        headers: headers,
        body: jsonEncode({
          'action': 'reject',
          if (rejectReason != null && rejectReason.isNotEmpty) 'reject_reason': rejectReason,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': responseData['success'] ?? true,
          'message': responseData['message']?.toString() ?? 'Rejected successfully',
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 409) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'conflict': true,
          'statusCode': response.statusCode,
          'message': responseData['message']?.toString() ??
              'Data sudah diproses, silakan refresh',
        };
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': errorData['message']?.toString() ?? 'Failed to reject: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'statusCode': null,
        'message': 'Error rejecting: $e',
      };
    }
  }

  /// Get page title dari config
  /// Jika config belum di-load atau tidak ada, return default title
  @override
  String getPageTitle() {
    return _pageTitle ?? 'Approval $masterName';
  }

  /// Get master name
  @override
  String getMasterName() {
    return masterName;
  }

  /// Get config yang sudah di-load (untuk keperluan tambahan)
  Map<String, dynamic>? getConfig() => _config;

  /// Get mapping yang sudah di-load (untuk keperluan tambahan)
  Map<String, String>? getMapping() => _mapping;
}
