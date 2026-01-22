import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/approval_item.dart';
import '../models/pagination_metadata.dart';
import '../controllers/approval_controller.dart';
import '../utils/storage_helper.dart';

/// Controller approval generik yang mengambil konfigurasi dan data dari API
/// lalu memetakan response menjadi `ApprovalItem` untuk digunakan di UI.
class DynamicApprovalController implements ApprovalController {
  final String apiUrl;
  final String masterName;
  Map<String, dynamic>? _config;
  String? _pageTitle;
  PaginationMetadata? _pagination;

  DynamicApprovalController({
    required this.apiUrl,
    required this.masterName,
  });

  /// Membuat ID korelasi per request untuk keperluan tracing/logging.
  String _generateCorrelationId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1 << 32);
    return '${millis.toRadixString(16)}-${random.toRadixString(16)}';
  }

  /// Menyusun header HTTP standar (auth, tracing, device ID).
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

  /// Melakukan POST dengan retry & exponential backoff untuk error jaringan/timeout.
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

  /// Melakukan GET dengan retry & exponential backoff untuk error jaringan/timeout.
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

  /// Mengambil dan memetakan daftar item approval dari API menjadi `List<ApprovalItem>`.
  @override
  Future<List<ApprovalItem>> loadItems({int page = 1, int perPage = 15}) async {
    try {
      final uri = Uri.parse(apiUrl);
      final url = uri.replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      });
      final headers = await _getHeaders();
      final response = await _getWithRetry(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to load items: ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final bool success = responseData['success'] ?? false;
      if (!success) {
        throw Exception('API returned success: false');
      }
      if (responseData['config'] != null) {
        _config = responseData['config'] as Map<String, dynamic>;
        _pageTitle = _config!['page_title']?.toString();
      }
      if (responseData['pagination'] != null) {
        _pagination = PaginationMetadata.fromJson(
          responseData['pagination'] as Map<String, dynamic>,
        );
      }
      final List<ApprovalItem> items = [];
      if (responseData['data'] != null) {
        final data = responseData['data'];
        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
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
        } else if (data is Map<String, dynamic>) {
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

      return items;
    } catch (e) {
      throw Exception('Error loading items: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> approve(int id) async {
    try {
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

  @override
  Future<Map<String, dynamic>> reject(int id, {String? rejectReason}) async {
    try {
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

  @override
  PaginationMetadata? getPagination() => _pagination;
}
