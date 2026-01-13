import 'package:flutter/material.dart';
import '../../services/po_service.dart';
import '../../models/po_model.dart';
import '../../utils/date_helper.dart';

class PODetailPage extends StatefulWidget {
  final int poId;

  const PODetailPage({super.key, required this.poId});

  @override
  State<PODetailPage> createState() => _PODetailPageState();
}

class _PODetailPageState extends State<PODetailPage> {
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_po == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail PO')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail PO'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Center(
              child: Chip(
                label: Text(
                  _po!.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(_po!.status),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nama Barang', _po!.namaBarang),
                    const Divider(),
                    _buildInfoRow('Total Harga', _po!.formattedHarga),
                    const Divider(),
                    _buildInfoRow('Creator', _po!.creatorEmail),
                    if (_po!.approverEmail != null) ...[
                      const Divider(),
                      _buildInfoRow('Approver', _po!.approverEmail!),
                    ],
                    if (_po!.tglApprove != null) ...[
                      const Divider(),
                      _buildInfoRow('Tanggal Approve', _po!.tglApprove!),
                    ],
                    if (_po!.rejectReason != null) ...[
                      const Divider(),
                      _buildInfoRow(
                        'Reject Reason',
                        _po!.rejectReason!,
                        isReject: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isReject = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isReject ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

