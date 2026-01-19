import 'package:flutter/material.dart';
import 'dynamic_route_resolver.dart';

/// App Routes Registry
/// 100% Server-Driven Routing
/// Semua routes di-resolve secara dinamis dari menuLink yang dikirim server
/// Tidak ada hardcoded routes lagi - semua berdasarkan data dari server
class AppRoutes {
  /// Routes map - kosong karena semua di-resolve secara dinamis
  /// Routes akan di-resolve dari menuLink server menggunakan DynamicRouteResolver
  static final Map<String, WidgetBuilder> routes = {};

  /// Get route builder by route name (Server-Driven)
  /// Resolve route secara dinamis dari menuLink server
  /// Returns null if route not found
  static WidgetBuilder? getRoute(String routeName) {
    // Resolve route secara dinamis dari menuLink
    return DynamicRouteResolver.resolveRoute(routeName);
  }

  /// Check if route exists (Server-Driven)
  static bool hasRoute(String routeName) {
    return DynamicRouteResolver.hasRoute(routeName);
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

