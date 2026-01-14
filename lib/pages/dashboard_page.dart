import 'package:flutter/material.dart';
import '../models/auth_user_model.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';
import '../utils/route_manager.dart';
import '../routes/app_routes.dart';
import '../components/menu_grid_item.dart';
import '../components/custom_toolbar.dart';

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

  void _navigateToMenu(MenuModel menu) {
    final routeName = RouteManager.normalizeRoute(menu.menuLink);
    if (routeName == null) {
      return;
    }

    if (AppRoutes.hasRoute(routeName)) {
      Navigator.pushNamed(context, routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu "${menu.label}" (${menu.menuLink}) belum tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatDate() {
    final now = DateTime.now();
    // Urutan: Senin(1), Selasa(2), Rabu(3), Kamis(4), Jumat(5), Sabtu(6), Minggu(7)
    final dayNames = [
      '',
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final monthNames = [
      '',
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
      body: Column(
        children: [
          // Custom Toolbar - Fixed, tidak bisa di-scroll (AppBar + UserProfile)
          CustomToolbar(
            user: widget.user,
            dateString: _formatDate(),
          ),
          // Menu Content - Bisa di-scroll
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMenus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildMenuContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent() {
    if (_isLoadingMenus) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
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
      );
    }

    if (_menus.isEmpty) {
      return Padding(
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
      );
    }

    // --- PERUBAHAN DI SINI ---
    // Widget Padding dihapus, langsung return GridView
    return GridView.builder(
      // Tambahkan padding: EdgeInsets.zero jika ingin benar-benar mepet ke sisi layar
      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
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
        return MenuGridItem(
          menu: menu,
          onTap: () => _navigateToMenu(menu),
        );
      },
    );
  }

}
