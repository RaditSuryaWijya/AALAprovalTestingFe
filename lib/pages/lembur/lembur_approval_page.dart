import 'package:flutter/material.dart';
import '../../services/lembur_service.dart';
import '../../models/lembur_model.dart';
import '../../models/auth_user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/date_helper.dart';
import '../base/base_approval_page.dart';
import 'lembur_detail_page.dart';

class LemburApprovalPage extends StatefulWidget {
  const LemburApprovalPage({super.key});

  @override
  State<LemburApprovalPage> createState() => _LemburApprovalPageState();
}

class _LemburApprovalPageState extends BaseApprovalPageState<LemburApprovalPage> {
  List<LemburModel> _lemburList = [];
  bool _isLoading = false;
  AuthUserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserAndLembur();
  }

  Future<void> _loadUserAndLembur() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = await AuthService.getCurrentUser();
      final list = await LemburService.getAllLembur();

      if (_currentUser != null) {
        if (_currentUser!.isSupervisor) {
          list.removeWhere((item) => item.status != 'PENDING_SPV');
        } else if (_currentUser!.isManager) {
          list.removeWhere((item) => item.status != 'PENDING_MGR');
        }
      }

      setState(() {
        _lemburList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(LemburModel lembur, String action) async {
    String? rejectReason;

    if (action == 'reject') {
      final reason = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Reject Reason'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan reject',
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );

      if (reason == null || reason.trim().isEmpty) {
        return;
      }
      rejectReason = reason;
    }

    final isSupervisor = _currentUser?.isSupervisor ?? false;
    final result = isSupervisor
        ? await LemburService.approveSupervisor(
            id: lembur.id,
            action: action,
            rejectReason: rejectReason,
          )
        : await LemburService.approveManager(
            id: lembur.id,
            action: action,
            rejectReason: rejectReason,
          );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? ''),
          backgroundColor:
              result['success'] == true ? Colors.green : Colors.red,
        ),
      );
      _loadUserAndLembur();
    }
  }

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isEmpty => _lemburList.isEmpty;

  @override
  String get emptyMessage => 'Tidak ada request pending';

  @override
  IconData get emptyIcon => Icons.rule;

  @override
  String get pageTitle => 'Approval Lembur';

  @override
  Future<void> loadData() => _loadUserAndLembur();

  @override
  Widget buildCardItem(int index) {
    return _buildLemburCard(_lemburList[index]);
  }

  @override
  int get itemCount => _lemburList.length;

  Widget _buildLemburCard(LemburModel lembur) {
    final tanggalFormatted = DateHelper.formatDateTime(lembur.tanggal);
    final tanggalParts = tanggalFormatted.split(' ');

    final keteranganParts = lembur.keterangan.length > 20
        ? [
            lembur.keterangan.substring(0, 20),
            lembur.keterangan.substring(20)
          ]
        : [lembur.keterangan];

    final content = Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time,
            color: Colors.orange.shade700,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var part in tanggalParts)
                Text(
                  part,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 4),
              for (var part in keteranganParts)
                Text(
                  part,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return buildApprovalCard(
      content: content,
      onApprove: () => _handleApprove(lembur, 'approve'),
      onReject: () => _handleApprove(lembur, 'reject'),
      onDetail: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LemburDetailPage(lemburId: lembur.id),
          ),
        ).then((_) => _loadUserAndLembur());
      },
    );
  }
}
