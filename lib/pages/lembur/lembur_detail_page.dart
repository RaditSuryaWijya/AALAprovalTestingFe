import 'package:flutter/material.dart';
import '../../services/lembur_service.dart';
import '../../models/lembur_model.dart';
import '../../utils/date_helper.dart';
import '../../config/api_config.dart';
import '../pdf_viewer_page.dart';
import '../base/base_detail_page.dart';

class LemburDetailPage extends StatefulWidget {
  final int lemburId;

  const LemburDetailPage({super.key, required this.lemburId});

  @override
  State<LemburDetailPage> createState() => _LemburDetailPageState();
}

class _LemburDetailPageState extends BaseDetailPageState<LemburDetailPage> {
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

  // Implement abstract methods dari BaseDetailPageState
  @override
  bool get isLoading => _isLoading;

  @override
  bool get isNotFound => _lembur == null;

  @override
  String get pageTitle => 'Detail Lembur';

  @override
  Widget buildContent() {
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Card
        buildInfoCard(
          Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoRow('Tanggal',DateHelper.formatDateTime(_lembur!.tanggal) ),
              const Divider(),
              buildInfoRow('Requestor', _lembur!.requestorEmail),
              const Divider(),
              buildInfoRow('Status', _lembur!.status,valueColor: _getStatusColor(_lembur!.status)),
              const Divider(),
              buildInfoRow(
                'Keterangan',
                _lembur!.keterangan,
                isMultiline: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tombol untuk membuka PDF rekap master lembur
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              final pdfUrl = ApiConfig.exportMaster('lembur');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PdfViewerPage(
                    url: pdfUrl,
                    title: 'Laporan Lembur',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Lihat PDF'),
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

