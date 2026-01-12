import '../models/lov_model.dart';

/// Utility class untuk menyimpan data LOV yang umum digunakan
class LovData {
  // Contoh: Daftar avatar yang tersedia
  static List<LovModel> getAvatarList() {
    return [
      LovModel(
        code: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/female/512/1.jpg',
        description: 'Avatar Wanita 1',
      ),
      LovModel(
        code: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/female/512/2.jpg',
        description: 'Avatar Wanita 2',
      ),
      LovModel(
        code: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/female/512/3.jpg',
        description: 'Avatar Wanita 3',
      ),
      LovModel(
        code: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/1.jpg',
        description: 'Avatar Pria 1',
      ),
      LovModel(
        code: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/2.jpg',
        description: 'Avatar Pria 2',
      ),
      LovModel(
        code: 'https://cdn.jsdelivr.net/gh/faker-js/assets-person-portrait/male/512/3.jpg',
        description: 'Avatar Pria 3',
      ),
    ];
  }

  // Contoh: Status user (jika diperlukan)
  static List<LovModel> getUserStatusList() {
    return [
      LovModel(code: 'ACTIVE', description: 'Aktif'),
      LovModel(code: 'INACTIVE', description: 'Tidak Aktif'),
      LovModel(code: 'SUSPENDED', description: 'Ditangguhkan'),
    ];
  }

  // Contoh: Sort options
  static List<LovModel> getSortOptions() {
    return [
      LovModel(code: 'name_asc', description: 'Nama A-Z'),
      LovModel(code: 'name_desc', description: 'Nama Z-A'),
      LovModel(code: 'created_asc', description: 'Terbaru'),
      LovModel(code: 'created_desc', description: 'Terlama'),
    ];
  }

  // Helper untuk mendapatkan avatar dari code
  static String? getAvatarUrl(String? code) {
    if (code == null || code.isEmpty) return null;
    return code;
  }

  // Helper untuk mendapatkan description dari code
  static String? getDescription(String? code, List<LovModel> items) {
    try {
      return items.firstWhere((item) => item.code == code).description;
    } catch (e) {
      return null;
    }
  }
}

