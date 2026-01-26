import 'dart:convert';
import 'package:flutter/material.dart';

/// Router untuk mengarahkan user berdasarkan payload notifikasi.
///
/// Backend mengirim data seperti:
/// { "type": "lembur_new|po_new|...", "id": 123 }
///
/// Karena app kita server-driven, kita navigasi pakai route string yang bisa
/// di-resolve oleh `DynamicRouteResolver` (mis. `/lembur/approval`).
class NotificationRouter {
  static GlobalKey<NavigatorState>? navigatorKey;

  static void handleMessageData(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    if (type.isEmpty) return;

    final master = _masterFromType(type);
    if (master == null) return;

    final route = '/$master/approval';
    final nav = navigatorKey?.currentState;
    if (nav == null) return;

    // Untuk sekarang kita arahkan ke halaman approval master terkait.
    // Kalau nanti ada halaman detail, bisa extend: '/$master/detail/$id' dsb.
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

