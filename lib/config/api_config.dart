class ApiConfig {
  // // Base URL
  // static const String baseUrl = "http://192.168.1.10:8000/api";
  //
  // // Endpoints
  // static const String login = "$baseUrl/login";
  // static const String register = "$baseUrl/register";
  // static const String getProducts = "$baseUrl/products";
  // static const String updateProfile = "$baseUrl/profile/update";



  static const String baseUrl = "https://731541df18f8.ngrok-free.app/api";

  // Authentication Endpoints
  static const String login = "$baseUrl/login";
  static const String logout = "$baseUrl/logout";
  static const String me = "$baseUrl/me";
  static const String menus = "$baseUrl/menu"; // Get dynamic menus

  // Lembur Endpoints
  static const String lembur = "$baseUrl/lembur";
  static String lemburDetail(int id) => "$lembur/$id";
  static String lemburApproveSupervisor(int id) => "$lembur/$id/approve-supervisor";
  static String lemburApproveManager(int id) => "$lembur/$id/approve-manager";

  // PO Endpoints
  static const String po = "$baseUrl/po";
  static String poDetail(int id) => "$po/$id";
  static String poApprove(int id) => "$po/$id/approve";

  // Endpoint Users (legacy - bisa dihapus jika tidak digunakan)
  static const String users = "$baseUrl/users";

  // Endpoint Master Approval (legacy - bisa dihapus jika tidak digunakan)
  static const String approvals = "$baseUrl/master-approvals";
}