import 'package:flutter/material.dart';
import '../pages/generic_approval_page.dart';
import '../config/api_config.dart';

/// Resolver yang mengubah `menu_link` dari backend menjadi halaman Flutter.
class DynamicRouteResolver {
  /// Menghasilkan `WidgetBuilder` dari string `menuLink` (mis. `/lembur/approval`).
  static WidgetBuilder? resolveRoute(String menuLink) {
    final normalizedLink = menuLink.toLowerCase().replaceAll(RegExp(r'/$'), '');
    if (normalizedLink == '/dashboard' || normalizedLink.isEmpty) {
      return null;
    }

    final parts = normalizedLink.split('/').where((p) => p.isNotEmpty).toList();
    
    if (parts.isEmpty) {
      return null;
    }

    final masterName = parts[0];
    final action = parts.length > 1 ? parts[1] : null;

    if (action == null || action == 'approval' || action == 'approve') {
      return _buildApprovalRoute(masterName);
    }
    return null;
  }

  /// Membuat `WidgetBuilder` untuk halaman approval generik suatu master.
  static WidgetBuilder _buildApprovalRoute(String masterName) {
    return (context) => GenericApprovalPage(
      apiUrl: ApiConfig.approvalEndpoint(masterName),
      masterName: masterName,
      emptyMessage: _getEmptyMessage(),
      emptyIcon: _getEmptyIcon(),
    );
  }

  /// Mengembalikan pesan kosong default berdasarkan jenis master.
  static String _getEmptyMessage() {
        return 'Tidak ada request pending';
  }

  /// Mengembalikan ikon default berdasarkan jenis master.
  static IconData _getEmptyIcon() {
        return Icons.rule;
  }

  /// Mengecek apakah `menuLink` dapat di-resolve menjadi halaman valid.
  static bool hasRoute(String menuLink) {
    return resolveRoute(menuLink) != null;
  }
}
