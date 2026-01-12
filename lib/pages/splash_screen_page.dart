import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../models/auth_user_model.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Tampilkan splash screen minimal 2 detik
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check authentication
    final isAuthenticated = await AuthService.isAuthenticated();
    final user = await AuthService.getCurrentUser();

    if (!mounted) return;

    if (isAuthenticated && user != null) {
      // User sudah login, redirect ke dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardPage(user: user),
        ),
      );
    } else {
      // User belum login, redirect ke login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Astra
            Image.asset(
              'assets/logoastra.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback jika gambar tidak ditemukan
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 16),
            // App name atau loading text (optional)
            Text(
              'Loading...',
              style: TextStyle(
                fontFamily: 'mgopenmodata',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

