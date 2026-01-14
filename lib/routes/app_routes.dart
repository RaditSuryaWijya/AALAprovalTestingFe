import 'package:flutter/material.dart';
import '../pages/lembur/lembur_list_page.dart';
import '../pages/lembur/lembur_create_page.dart';
import '../pages/lembur/lembur_approval_page.dart';
import '../pages/po/po_list_page.dart';
import '../pages/po/po_create_page.dart';
import '../pages/po/po_approval_page.dart';

import '../pages/cuti/cuti_list_page.dart';
import '../pages/cuti/cuti_approval_page.dart';
import '../pages/cuti/cuti_detail_page.dart';

/// App Routes Registry
/// Semua routes didefinisikan di sini sebagai Map<String, WidgetBuilder>
/// Backend mengirim menu_link yang sesuai dengan key di routes map ini
class AppRoutes {
  // Routes map - key adalah route name, value adalah WidgetBuilder
  static final Map<String, WidgetBuilder> routes = {
    // Lembur routes
    '/lembur': (context) => const LemburListPage(),
    '/lembur/list': (context) => const LemburListPage(),
    '/lembur/create': (context) => const LemburCreatePage(),
    '/lembur/approval': (context) => const LemburApprovalPage(),
    '/lembur/approve': (context) => const LemburApprovalPage(),

    // PO routes
    '/po': (context) => const POListPage(),
    '/po/list': (context) => const POListPage(),
    '/po/create': (context) => const POCreatePage(),
    '/po/approval': (context) => const POApprovalPage(),
    '/po/approve': (context) => const POApprovalPage(),

    // cuti routes
    '/cuti': (context) => const cutiListPage(),
    '/cuti/list': (context) => const cutiListPage(),
    '/cuti/approval': (context) => const cutiApprovalPage(),
    '/cuti/approve': (context) => const cutiApprovalPage(),
  };

  /// Get route builder by route name
  /// Returns null if route not found
  static WidgetBuilder? getRoute(String routeName) {
    // Normalize route name
    final normalizedRoute = _normalizeRoute(routeName);
    return routes[normalizedRoute];
  }

  /// Check if route exists
  static bool hasRoute(String routeName) {
    final normalizedRoute = _normalizeRoute(routeName);
    return routes.containsKey(normalizedRoute);
  }

  /// Normalize route name (lowercase, remove trailing slash)
  static String _normalizeRoute(String route) {
    return route.toLowerCase().replaceAll(RegExp(r'/$'), '');
  }

  /// Register new route dynamically (untuk extensibility)
  static void registerRoute(String routeName, WidgetBuilder builder) {
    final normalizedRoute = _normalizeRoute(routeName);
    routes[normalizedRoute] = builder;
  }

  /// Register multiple routes at once
  static void registerRoutes(Map<String, WidgetBuilder> newRoutes) {
    newRoutes.forEach((key, value) {
      final normalizedRoute = _normalizeRoute(key);
      routes[normalizedRoute] = value;
    });
  }
}

