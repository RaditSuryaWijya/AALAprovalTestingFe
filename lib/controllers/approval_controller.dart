import '../models/approval_item.dart';
import '../models/pagination_metadata.dart';

/// Kontrak dasar untuk semua controller approval.
/// Memisahkan UI dari detail implementasi pengambilan dan pemrosesan data approval.
abstract class ApprovalController {
  Future<List<ApprovalItem>> loadItems({int page = 1, int perPage = 15});
  Future<Map<String, dynamic>> approve(int id);
  Future<Map<String, dynamic>> reject(int id, {String? rejectReason});
  String getPageTitle();
  String getMasterName();
  PaginationMetadata? getPagination();
}
