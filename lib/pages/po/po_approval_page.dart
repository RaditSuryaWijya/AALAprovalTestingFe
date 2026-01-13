import 'package:flutter/material.dart';
import '../../services/po_service.dart';
import '../../models/po_model.dart';
import '../base/base_approval_page.dart';
import 'po_detail_page.dart';

class POApprovalPage extends StatefulWidget {
  const POApprovalPage({super.key});

  @override
  State<POApprovalPage> createState() => _POApprovalPageState();
}

class _POApprovalPageState extends BaseApprovalPageState<POApprovalPage> {
  List<POModel> _poList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPO();
  }

  Future<void> _loadPO() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await POService.getAllPO();
      list.removeWhere((item) => item.status != 'PENDING');

      setState(() {
        _poList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(POModel po, String action) async {
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

    final result = await POService.approvePO(
      id: po.id,
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
      _loadPO();
    }
  }

  String _formatPrice(String priceString) {
    try {
      final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.parse(cleanPrice);
      return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    } catch (e) {
      return 'Rp $priceString';
    }
  }

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isEmpty => _poList.isEmpty;

  @override
  String get emptyMessage => 'Tidak ada request PO pending';

  @override
  IconData get emptyIcon => Icons.shopping_cart;

  @override
  String get pageTitle => 'Approval PO';

  @override
  Future<void> loadData() => _loadPO();

  @override
  Widget buildCardItem(int index) {
    return _buildPOCard(_poList[index]);
  }

  @override
  int get itemCount => _poList.length;

  Widget _buildPOCard(POModel po) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          po.namaBarang,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Harga
        Text(
          _formatPrice(po.totalHarga),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    return buildApprovalCard(
      content: content,
      onApprove: () => _handleApprove(po, 'approve'),
      onReject: () => _handleApprove(po, 'reject'),
      onDetail: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PODetailPage(poId: po.id),
          ),
        ).then((_) => _loadPO());
      },
    );
  }
}
