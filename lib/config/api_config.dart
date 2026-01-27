class ApiConfig {
  static const String baseUrl = "https://c0e9630deffd.ngrok-free.app/api";

  /// Versi aplikasi client untuk tracking di activity logs
  static const String clientVersion = "1.0.0";

  // Authentication Endpoints
  static const String login = "$baseUrl/login";
  static const String logout = "$baseUrl/logout";
  static const String me = "$baseUrl/me";
  static const String menus = "$baseUrl/menu";
  // FCM Token
  static const String saveFcmToken = "$baseUrl/fcm-token";
  // Export PDF
  static String exportMasterById(String master, int id) => "$baseUrl/export/$master/$id";
  // Dynamic Approval Endpoints
  static String approvalEndpoint(String master) => "$baseUrl/$master";
}