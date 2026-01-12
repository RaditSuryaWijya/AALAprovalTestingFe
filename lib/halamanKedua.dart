import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'form_user_page.dart';

class HalamanKedua extends StatefulWidget {
  const HalamanKedua({super.key});

  @override
  State<HalamanKedua> createState() => _HalamanKeduaState();
}

class _HalamanKeduaState extends State<HalamanKedua> {
  List<UserModel> allUsers = []; // Semua data dari API
  List<UserModel> displayedUsers = []; // Data yang ditampilkan (10 per halaman)
  bool isLoading = false;
  String? errorMessage;
  
  // Pagination state
  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;
  bool hasNextPage = false;
  bool hasPreviousPage = false;
  static const int limitPerPage = 10; // Maksimal 10 data per halaman

  @override
  void initState() {
    super.initState();
    loadAllUsers();
  }

  // Fungsi untuk load semua users dari API
  Future<void> loadAllUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Ambil semua data dari API (tanpa pagination parameter)
      var fetchedUsers = await UserService.getAllUsers();
      
      // Hitung pagination info
      totalItems = fetchedUsers.length;
      totalPages = totalItems > 0 ? (totalItems / limitPerPage).ceil() : 1;
      
      setState(() {
        allUsers = fetchedUsers;
        isLoading = false;
      });
      
      // Set halaman pertama setelah data dimuat
      goToPage(1);
    } catch (e) {
        setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }
  
  // Fungsi untuk update pagination dan slice data
  void updatePagination(int page) {
    // Jika tidak ada data, reset state
    if (allUsers.isEmpty) {
      setState(() {
        displayedUsers = [];
        currentPage = 1;
        totalPages = 1;
        totalItems = 0;
        hasNextPage = false;
        hasPreviousPage = false;
      });
      return;
    }

    // Hitung total halaman berdasarkan jumlah data
    totalPages = totalItems > 0 ? (totalItems / limitPerPage).ceil() : 1;
    if (totalPages < 1) totalPages = 1;

    // Clamp page agar tidak melebihi batas
    if (page < 1) page = 1;
    if (page > totalPages) page = totalPages;

    // Hitung start dan end index untuk slicing
    int startIndex = (page - 1) * limitPerPage;
    if (startIndex >= allUsers.length) {
      // Jika startIndex melebihi panjang list, kembali ke halaman 1
      startIndex = 0;
      page = 1;
    }
    int endIndex = startIndex + limitPerPage;

    // Pastikan endIndex tidak melebihi panjang list
    if (endIndex > allUsers.length) {
      endIndex = allUsers.length;
    }

    // Slice data untuk halaman saat ini
    displayedUsers = allUsers.sublist(startIndex, endIndex);

    // Update pagination state
        setState(() {
      currentPage = page;
      hasNextPage = page < totalPages;
      hasPreviousPage = page > 1;
    });
  }
  
  // Navigasi ke halaman berikutnya
  void nextPage() {
    if (hasNextPage) {
      updatePagination(currentPage + 1);
    }
  }
  
  // Navigasi ke halaman sebelumnya
  void previousPage() {
    if (hasPreviousPage) {
      updatePagination(currentPage - 1);
    }
  }
  
  // Navigasi ke halaman tertentu
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      updatePagination(page);
    }
  }

  // Fungsi untuk delete user
  Future<void> deleteUser(String id, String name) async {
    // Konfirmasi delete
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await UserService.deleteUser(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil dihapus')),
        );
        loadAllUsers(); // Reload semua data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus user')),
        );
      }
    }
  }

  // Navigasi ke form untuk create user baru
  void navigateToCreateForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormUserPage(),
      ),
    );
    loadAllUsers(); // Reload semua data setelah kembali
  }

  // Navigasi ke form untuk edit user
  void navigateToEditForm(UserModel user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormUserPage(user: user),
      ),
    );
    loadAllUsers(); // Reload semua data setelah kembali
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Users"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAllUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: loadAllUsers,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : allUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak ada data user',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
              ElevatedButton.icon(
                            onPressed: loadAllUsers,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Info pagination (hanya muncul jika ada data)
                        if (totalItems > 0)
                          Container(
                            padding: const EdgeInsets.all(12),
                            color: Colors.grey.shade200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Halaman $currentPage dari $totalPages | Total: $totalItems user',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Menampilkan ${displayedUsers.length} dari $totalItems data',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
                        // List users
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: loadAllUsers,
                            child: ListView.builder(
                        itemCount: displayedUsers.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final user = displayedUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user.avatar),
                                onBackgroundImageError: (_, __) {},
                                child: user.avatar.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID: ${user.id}'),
              Text(
                                    user.createdAt != null 
                                        ? 'Created: ${_formatDate(user.createdAt!)}'
                                        : 'Created: Tidak ada data',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => navigateToEditForm(user),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteUser(user.id, user.name),
                                    tooltip: 'Hapus',
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                            ),
                          ),
                        ),
                        // Pagination controls (hanya muncul jika ada lebih dari 1 halaman)
                        if (totalPages > 1)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              // Previous button
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: hasPreviousPage ? previousPage : null,
                                tooltip: 'Halaman Sebelumnya',
                              ),
                              const SizedBox(width: 8),
                              // Page numbers (tampilkan max 5 page numbers)
                              ..._buildPageNumbers(),
                              const SizedBox(width: 8),
                              // Next button
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: hasNextPage ? nextPage : null,
                                tooltip: 'Halaman Berikutnya',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToCreateForm,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method untuk build page numbers
  List<Widget> _buildPageNumbers() {
    List<Widget> pageWidgets = [];
    int maxVisiblePages = 5;
    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > maxVisiblePages) {
      if (currentPage <= 3) {
        endPage = maxVisiblePages;
      } else if (currentPage >= totalPages - 2) {
        startPage = totalPages - maxVisiblePages + 1;
      } else {
        startPage = currentPage - 2;
        endPage = currentPage + 2;
      }
    }

    // First page
    if (startPage > 1) {
      pageWidgets.add(
        TextButton(
          onPressed: () => goToPage(1),
          child: const Text('1'),
        ),
      );
      if (startPage > 2) {
        pageWidgets.add(const Text('...'));
      }
    }

    // Page numbers
    for (int i = startPage; i <= endPage; i++) {
      pageWidgets.add(
        TextButton(
          onPressed: () => goToPage(i),
          style: TextButton.styleFrom(
            backgroundColor: i == currentPage ? Colors.green : null,
            foregroundColor: i == currentPage ? Colors.white : null,
          ),
          child: Text('$i'),
        ),
      );
    }

    // Last page
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageWidgets.add(const Text('...'));
      }
      pageWidgets.add(
        TextButton(
          onPressed: () => goToPage(totalPages),
          child: Text('$totalPages'),
        ),
      );
    }

    return pageWidgets;
  }

  // Helper method untuk format tanggal
  String _formatDate(String dateString) {
    try {
      if (dateString.isEmpty) return 'Tidak ada data';
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
    } catch (e) {
      return dateString;
    }
  }
}
