import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';
import '../models/approval_model.dart';

class ApprovalService {
  // READ - Ambil semua master approval
  static Future<List<ApprovalModel>> getAllApprovals() async {
    try {
      final url = Uri.parse(ApiConfig.approvals);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<ApprovalModel> approvals = [];

        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          if (success && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is List) {
              for (final item in data) {
                if (item is Map<String, dynamic>) {
                  approvals.add(ApprovalModel.fromJson(item));
                }
              }
            } else if (data is Map<String, dynamic>) {
              approvals.add(ApprovalModel.fromJson(data));
            }
          }
        } else if (responseData is List) {
          for (final item in responseData) {
            if (item is Map<String, dynamic>) {
              approvals.add(ApprovalModel.fromJson(item));
            }
          }
        }

        return approvals;
      } else {
        print('Gagal ambil master approval: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error ambil master approval: $e');
      return [];
    }
  }

  /// setStatus - update hanya field `status_approval` untuk satu master approval
  /// [approvalId] biasanya diambil dari field `approval_id` (contoh: AP-001)
  /// [statusApproval] contoh: ACTIVE / INACTIVE / PENDING
  static Future<ApprovalModel?> setStatus({
    required String approvalId,
    required String statusApproval,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.approvals}/$approvalId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'status_approval': statusApproval,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Handle format baru: {success, data, message}
        if (responseData is Map<String, dynamic>) {
          final bool success = responseData['success'] ?? false;
          final String message = responseData['message'] ?? '';

          if (success && responseData['data'] != null) {
            final data = responseData['data'];
            if (data is Map<String, dynamic>) {
              print('Sukses setStatus approval: $message');
              return ApprovalModel.fromJson(data);
            }
          } else {
            print('Gagal setStatus approval: $message');
            return null;
          }
        }

        // Fallback format lama (langsung object)
        if (responseData is Map<String, dynamic>) {
          print('Sukses setStatus approval (legacy format)');
          return ApprovalModel.fromJson(responseData);
        }

        print('Gagal setStatus approval: Format response tidak dikenali');
        return null;
      } else {
        print('Gagal setStatus approval: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error setStatus approval: $e');
      return null;
    }
  }
}
