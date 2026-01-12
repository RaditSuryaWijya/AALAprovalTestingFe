/// Route Manager - Helper untuk normalisasi route name
/// Tidak melakukan mapping widget, hanya helper untuk normalize menu_link
class RouteManager {
  /// Normalize menu_link menjadi route name yang konsisten
  /// - Convert to lowercase
  /// - Remove trailing slash
  /// - Handle dashboard case
  static String? normalizeRoute(String menuLink) {
    // Normalize menu link (lowercase, remove trailing slash)
    final normalizedLink = menuLink.toLowerCase().replaceAll(RegExp(r'/$'), '');

    // Jika dashboard atau empty, return null (tidak perlu navigate)
    if (normalizedLink == '/dashboard' || normalizedLink.isEmpty) {
      return null;
    }

    return normalizedLink;
  }

  /// Check if menu_link is valid for navigation
  /// Returns true if menu_link is not dashboard and not empty
  static bool isValidRoute(String menuLink) {
    final normalized = normalizeRoute(menuLink);
    return normalized != null;
  }
}

