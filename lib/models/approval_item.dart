/// Representasi satu baris data yang akan ditampilkan di kartu approval.
class ApprovalItem {
  final int id;
  final String title;
  final String subtitle;
  final String? date;
  final String? status;

  ApprovalItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.date,
    this.status,
  });

  /// Membuat `ApprovalItem` dari JSON mentah menggunakan konfigurasi mapping dinamis.
  factory ApprovalItem.fromJson(
    Map<String, dynamic> json,
    Map<String, String> mapping,
  ) {
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
    );
  }

  /// Mengubah `ApprovalItem` kembali ke bentuk map (berguna untuk logging/debug).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'date': date,
      'status': status,
    };
  }
}
