import 'package:flutter/material.dart';
import '../controllers/dynamic_approval_controller.dart';
import '../controllers/approval_controller.dart';
import '../models/approval_item.dart';
import '../models/pagination_metadata.dart';
import '../config/api_config.dart';
import '../components/approval_card.dart';
import 'pdf_viewer_page.dart';
import '../utils/date_helper.dart';

/// Halaman approval generik yang menampilkan dan memproses daftar `ApprovalItem`
/// untuk berbagai master (lembur, cuti, po, dll) menggunakan `DynamicApprovalController`.
class GenericApprovalPage extends StatefulWidget {
  final String apiUrl;
  final String masterName;
  final String? emptyMessage;
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
  PaginationMetadata? _pagination;
  int _currentPage = 1;
  int _perPage = 10;

  /// Inisialisasi controller dan langsung memuat data awal.
  @override
  void initState() {
    super.initState();
    _controller = DynamicApprovalController(
      apiUrl: widget.apiUrl,
      masterName: widget.masterName,
    );
    _loadItems();
  }

  /// Memuat ulang daftar item approval dari API dengan pagination.
  Future<void> _loadItems({int? page}) async {
    if (page != null) {
      _currentPage = page;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _controller.loadItems(
        page: _currentPage,
        perPage: _perPage,
      );
      final title = _controller.getPageTitle();
      final pagination = _controller.getPagination();

      setState(() {
        _items = items;
        _pageTitle = title;
        _pagination = pagination;
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

  /// Handler untuk aksi approve pada satu item.
  Future<void> _handleApprove(ApprovalItem item) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final result = await _controller.approve(item.id);

    if (!mounted) return;

    if (result['conflict'] == true || result['statusCode'] == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sudah diproses, silakan refresh'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? ''),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        _loadItems();
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  /// Handler untuk aksi reject pada satu item, termasuk input alasan.
  Future<void> _handleReject(ApprovalItem item) async {
    if (_isSubmitting) return;
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

    if (result['conflict'] == true || result['statusCode'] == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sudah diproses, silakan refresh'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? ''),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        _loadItems();
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  /// Handler untuk membuka detail dalam bentuk PDF viewer.
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

  /// Membangun konten teks di dalam kartu approval untuk satu item.
  Widget _buildCardContent(ApprovalItem item) {
    String? formattedDate;
    if (item.date != null && item.date!.isNotEmpty) {
      try {
        formattedDate = DateHelper.formatDateTime(item.date!);
      } catch (e) {
        formattedDate = item.date;
      }
    }

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
                        onPressed: () => _loadItems(),
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
                  onRefresh: () => _loadItems(),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            return _buildApprovalCard(_items[index]);
                          },
                        ),
                      ),
                      if (_pagination != null) _buildPaginationControls(),
                    ],
                  ),
                ),
    );
  }

  /// Membangun kontrol pagination (tombol prev/next dan info halaman).
  Widget _buildPaginationControls() {
    final pagination = _pagination!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Halaman ${pagination.currentPage} dari ${pagination.lastPage}',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'mgopenmodata',
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: pagination.hasPreviousPage
                    ? () => _loadItems(page: pagination.currentPage - 1)
                    : null,
                tooltip: 'Halaman Sebelumnya',
              ),
              Text(
                '${pagination.from}-${pagination.to} dari ${pagination.total}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'mgopenmodata',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: pagination.hasNextPage
                    ? () => _loadItems(page: pagination.currentPage + 1)
                    : null,
                tooltip: 'Halaman Berikutnya',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
