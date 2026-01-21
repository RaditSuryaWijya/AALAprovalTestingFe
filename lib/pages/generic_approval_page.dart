import 'package:flutter/material.dart';
import '../controllers/dynamic_approval_controller.dart';
import '../controllers/approval_controller.dart';
import '../models/approval_item.dart';
import '../config/api_config.dart';
import '../components/approval_card.dart';
import 'pdf_viewer_page.dart';
import '../utils/date_helper.dart';

/// GenericApprovalPage
/// Halaman approval generik yang dapat bekerja dengan berbagai master
/// menggunakan DynamicApprovalController
class GenericApprovalPage extends StatefulWidget {
  /// URL API untuk load items
  final String apiUrl;

  /// Master name (untuk export PDF, dll)
  /// Contoh: 'cuti', 'lembur', 'po'
  final String masterName;

  /// Empty message custom (opsional)
  final String? emptyMessage;

  /// Empty icon custom (opsional)
  final IconData? emptyIcon;

  const GenericApprovalPage({
    super.key,
    required this.apiUrl,
    required this.masterName,
    this.emptyMessage,
    this.emptyIcon,
  });

  @override
  State<GenericApprovalPage> createState() => _GenericApprovalPageState();
}

class _GenericApprovalPageState extends State<GenericApprovalPage> {
  late ApprovalController _controller;
  List<ApprovalItem> _items = [];
  bool _isLoading = false;
  String? _pageTitle;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = DynamicApprovalController(
      apiUrl: widget.apiUrl,
      masterName: widget.masterName,
    );
    _loadItems();
  }

  /// Load items dari controller
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _controller.loadItems();
      final title = _controller.getPageTitle();

      setState(() {
        _items = items;
        _pageTitle = title;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle approve action
  Future<void> _handleApprove(ApprovalItem item) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final result = await _controller.approve(item.id);

    if (!mounted) return;

    // Handle 409 conflict
    if (result['conflict'] == true || result['statusCode'] == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sudah diproses, silakan refresh'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadItems(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? ''),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        _loadItems(); // Reload items setelah approve
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  /// Handle reject action
  Future<void> _handleReject(ApprovalItem item) async {
    if (_isSubmitting) return;
    // Show dialog untuk input reject reason
    final rejectReason = await showDialog<String>(
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

    if (rejectReason == null || rejectReason.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _controller.reject(item.id, rejectReason: rejectReason);

    if (!mounted) return;

    // Handle 409 conflict
    if (result['conflict'] == true || result['statusCode'] == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sudah diproses, silakan refresh'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadItems(); // refresh list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? ''),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        _loadItems(); // Reload items setelah reject
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  /// Handle detail action - buka PDF viewer
  void _handleDetail(ApprovalItem item) {
    final pdfUrl = ApiConfig.exportMasterById(widget.masterName, item.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          url: pdfUrl,
          title: 'Detail ${widget.masterName.toUpperCase()} #${item.id}',
        ),
      ),
    );
  }

  /// Build content untuk approval card
  Widget _buildCardContent(ApprovalItem item) {
    // Format date jika ada
    String? formattedDate;
    if (item.date != null && item.date!.isNotEmpty) {
      try {
        formattedDate = DateHelper.formatDateTime(item.date!);
      } catch (e) {
        formattedDate = item.date;
      }
    }

    // Split title dan subtitle untuk multiple lines jika panjang
    final titleParts = item.title.length > 30
        ? [
            item.title.substring(0, 30),
            item.title.substring(30),
          ]
        : [item.title];

    final subtitleParts = item.subtitle.length > 20
        ? [
            item.subtitle.substring(0, 20),
            item.subtitle.substring(20),
          ]
        : [item.subtitle];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        for (var part in titleParts)
          Text(
            part,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (titleParts.length > 1) const SizedBox(height: 4),
        // Subtitle
        for (var part in subtitleParts)
          Text(
            part,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        // Date jika ada
        if (formattedDate != null) ...[
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  /// Build approval card untuk item
  Widget _buildApprovalCard(ApprovalItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1.0),
      child: ApprovalCard(
        content: _buildCardContent(item),
        onApprove: () => _handleApprove(item),
        onReject: () => _handleReject(item),
        onDetail: () => _handleDetail(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _pageTitle ?? 'Approval ${widget.masterName}',
          style: const TextStyle(
            fontFamily: 'mgopenmodata',
          ),
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
        elevation: 0.0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.emptyIcon ?? Icons.rule,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.emptyMessage ?? 'Tidak ada request pending',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontFamily: 'mgopenmodata',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadItems,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontFamily: 'mgopenmodata'),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadItems,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return _buildApprovalCard(_items[index]);
                    },
                  ),
                ),
    );
  }
}
