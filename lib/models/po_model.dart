class POModel {
  final int id;
  final String creatorEmail;
  final String namaBarang;
  final String totalHarga;
  final String status;
  final String? approverEmail;
  final String? tglApprove;
  final String? rejectReason;
  final String createdAt;
  final String updatedAt;

  POModel({
    required this.id,
    required this.creatorEmail,
    required this.namaBarang,
    required this.totalHarga,
    required this.status,
    this.approverEmail,
    this.tglApprove,
    this.rejectReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory POModel.fromJson(Map<String, dynamic> json) {
    return POModel(
      id: json['id'] ?? 0,
      creatorEmail: json['creator_email']?.toString() ?? '',
      namaBarang: json['nama_barang']?.toString() ?? '',
      totalHarga: json['total_harga']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      approverEmail: json['approver_email']?.toString(),
      tglApprove: json['tgl_approve']?.toString(),
      rejectReason: json['reject_reason']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_email': creatorEmail,
      'nama_barang': namaBarang,
      'total_harga': totalHarga,
      'status': status,
      'approver_email': approverEmail,
      'tgl_approve': tglApprove,
      'reject_reason': rejectReason,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper untuk status
  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  // Format currency
  String get formattedHarga {
    try {
      final harga = double.parse(totalHarga);
      return 'Rp ${harga.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    } catch (e) {
      return totalHarga;
    }
  }
}

