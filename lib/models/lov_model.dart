// Model untuk List of Values (LOV)
class LovModel {
  final String code; // Value yang akan disimpan
  final String description; // Label yang ditampilkan
  final dynamic data; // Data tambahan (optional)

  LovModel({
    required this.code,
    required this.description,
    this.data,
  });

  @override
  String toString() => description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LovModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

