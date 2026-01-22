import 'package:flutter/material.dart';
import 'dynamic_route_resolver.dart';

/// Gerbang utama untuk named routes.
/// Saat ini semua route di-resolve secara dinamis lewat `DynamicRouteResolver`.
class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {};
  static WidgetBuilder? getRoute(String routeName) {
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

