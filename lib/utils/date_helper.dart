// Helper untuk format tanggal tanpa package intl
class DateHelper {
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    
    if (format == 'yyyy-MM-dd') {
      return '$year-$month-$day';
    } else if (format == 'dd MMMM yyyy') {
      final monthNames = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '$day ${monthNames[date.month - 1]} $year';
    }
    
    return '$day/$month/$year';
  }

  static String formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return dateString;
    }
  }

  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}

