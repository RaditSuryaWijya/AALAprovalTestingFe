import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'models/auth_user_model.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Approval System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'mgopenmodata', // Default font untuk aplikasi
      ),
      // Tidak lagi menggunakan custom SplashScreenPage
      // Langsung gunakan AuthGate untuk cek login dan redirect
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
      // Setup named routes - 100% Server-Driven
      // Routes akan di-resolve secara dinamis dari menuLink server
      routes: AppRoutes.routes,
      // Handler untuk route yang tidak ditemukan di routes map
      // Akan di-resolve secara dinamis menggunakan DynamicRouteResolver
      onGenerateRoute: (settings) {
        final routeName = settings.name;
        if (routeName == null) return null;

        // Coba resolve route secara dinamis
        final builder = AppRoutes.getRoute(routeName);
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }

        // Jika tidak ditemukan, return null (akan di-handle oleh onUnknownRoute)
        return null;
      },
      // Handle route yang tidak ditemukan
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Route "${settings.name}" tidak ditemukan',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  AuthUserModel? _user;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await AuthService.isAuthenticated();
    final user = await AuthService.getCurrentUser();

    if (!mounted) return;

    if (isAuthenticated && user != null) {
      // Sudah login -> langsung ke dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardPage(user: user)),
      );
    } else {
      // Belum login -> ke halaman login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }

    if (mounted) {
      setState(() {
        _checking = false;
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sementara cek auth, tampilkan loading sederhana (tanpa logo custom)
    if (_checking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      );
    }

    // Secara teori tidak pernah sampai sini karena sudah di-redirect,
    // tapi untuk jaga-jaga tampilkan LoginPage.
    return const LoginPage();
  }
}
