import 'package:flutter/material.dart';

class ApprovalCard extends StatelessWidget {
  /// Konten utama di bagian tengah (Teks nama, harga, tanggal, dll)
  final Widget content;

  /// Fungsi ketika tombol Check (Hijau) ditekan
  final VoidCallback onApprove;

  /// Fungsi ketika tombol Silang (Merah) ditekan
  final VoidCallback onReject;

  /// Fungsi ketika tombol Info (Biru) ditekan
  final VoidCallback onDetail;

  const ApprovalCard({
    super.key,
    required this.content,
    required this.onApprove,
    required this.onReject,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Card(
        color: Colors.grey.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spacer kiri (bisa diganti leading icon jika ada)
              const SizedBox(width: 16),

              // Bagian Tengah (Dinamis)
              Expanded(child: content),

              const SizedBox(width: 16),

              // Bagian Kanan (Tombol Aksi Tetap)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleButton(
                    color: Colors.green,
                    icon: Icons.check,
                    onTap: onApprove,
                    tooltip: 'Approve',
                  ),
                  const SizedBox(height: 8),
                  _buildCircleButton(
                    color: Colors.red,
                    icon: Icons.close,
                    onTap: onReject,
                    tooltip: 'Reject',
                  ),
                  const SizedBox(height: 8),
                  _buildCircleButton(
                    color: Colors.blue,
                    icon: Icons.info,
                    onTap: onDetail,
                    tooltip: 'Detail',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
        tooltip: tooltip,
      ),
    );
  }
}