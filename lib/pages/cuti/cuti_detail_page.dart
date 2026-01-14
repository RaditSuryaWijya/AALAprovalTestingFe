import 'package:flutter/material.dart';
import '../../services/cuti_service.dart';
import '../../models/cuti_model.dart';
import '../../utils/date_helper.dart';
import '../base/base_detail_page.dart';

class CutiDetailPage extends StatefulWidget {
  final int cutiId;

  const CutiDetailPage({super.key, required this.cutiId});

  @override
  State<CutiDetailPage> createState() => _CutiDetailPageState();
}

class _CutiDetailPageState extends BaseDetailPageState<CutiDetailPage> {
  CutiModel? _cuti;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final cuti = await CutiService.getcutiById(widget.cutiId);
      setState(() {
        _cuti = cuti;
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

  // Implement abstract methods dari BaseDetailPageState
  @override
  bool get isLoading => _isLoading;

  @override
  bool get isNotFound => _cuti == null;

  @override
  String get pageTitle => 'Detail cuti';

  @override
  Widget buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Badge
        buildStatusChip(_cuti!.status, _getStatusColor(_cuti!.status)),
        const SizedBox(height: 24),

        // Info Card
        buildInfoCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoRow('Tanggal', _cuti!.tanggal),
              const Divider(),
              buildInfoRow('Requestor', _cuti!.requestorEmail),
              const Divider(),
              buildInfoRow(
                'Keterangan',
                _cuti!.keterangan,
                isMultiline: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Timeline Card
        buildInfoCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitle('Timeline Approval'),
              const SizedBox(height: 16),
              _buildTimelineItem(
                'Request dibuat',
                _cuti!.requestorEmail,
                _cuti!.createdAt,
                true,
              ),
              if (_cuti!.spvEmail != null)
                _buildTimelineItem(
                  'Supervisor Approve',
                  _cuti!.spvEmail!,
                  _cuti!.tglApproveSpv ?? '',
                  true,
                ),
              if (_cuti!.mgrEmail != null)
                _buildTimelineItem(
                  'Manager Approve',
                  _cuti!.mgrEmail!,
                  _cuti!.tglApproveMgr ?? '',
                  true,
                ),
              if (_cuti!.rejectReason != null)
                _buildTimelineItem(
                  'Reject Reason',
                  _cuti!.rejectReason!,
                  '',
                  false,
                  isReject: true,
                ),
            ],
          ),
        ),
      ],
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

