import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../pages/pdf_viewer_page.dart';

/// Router untuk mengarahkan user berdasarkan payload notifikasi.
///
/// Backend mengirim data seperti:
/// { "type": "lembur_new|po_new|...", "id": 123 }
///
/// Ketika notifikasi diklik, akan navigasi langsung ke halaman detail (PDF) dari approval tersebut.
class NotificationRouter {
  static GlobalKey<NavigatorState>? navigatorKey;

  static void handleMessageData(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    if (type.isEmpty) return;

    final master = _masterFromType(type);
    if (master == null) return;

    // Ambil ID dari data notifikasi
    final idStr = data['id']?.toString();
    if (idStr == null || idStr.isEmpty) {
      // Jika tidak ada ID, arahkan ke halaman approval list
      _navigateToApprovalList(master);
      return;
    }

    final id = int.tryParse(idStr);
    if (id == null || id <= 0) {
      // ID tidak valid, arahkan ke halaman approval list
      _navigateToApprovalList(master);
      return;
    }

    // Navigasi langsung ke halaman detail (PDF) dari approval tersebut
    _navigateToDetail(master, id);
  }

  /// Navigasi ke halaman detail (PDF) dari approval
  static void _navigateToDetail(String master, int id) {
    final nav = navigatorKey?.currentState;
    if (nav == null) return;

    // Build PDF URL untuk detail approval
    final pdfUrl = ApiConfig.exportMasterById(master, id);

    // Selalu gunakan push agar ada halaman sebelumnya di stack (Dashboard),
    // sehingga AppBar otomatis menampilkan tombol back.
    nav.push(
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          url: pdfUrl,
          title: 'Detail ${master.toUpperCase()} #$id',
          masterName: master,
          id: id,
        ),
      ),
    );
  }

  /// Navigasi ke halaman approval list jika ID tidak tersedia
  static void _navigateToApprovalList(String master) {
    final route = '/$master/approval';
    final nav = navigatorKey?.currentState;
    if (nav == null) return;

    nav.pushNamed(route);
  }

  static void handlePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        handleMessageData(decoded);
      }
    } catch (_) {
      // Abaikan payload yang bukan JSON
    }
  }

  static String? _masterFromType(String type) {
    // Ambil prefix sebelum '_' (contoh: 'lembur_new' -> 'lembur')
    final parts = type.split('_');
    if (parts.isEmpty) return null;
    final master = parts[0].trim();
    if (master.isEmpty) return null;
    return master;
  }
}

