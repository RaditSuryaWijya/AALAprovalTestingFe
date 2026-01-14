class CutiModel {
  final int id;
  final String requestorEmail;
  final String tanggal;
  final String keterangan;
  final String status;
  final String? spvEmail;
  final String? tglApproveSpv;
  final String? mgrEmail;
  final String? tglApproveMgr;
  final String? rejectReason;
  final String createdAt;
  final String updatedAt;

  CutiModel({
    required this.id,
    required this.requestorEmail,
    required this.tanggal,
    required this.keterangan,
    required this.status,
    this.spvEmail,
    this.tglApproveSpv,
    this.mgrEmail,
    this.tglApproveMgr,
    this.rejectReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CutiModel.fromJson(Map<String, dynamic> json) {
    return CutiModel(
      id: json['id'] ?? 0,
      requestorEmail: json['requestor_email']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      spvEmail: json['spv_email']?.toString(),
      tglApproveSpv: json['tgl_approve_spv']?.toString(),
      mgrEmail: json['mgr_email']?.toString(),
      tglApproveMgr: json['tgl_approve_mgr']?.toString(),
      rejectReason: json['reject_reason']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestor_email': requestorEmail,
      'tanggal': tanggal,
      'keterangan': keterangan,
      'status': status,
      'spv_email': spvEmail,
      'tgl_approve_spv': tglApproveSpv,
      'mgr_email': mgrEmail,
      'tgl_approve_mgr': tglApproveMgr,
      'reject_reason': rejectReason,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper untuk status
  bool get isPendingSpv => status == 'PENDING_SPV';
  bool get isPendingMgr => status == 'PENDING_MGR';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
}

