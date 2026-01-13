import 'package:flutter/material.dart';
import '../models/auth_user_model.dart';
import '../models/menu_model.dart';
import '../services/auth_service.dart';
import '../services/menu_service.dart';
import '../utils/route_manager.dart';
import '../routes/app_routes.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final AuthUserModel user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<MenuModel> _menus = [];
  bool _isLoadingMenus = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    setState(() {
      _isLoadingMenus = true;
      _errorMessage = null;
    });

    try {
      final menuResponse = await MenuService.getMenus();
      if (menuResponse != null) {
        // Filter menu dashboard karena tidak perlu ditampilkan sebagai card
        // User sudah berada di halaman dashboard
        final filteredMenus = menuResponse.menus.where((menu) {
          final normalizedLink = menu.menuLink.toLowerCase().replaceAll(RegExp(r'/$'), '');
          return normalizedLink != '/dashboard' && normalizedLink.isNotEmpty;
        }).toList();

        setState(() {
          _menus = filteredMenus;
          _isLoadingMenus = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat menu';
          _isLoadingMenus = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoadingMenus = false;
      });
    }
  }

  // Navigate ke halaman berdasarkan menu_link menggunakan named routes
  void _navigateToMenu(MenuModel menu) {
    // Normalize route name
    final routeName = RouteManager.normalizeRoute(menu.menuLink);

    // Jika dashboard atau tidak valid, tidak perlu navigate
    if (routeName == null) {
      return;
    }

    // Check if route exists in AppRoutes
    if (AppRoutes.hasRoute(routeName)) {
      // Navigate menggunakan named route - Flutter akan otomatis resolve dari routes map
      Navigator.pushNamed(context, routeName);
    } else {
      // Show error jika menu_link tidak dikenali
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu "${menu.label}" (${menu.menuLink}) belum tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  String _formatDate() {
    final now = DateTime.now();
    // Urutan: Senin(1), Selasa(2), Rabu(3), Kamis(4), Jumat(5), Sabtu(6), Minggu(7)
    final dayNames = [
      '', // index 0 tidak digunakan
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final monthNames = [
      '', // index 0 tidak digunakan
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final dayName = dayNames[now.weekday];
    final day = now.day.toString().padLeft(2, '0');
    final month = monthNames[now.month];
    final year = now.year.toString();
    
    return '$dayName, $day $month $year'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'AAL APROVAL',
          style: TextStyle(
            fontFamily: 'mgopenmodata',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header tetap (tidak ikut scroll)
          _buildHeader(),
          const SizedBox(height: 8),
          // Area menu scrollable + pull to refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMenus,
              child: _buildMenuContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Header profil user (tetap di atas, tidak ikut scroll)
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.shade300, width: 2),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.user.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'mgopenmodata',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.jabatan.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'mgopenmodata',
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    fontFamily: 'mgopenmodata',
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.department.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'mgopenmodata',
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatDate(),
                    style: TextStyle(
                      fontFamily: 'mgopenmodata',
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Konten menu (scrollable) untuk RefreshIndicator
  Widget _buildMenuContent() {
    // Gunakan ListView agar bisa di-scroll
      return ListView(
        padding: EdgeInsets.zero,
        children: [
        if (_isLoadingMenus)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMenus,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          )
        else if (_menus.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(
                  Icons.menu,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text('Tidak ada menu tersedia'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadMenus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 0.85,
              ),
              itemCount: _menus.length,
              itemBuilder: (context, index) {
                final menu = _menus[index];
                return _buildMenuCard(menu);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    return Container(
      height: 135, 
      margin: const EdgeInsets.all(1.25), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5), 
        color: Colors.grey.shade300,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToMenu(menu),
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(5.0), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  menu.iconData,
                  size: 60,
                  color: Colors.blue,
                ),
                const SizedBox(height: 4),
                Text(
                  menu.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'mgopenmodata',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
