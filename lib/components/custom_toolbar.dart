import 'package:flutter/material.dart';
import '../models/auth_user_model.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class CustomToolbar extends StatelessWidget {
  final AuthUserModel user;
  final String dateString;

  const CustomToolbar({
    super.key,
    required this.user,
    required this.dateString,
  });

  Future<void> _handleLogout(BuildContext context) async {
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

    if (confirm == true && context.mounted) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AppBar area (dengan exit button)
          SizedBox(
            height: 70,
            child: AppBar(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => _handleLogout(context),
                tooltip: 'Logout',
              ),
            ),
          ),
          // User Profile Header
          Container(
            height: 170,
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 12),
            child: Stack(
              children: [
                // Tanggal di kanan atas
                Positioned(
                  bottom: 10,
                  right: 16,
                  child: Text(
                    dateString,
                    style: const TextStyle(
                      fontFamily: 'mgopenmodata',
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Layout Avatar dan Info User
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circle Image View
                    Container(
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber.shade300, width: 2),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    // Info Text
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nama (Bold, All Caps)
                            Text(
                              user.name.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'mgopenmodata',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Jabatan (Thin)
                            Text(
                              user.jabatan.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'mgopenmodata',
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Department (Thin)
                            Text(
                              user.department.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'mgopenmodata',
                                fontWeight: FontWeight.w300,
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
