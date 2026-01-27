import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../controllers/dynamic_approval_controller.dart';
import '../config/api_config.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;
  final String? masterName;
  final int? id;

  const PdfViewerPage({
    super.key,
    required this.url,
    required this.title,
    this.masterName,
    this.id,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isSubmitting = false;
  DynamicApprovalController? _controller;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller jika masterName dan id tersedia
    if (widget.masterName != null && widget.id != null) {
      _controller = DynamicApprovalController(
        apiUrl: ApiConfig.approvalEndpoint(widget.masterName!),
        masterName: widget.masterName!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showActionButtons = widget.masterName != null && widget.id != null && _controller != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
      ),
      body: PDF(
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
      ).fromUrl(
        widget.url,
        placeholder: (progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(
                '$progress %',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        errorWidget: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                "Gagal memuat PDF: $error",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showActionButtons
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleReject,
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text(
                          'REJECT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'mgopenmodata',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleApprove,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'APPROVE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'mgopenmodata',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  /// Handler untuk aksi approve
  Future<void> _handleApprove() async {
    if (_isSubmitting || _controller == null || widget.id == null) return;

    // Konfirmasi approve
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Approve'),
        content: const Text('Apakah Anda yakin ingin approve request ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSubmitting = true;
    });

    final result = await _controller!.approve(widget.id!);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result['conflict'] == true || result['statusCode'] == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sudah diproses, silakan refresh'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? ''),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        // Kembali ke halaman sebelumnya setelah approve berhasil
        Navigator.pop(context);
      }
    }
  }

  /// Handler untuk aksi reject dengan input alasan
  Future<void> _handleReject() async {
    if (_isSubmitting || _controller == null || widget.id == null) return;

    // Dialog untuk input alasan reject
    final rejectReason = await showDialog<String>(
      context: context,
      builder: (context) {
        String reason = '';
        return AlertDialog(
          title: const Text('Reject Request'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Masukkan alasan reject:'),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => reason = value,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Alasan reject...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reason.trim().isNotEmpty) {
                  Navigator.pop(context, reason.trim());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (rejectReason == null || rejectReason.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final result = await _controller!.reject(widget.id!, rejectReason: rejectReason);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result['conflict'] == true || result['statusCode'] == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sudah diproses, silakan refresh'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? ''),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        // Kembali ke halaman sebelumnya setelah reject berhasil
        Navigator.pop(context);
      }
    }
  }
}