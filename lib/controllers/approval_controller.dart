import '../models/approval_item.dart';

/// Abstract class untuk controller approval
/// Semua controller approval harus mengimplementasikan interface ini
abstract class ApprovalController {
  /// Load items dari API
  /// Return List<ApprovalItem> yang sudah di-mapping
  Future<List<ApprovalItem>> loadItems();

  /// Approve item dengan ID tertentu
  /// [id] adalah ID dari item yang akan di-approve
  /// Return Map dengan 'success' dan 'message'
  Future<Map<String, dynamic>> approve(int id);

  /// Reject item dengan ID tertentu
  /// [id] adalah ID dari item yang akan di-reject
  /// [rejectReason] adalah alasan reject (opsional)
  /// Return Map dengan 'success' dan 'message'
  Future<Map<String, dynamic>> reject(int id, {String? rejectReason});

  /// Get page title untuk halaman approval
  /// Bisa diambil dari config API atau hardcoded
  String getPageTitle();

  /// Get master name (untuk export PDF, dll)
  /// Contoh: 'cuti', 'lembur', 'po'
  String getMasterName();
}
