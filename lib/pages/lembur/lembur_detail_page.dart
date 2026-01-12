import 'package:flutter/material.dart';
import '../../services/lembur_service.dart';
import '../../models/lembur_model.dart';
import '../../utils/date_helper.dart';

class LemburDetailPage extends StatefulWidget {
  final int lemburId;

  const LemburDetailPage({super.key, required this.lemburId});

  @override
  State<LemburDetailPage> createState() => _LemburDetailPageState();
}

class _LemburDetailPageState extends State<LemburDetailPage> {
  LemburModel? _lembur;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final lembur = await LemburService.getLemburById(widget.lemburId);
      setState(() {
        _lembur = lembur;
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
      case 'PENDING_SPV':
        return Colors.orange;
      case 'PENDING_MGR':
        return Colors.blue;
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

    if (_lembur == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Lembur')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        title: const Text('Detail Lembur'),
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Status Badge
            Center(
              child: Chip(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                label: Text(
                  _lembur!.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(_lembur!.status),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Tanggal', _lembur!.tanggal),
                    const Divider(),
                    _buildInfoRow('Requestor', _lembur!.requestorEmail),
                    const Divider(),
                    _buildInfoRow(
                      'Keterangan',
                      _lembur!.keterangan,
                      isMultiline: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Timeline Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timeline Approval',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineItem(
                      'Request dibuat',
                      _lembur!.requestorEmail,
                      _lembur!.createdAt,
                      true,
                    ),
                    if (_lembur!.spvEmail != null)
                      _buildTimelineItem(
                        'Supervisor Approve',
                        _lembur!.spvEmail!,
                        _lembur!.tglApproveSpv ?? '',
                        true,
                      ),
                    if (_lembur!.mgrEmail != null)
                      _buildTimelineItem(
                        'Manager Approve',
                        _lembur!.mgrEmail!,
                        _lembur!.tglApproveMgr ?? '',
                        true,
                      ),
                    if (_lembur!.rejectReason != null)
                      _buildTimelineItem(
                        'Reject Reason',
                        _lembur!.rejectReason!,
                        '',
                        false,
                        isReject: true,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
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
              fontWeight: isMultiline ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    String date,
    bool isCompleted, {
    bool isReject = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompleted
                ? (isReject ? Icons.cancel : Icons.check_circle)
                : Icons.radio_button_unchecked,
            color: isReject
                ? Colors.red
                : (isCompleted ? Colors.green : Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

