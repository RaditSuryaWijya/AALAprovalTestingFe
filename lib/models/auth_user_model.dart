class AuthUserModel {
  final int id;
  final String name;
  final String email;
  final String jabatan;
  final String department;

  AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.jabatan,
    required this.department,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      jabatan: json['jabatan']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'jabatan': jabatan,
      'department': department,
    };
  }

  // Helper untuk cek role
  bool get isStaff => jabatan.toUpperCase() == 'STAFF';
  bool get isSupervisor => jabatan.toUpperCase() == 'SUPERVISOR';
  bool get isManager => jabatan.toUpperCase() == 'MANAGER';
}

