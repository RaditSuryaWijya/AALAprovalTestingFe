class ApprovalModel {
  final String approvalId;
  final String appId;
  final String statusApproval;
  final String deskripsi;

  ApprovalModel({
    required this.approvalId,
    required this.appId,
    required this.statusApproval,
    required this.deskripsi,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      approvalId: json['approval_id']?.toString() ?? '',
      appId: json['app_id']?.toString() ?? '',
      statusApproval: json['status_approval']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'approval_id': approvalId,
      'app_id': appId,
      'status_approval': statusApproval,
      'deskripsi': deskripsi,
    };
  }
}


