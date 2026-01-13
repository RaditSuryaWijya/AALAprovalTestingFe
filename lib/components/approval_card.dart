import 'package:flutter/material.dart';

class ApprovalCard extends StatelessWidget {
  final Widget content;
  final VoidCallback onApprove;
  final VoidCallback onReject;
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
    return Card(
        color: Colors.grey.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 5),
              Expanded(child: content),
              const SizedBox(width: 16),
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