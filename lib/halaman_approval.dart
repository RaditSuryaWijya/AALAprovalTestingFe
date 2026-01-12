import 'package:flutter/material.dart';

import 'models/approval_model.dart';
import 'services/approval_service.dart';

class HalamanApproval extends StatefulWidget {
  const HalamanApproval({super.key});

  @override
  State<HalamanApproval> createState() => _HalamanApprovalState();
}

class _HalamanApprovalState extends State<HalamanApproval> {
  List<ApprovalModel> approvals = [];
  bool isLoading = false;
  String? errorMessage;
  String? _statusUpdatingId; // menandai approval yang sedang di-update

  @override
  void initState() {
    super.initState();
    loadApprovals();
  }

  Future<void> loadApprovals() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetched = await ApprovalService.getAllApprovals();
      setState(() {
        approvals = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.grey;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _setStatusForApproval(
    ApprovalModel approval,
    String newStatus,
  ) async {
    setState(() {
      _statusUpdatingId = approval.approvalId;
    });

    try {
      final updated = await ApprovalService.setStatus(
        approvalId: approval.approvalId,
        statusApproval: newStatus,
      );

      if (updated != null) {
        // Update list di memory tanpa reload semua list
        setState(() {
          final index = approvals.indexWhere(
              (item) => item.approvalId == approval.approvalId);
          if (index != -1) {
            approvals[index] = updated;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Status ${approval.approvalId} diubah ke $newStatus',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengubah status approval'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setStatus: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _statusUpdatingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadApprovals,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (approvals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rule_folder_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Belum ada master approval',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: loadApprovals,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadApprovals,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: approvals.length,
        itemBuilder: (context, index) {
          final approval = approvals[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _statusColor(approval.statusApproval),
                child: Text(
                  approval.approvalId.isNotEmpty
                      ? approval.approvalId.substring(0, 1)
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                approval.approvalId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App ID: ${approval.appId}'),
                  Text(
                    'Status: ${approval.statusApproval}',
                    style: TextStyle(
                      color: _statusColor(approval.statusApproval),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    approval.deskripsi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                icon: _statusUpdatingId == approval.approvalId
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value != approval.statusApproval) {
                    _setStatusForApproval(approval, value);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'ACTIVE',
                    child: Text('Set ACTIVE'),
                  ),
                  PopupMenuItem(
                    value: 'INACTIVE',
                    child: Text('Set INACTIVE'),
                  ),
                  PopupMenuItem(
                    value: 'PENDING',
                    child: Text('Set PENDING'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


