/// Model untuk item approval yang digunakan di GenericApprovalPage
/// Model ini menyimpan data yang akan ditampilkan di card approval
class ApprovalItem {
  /// ID unik dari item (untuk approve/reject/detail)
  final int id;

  /// Judul utama yang ditampilkan di card
  final String title;

  /// Subtitle/deskripsi yang ditampilkan di card
  final String subtitle;

  /// Tanggal/keterangan waktu (opsional)
  final String? date;

  /// Status approval (PENDING, APPROVED, REJECTED, dll)
  final String? status;

  /// Data mentah dari JSON (untuk keperluan tambahan jika diperlukan)
  final Map<String, dynamic>? rawData;

  ApprovalItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.date,
    this.status,
    this.rawData,
  });

  /// Factory constructor untuk membuat ApprovalItem dari JSON
  /// Menggunakan mapping dinamis dari config
  factory ApprovalItem.fromJson(
    Map<String, dynamic> json,
    Map<String, String> mapping,
  ) {
    // Helper function untuk mendapatkan value dari JSON berdasarkan key mapping
    String? getMappedValue(String key) {
      final fieldName = mapping[key];
      if (fieldName == null) return null;
      return json[fieldName]?.toString();
    }

    return ApprovalItem(
      id: json['id'] ?? 0,
      title: getMappedValue('title') ?? '',
      subtitle: getMappedValue('subtitle') ?? '',
      date: getMappedValue('date'),
      status: getMappedValue('status'),
      rawData: json,
    );
  }

  /// Convert ke JSON (untuk debugging atau keperluan lain)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'date': date,
      'status': status,
      'rawData': rawData,
    };
  }
}
