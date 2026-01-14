import 'package:flutter/material.dart';
import '../../services/cuti_service.dart';
import '../../models/cuti_model.dart';
import '../../utils/date_helper.dart';
import 'cuti_detail_page.dart';

class cutiListPage extends StatefulWidget {
  const cutiListPage({super.key});

  @override
  State<cutiListPage> createState() => _cutiListPageState();
}

class _cutiListPageState extends State<cutiListPage> {
  List<CutiModel> _cutiList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadcuti();
  }

  Future<void> _loadcuti() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await CutiService.getAllcuti();
      setState(() {
        _cutiList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('cuti Saya'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : _cutiList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Belum ada request cuti', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadcuti,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadcuti,
        backgroundColor: Colors.white,
        color: Colors.black,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _cutiList.length,
          itemBuilder: (context, index) {
            final cuti = _cutiList[index];
            return _buildcutiCard(cuti);
          },
        ),
      ),
    );
  }

  Widget _buildcutiCard(CutiModel cuti) {
    // Format tanggal
    final tanggalFormatted = DateHelper.formatDateTime(cuti.tanggal);
    final tanggalParts = tanggalFormatted.split(' ');

    // Split keterangan jika panjang
    final keteranganParts = cuti.keterangan.length > 20
        ? [
      cuti.keterangan.substring(0, 20),
      cuti.keterangan.substring(20)
    ]
        : [cuti.keterangan];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon di lingkaran putih
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
              // Informasi di tengah
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal (multiple lines)
                    for (var part in tanggalParts)
                      Text(
                        part,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Keterangan (multiple lines)
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
              // Tombol aksi di kanan
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkmark hijau
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CutiDetailPage(cutiId: cuti.id),
                          ),
                        ).then((_) => _loadcuti());
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // X merah
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CutiDetailPage(cutiId: cuti.id),
                          ),
                        ).then((_) => _loadcuti());
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Info icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CutiDetailPage(cutiId: cuti.id),
                          ),
                        ).then((_) => _loadcuti());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
