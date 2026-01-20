import 'package:flutter/material.dart';
import '../pages/generic_approval_page.dart';
import '../config/api_config.dart';

/// Dynamic Route Resolver
/// Resolver untuk membuat widget secara dinamis berdasarkan menuLink dari server
/// 100% Server-Driven Routing
class DynamicRouteResolver {
  /// Resolve route dari menuLink menjadi WidgetBuilder
  /// 
  /// Format menuLink yang didukung:
  /// - /{master}/approval atau /{master}/approve -> GenericApprovalPage
  /// - /{master} -> GenericApprovalPage (default untuk approval)
  /// 
  /// Contoh:
  /// - /lembur/approval -> GenericApprovalPage untuk lembur
  /// - /cuti/approve -> GenericApprovalPage untuk cuti
  /// - /po/approval -> GenericApprovalPage untuk po
  static WidgetBuilder? resolveRoute(String menuLink) {
    // Normalize menu link
    final normalizedLink = menuLink.toLowerCase().replaceAll(RegExp(r'/$'), '');
    
    // Skip dashboard
    if (normalizedLink == '/dashboard' || normalizedLink.isEmpty) {
      return null;
    }

    // Parse route untuk mendapatkan master name
    // Format: /{master} atau /{master}/approval atau /{master}/approve
    final parts = normalizedLink.split('/').where((p) => p.isNotEmpty).toList();
    
    if (parts.isEmpty) {
      return null;
    }

    final masterName = parts[0];
    final action = parts.length > 1 ? parts[1] : null;

    // Jika action adalah 'approval' atau 'approve', atau tidak ada action (default approval)
    if (action == null || action == 'approval' || action == 'approve') {
      return _buildApprovalRoute(masterName);
    }

    // Untuk action lain (list, create, dll), return null karena tidak digunakan lagi
    // Server hanya akan mengirim menuLink untuk approval
    return null;
  }

  /// Build approval route untuk master tertentu
  static WidgetBuilder _buildApprovalRoute(String masterName) {
    return (context) => GenericApprovalPage(
      apiUrl: ApiConfig.approvalEndpoint(masterName),
      masterName: masterName,
      emptyMessage: _getEmptyMessage(masterName),
      emptyIcon: _getEmptyIcon(masterName),
    );
  }

  /// Get empty message berdasarkan master name
  static String _getEmptyMessage(String masterName) {
    switch (masterName.toLowerCase()) {
      case 'lembur':
        return 'Tidak ada request lembur pending';
      case 'cuti':
        return 'Tidak ada request cuti pending';
      case 'po':
        return 'Tidak ada request PO pending';
      default:
        return 'Tidak ada request pending';
    }
  }

  /// Get empty icon berdasarkan master name
  static IconData _getEmptyIcon(String masterName) {
    switch (masterName.toLowerCase()) {
      case 'lembur':
        return Icons.access_time;
      case 'cuti':
        return Icons.rule;
      case 'po':
        return Icons.shopping_cart;
      default:
        return Icons.rule;
    }
  }

  /// Check if route exists (untuk validasi)
  static bool hasRoute(String menuLink) {
    return resolveRoute(menuLink) != null;
  }
}
