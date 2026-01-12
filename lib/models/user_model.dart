class UserModel {
  final String id;
  final String name;
  final String avatar;
  final String? createdAt; // Bisa null

  UserModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.createdAt, // Optional karena bisa null
  });

  // Factory constructor untuk membuat UserModel dari JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(), // Bisa null
    );
  }

  // Method untuk mengkonversi UserModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'createdAt': createdAt,
    };
  }

  // Method untuk membuat copy dengan beberapa field yang diubah
  UserModel copyWith({
    String? id,
    String? name,
    String? avatar,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

