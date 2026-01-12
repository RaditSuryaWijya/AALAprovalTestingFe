import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/user_model.dart';

class UserService {
  // CREATE - Tambah user baru
  static Future<UserModel?> createUser({
    required String name,
    required String avatar,
  }) async {
    try {
      var url = Uri.parse(ApiConfig.users);
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json",
        },
        body: jsonEncode({
          'name': name,
          'avatar': avatar,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        
        // Handle struktur response baru: {success, data, message}
        if (responseData is Map<String, dynamic>) {
          bool success = responseData['success'] ?? false;
          String message = responseData['message'] ?? '';
          
          if (success && responseData['data'] != null) {
            var userData = responseData['data'];
            if (userData is Map<String, dynamic>) {
              print("Sukses create user: $message");
              return UserModel.fromJson(userData);
            }
          }
        }
        
        // Fallback untuk struktur lama (jika masih digunakan)
        if (responseData is Map<String, dynamic> && responseData['name'] != null) {
          print("Sukses create user: ${responseData['name']}");
          return UserModel.fromJson(responseData);
        }
        
        print("Gagal create user: Format response tidak dikenali");
        return null;
      } else {
        print("Gagal create user: ${response.statusCode}");
        print("Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error create user: $e");
      return null;
    }
  }

  // READ - Ambil users dengan pagination
  static Future<List<UserModel>> getAllUsers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Tambahkan query parameters untuk pagination
      var url = Uri.parse(ApiConfig.users).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<UserModel> users = [];
        
        // Handle struktur response baru: {success, data, message}
        if (responseData is Map<String, dynamic>) {
          bool success = responseData['success'] ?? false;
          String message = responseData['message'] ?? '';
          
          if (success && responseData['data'] != null) {
            var data = responseData['data'];
            
            // Handle jika data adalah array
            if (data is List) {
              for (var item in data) {
                if (item is Map<String, dynamic>) {
                  users.add(UserModel.fromJson(item));
                }
              }
              print("Sukses ambil ${users.length} users: $message");
              return users;
            }
            // Handle jika data adalah single object
            else if (data is Map<String, dynamic>) {
              users.add(UserModel.fromJson(data));
              print("Sukses ambil 1 user: $message");
              return users;
            }
          } else {
            print("Gagal ambil users: $message");
            return [];
          }
        }
        
        // Fallback untuk struktur lama (jika masih digunakan)
        if (responseData is List) {
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              users.add(UserModel.fromJson(item));
            }
          }
          print("Sukses ambil ${users.length} users (legacy format)");
          return users;
        }
        
        print("Gagal ambil users: Format response tidak dikenali");
        return [];
      } else {
        print("Gagal ambil users: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error ambil users: $e");
      return [];
    }
  }

  // READ - Ambil users dengan pagination (mengembalikan Map dengan info pagination)
  static Future<Map<String, dynamic>> getUsersWithPagination({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Tambahkan query parameters untuk pagination
      var url = Uri.parse(ApiConfig.users).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<UserModel> users = [];
        int totalPages = 1;
        int totalItems = 0;
        bool hasNextPage = false;
        
        // Handle struktur response baru: {success, data, message}
        if (responseData is Map<String, dynamic>) {
          bool success = responseData['success'] ?? false;
          String message = responseData['message'] ?? '';
          
          if (success && responseData['data'] != null) {
            var data = responseData['data'];
            
            // Handle jika data adalah array
            if (data is List) {
              for (var item in data) {
                if (item is Map<String, dynamic>) {
                  users.add(UserModel.fromJson(item));
                }
              }
              
              // Extract pagination info jika ada di response
              totalItems = responseData['total'] ?? users.length;
              totalPages = responseData['totalPages'] ?? 
                           (totalItems > 0 ? (totalItems / limit).ceil() : 1);
              hasNextPage = responseData['hasNextPage'] ?? 
                           (page < totalPages);
              
              print("Sukses ambil ${users.length} users (page $page/$totalPages): $message");
              return {
                'users': users,
                'currentPage': page,
                'totalPages': totalPages,
                'totalItems': totalItems,
                'hasNextPage': hasNextPage,
                'hasPreviousPage': page > 1,
              };
            }
            // Handle jika data adalah single object
            else if (data is Map<String, dynamic>) {
              users.add(UserModel.fromJson(data));
              print("Sukses ambil 1 user: $message");
              return {
                'users': users,
                'currentPage': 1,
                'totalPages': 1,
                'totalItems': 1,
                'hasNextPage': false,
                'hasPreviousPage': false,
              };
            }
          } else {
            print("Gagal ambil users: $message");
            return {
              'users': [],
              'currentPage': page,
              'totalPages': 1,
              'totalItems': 0,
              'hasNextPage': false,
              'hasPreviousPage': false,
            };
          }
        }
        
        // Fallback untuk struktur lama (jika masih digunakan)
        if (responseData is List) {
          for (var item in responseData) {
            if (item is Map<String, dynamic>) {
              users.add(UserModel.fromJson(item));
            }
          }
          // Untuk legacy format, anggap semua data sudah dimuat
          print("Sukses ambil ${users.length} users (legacy format)");
          return {
            'users': users,
            'currentPage': 1,
            'totalPages': 1,
            'totalItems': users.length,
            'hasNextPage': false,
            'hasPreviousPage': false,
          };
        }
        
        print("Gagal ambil users: Format response tidak dikenali");
        return {
          'users': [],
          'currentPage': page,
          'totalPages': 1,
          'totalItems': 0,
          'hasNextPage': false,
          'hasPreviousPage': false,
        };
      } else {
        print("Gagal ambil users: ${response.statusCode}");
        return {
          'users': [],
          'currentPage': page,
          'totalPages': 1,
          'totalItems': 0,
          'hasNextPage': false,
          'hasPreviousPage': false,
        };
      }
    } catch (e) {
      print("Error ambil users: $e");
      return {
        'users': [],
        'currentPage': page,
        'totalPages': 1,
        'totalItems': 0,
        'hasNextPage': false,
        'hasPreviousPage': false,
      };
    }
  }

  // READ - Ambil user by ID
  static Future<UserModel?> getUserById(String id) async {
    try {
      var url = Uri.parse("${ApiConfig.users}/$id");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        
        // Handle struktur response baru: {success, data, message}
        if (responseData is Map<String, dynamic>) {
          bool success = responseData['success'] ?? false;
          String message = responseData['message'] ?? '';
          
          if (success && responseData['data'] != null) {
            var userData = responseData['data'];
            if (userData is Map<String, dynamic>) {
              print("Sukses ambil user: $message");
              return UserModel.fromJson(userData);
            }
          } else {
            print("Gagal ambil user: $message");
            return null;
          }
        }
        
        // Fallback untuk struktur lama (jika masih digunakan)
        if (responseData is Map<String, dynamic> && responseData['name'] != null) {
          print("Sukses ambil user: ${responseData['name']}");
          return UserModel.fromJson(responseData);
        }
        
        print("Gagal ambil user: Format response tidak dikenali");
        return null;
      } else {
        print("Gagal ambil user: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error ambil user: $e");
      return null;
    }
  }

  // UPDATE - Update user
  static Future<UserModel?> updateUser({
    required String id,
    required String name,
    required String avatar,
  }) async {
    try {
      var url = Uri.parse("${ApiConfig.users}/$id");
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'avatar': avatar,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        
        // Handle struktur response baru: {success, data, message}
        if (responseData is Map<String, dynamic>) {
          bool success = responseData['success'] ?? false;
          String message = responseData['message'] ?? '';
          
          if (success && responseData['data'] != null) {
            var userData = responseData['data'];
            if (userData is Map<String, dynamic>) {
              print("Sukses update user: $message");
              return UserModel.fromJson(userData);
            }
          } else {
            print("Gagal update user: $message");
            return null;
          }
        }
        
        // Fallback untuk struktur lama (jika masih digunakan)
        if (responseData is Map<String, dynamic> && responseData['name'] != null) {
          print("Sukses update user: ${responseData['name']}");
          return UserModel.fromJson(responseData);
        }
        
        print("Gagal update user: Format response tidak dikenali");
        return null;
      } else {
        print("Gagal update user: ${response.statusCode}");
        print("Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error update user: $e");
      return null;
    }
  }

  // DELETE - Hapus user
  static Future<bool> deleteUser(String id) async {
    try {
      var url = Uri.parse("${ApiConfig.users}/$id");
      var response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Sukses hapus user dengan ID: $id");
        return true;
      } else {
        print("Gagal hapus user: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error hapus user: $e");
      return false;
    }
  }
}

