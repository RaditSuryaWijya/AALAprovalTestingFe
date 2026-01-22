class ApiConfig {
  static const String baseUrl = "https://4e46560e2f35.ngrok-free.app/api";

  // Authentication Endpoints
  static const String login = "$baseUrl/login";
  static const String logout = "$baseUrl/logout";
  static const String me = "$baseUrl/me";
  static const String menus = "$baseUrl/menu";

  // Endpoint Users
  static const String users = "$baseUrl/users";
  // Export PDF by ID
  static String exportMasterById(String master, int id) => "$baseUrl/export/$master/$id";
  // Dynamic Approval Endpoints
  static String approvalEndpoint(String master) => "$baseUrl/$master";
}