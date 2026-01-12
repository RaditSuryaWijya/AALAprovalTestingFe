import 'package:flutter/material.dart';
import '../../services/po_service.dart';
import '../../models/po_model.dart';
import '../../models/auth_user_model.dart';
import '../../services/auth_service.dart';
import 'po_detail_page.dart';
import '../../components/approval_card.dart';

class POApprovalPage extends StatefulWidget {
  const POApprovalPage({super.key});

  @override
  State<POApprovalPage> createState() => _POApprovalPageState();
}

class _POApprovalPageState extends State<POApprovalPage> {
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
      // Filter hanya PENDING untuk Manager
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
      // Remove any non-numeric characters except decimal point
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Approval PO',
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
          : _poList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada request PO pending',
                        style: TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadPO,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPO,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _poList.length,
                    itemBuilder: (context, index) {
                      final po = _poList[index];
                      return _buildPOCard(po);
                    },
                  ),
                ),
    );
  }

  Widget _buildPOCard(POModel po) {
    // Logic split dihapus

    return ApprovalCard(
      onApprove: () => _handleApprove(po, 'approve'),
      onReject: () => _handleApprove(po, 'reject'),
      onDetail: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PODetailPage(poId: po.id)),
        ).then((_) => _loadPO());
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Langsung tampilkan nama barang secara utuh
          Text(
            po.namaBarang,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500
            ),
            // Opsional: Agar tidak terlalu panjang ke bawah, bisa dibatasi
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Harga
          Text(
              '',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700)
          ),
          Text(
            _formatPrice(po.totalHarga),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
