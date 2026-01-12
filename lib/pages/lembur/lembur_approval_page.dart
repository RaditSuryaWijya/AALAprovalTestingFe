  import 'package:flutter/material.dart';
  import '../../services/lembur_service.dart';
  import '../../models/lembur_model.dart';
  import '../../models/auth_user_model.dart';
  import '../../services/auth_service.dart';
  import '../../utils/date_helper.dart';
  import 'lembur_detail_page.dart';
  import '../../components/approval_card.dart';
  
  class LemburApprovalPage extends StatefulWidget {
    const LemburApprovalPage({super.key});
  
    @override
    State<LemburApprovalPage> createState() => _LemburApprovalPageState();
  }
  
  class _LemburApprovalPageState extends State<LemburApprovalPage> {
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
  
        // Filter berdasarkan role
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
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Approval Lembur',
            style: TextStyle(
              fontFamily: 'mgopenmodata',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _lemburList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rule, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada request pending',
                          style: TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadUserAndLembur,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUserAndLembur,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _lemburList.length,
                      itemBuilder: (context, index) {
                        final lembur = _lemburList[index];
                        return _buildLemburCard(lembur);
                      },
                    ),
                  ),
      );
    }

    Widget _buildLemburCard(LemburModel lembur) {
      // Logic formatting tetap di sini
      final tanggalFormatted = DateHelper.formatDateTime(lembur.tanggal);
      final tanggalParts = tanggalFormatted.split(' ');

      final keteranganParts = lembur.keterangan.length > 20
          ? [lembur.keterangan.substring(0, 20), lembur.keterangan.substring(20)]
          : [lembur.keterangan];

      return ApprovalCard(
        // 1. Tentukan aksi
        onApprove: () => _handleApprove(lembur, 'approve'),
        onReject: () => _handleApprove(lembur, 'reject'),
        onDetail: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LemburDetailPage(lemburId: lembur.id)),
          ).then((_) => _loadUserAndLembur());
        },
        // 2. Susun konten tengah secara custom
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanggal
            for (var part in tanggalParts)
              Text(
                part,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 4),
            // Keterangan
            for (var part in keteranganParts)
              Text(
                part,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
          ],
        ),
      );
    }
  }
