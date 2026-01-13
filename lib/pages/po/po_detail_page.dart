import 'package:flutter/material.dart';
import '../../services/po_service.dart';
import '../../models/po_model.dart';
import '../../utils/date_helper.dart';
import '../base/base_detail_page.dart';

class PODetailPage extends StatefulWidget {
  final int poId;

  const PODetailPage({super.key, required this.poId});

  @override
  State<PODetailPage> createState() => _PODetailPageState();
}

class _PODetailPageState extends BaseDetailPageState<PODetailPage> {
  POModel? _po;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final po = await POService.getPOById(widget.poId);
      setState(() {
        _po = po;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isNotFound => _po == null;

  @override
  String get pageTitle => 'Detail PO';

  @override
  Widget buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildStatusChip(_po!.status, _getStatusColor(_po!.status)),
        const SizedBox(height: 24),

        buildInfoCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoRow('Nama Barang', _po!.namaBarang),
              const Divider(),
              buildInfoRow('Total Harga', _po!.formattedHarga),
              const Divider(),
              buildInfoRow('Creator', _po!.creatorEmail),
              if (_po!.approverEmail != null) ...[
                const Divider(),
                buildInfoRow('Approver', _po!.approverEmail!),
              ],
              if (_po!.tglApprove != null) ...[
                const Divider(),
                buildInfoRow('Tanggal Approve', _po!.tglApprove!),
              ],
              if (_po!.rejectReason != null) ...[
                const Divider(),
                buildInfoRow(
                  'Reject Reason',
                  _po!.rejectReason!,
                  isReject: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

