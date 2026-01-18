class ApiConfig {
  static const String baseUrl = "https://f142c7975105.ngrok-free.app/api";

  // Authentication Endpoints
  static const String login = "$baseUrl/login";
  static const String logout = "$baseUrl/logout";
  static const String me = "$baseUrl/me";
  static const String menus = "$baseUrl/menu";

  // Lembur Endpoints
  static const String lembur = "$baseUrl/lembur";
  static String lemburDetail(int id) => "$lembur/$id";
  static String lemburApproveSupervisor(int id) => "$lembur/$id/approve-supervisor";
  static String lemburApproveManager(int id) => "$lembur/$id/approve-manager";

  // Lembur Cuti
  static const String cuti = "$baseUrl/cuti";
  static String cutiDetail(int id) => "$cuti/$id";
  static String cutiApproveSupervisor(int id) => "$cuti/$id/approve-supervisor";
  static String cutiApproveManager(int id) => "$cuti/$id/approve-manager";

  // PO Endpoints
  static const String po = "$baseUrl/po";
  static String poDetail(int id) => "$po/$id";
  static String poApprove(int id) => "$po/$id/approve";

  // Endpoint Users (legacy - bisa dihapus jika tidak digunakan)
  static const String users = "$baseUrl/users";

  // Endpoint Master Approval (legacy - bisa dihapus jika tidak digunakan)
  static const String approvals = "$baseUrl/master-approvals";

  // Export PDF generik per master (misal: users, cuti, lembur, po)
  static String exportMaster(String master) => "$baseUrl/export/$master";
}