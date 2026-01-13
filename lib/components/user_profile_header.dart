import 'package:flutter/material.dart';
import '../models/auth_user_model.dart';

class UserProfileHeader extends StatelessWidget {
  final AuthUserModel user;
  final String dateString;

  const UserProfileHeader({
    super.key,
    required this.user,
    required this.dateString,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300, // Background disamakan dengan AppBar
      padding: const EdgeInsets.only(bottom: 16), // Beri jarak sedikit ke bawah
      child: Stack(
        children: [
          // Tanggal di kanan atas
          Positioned(
            top: 10,
            right: 16, // Sedikit digeser agar tidak terlalu mepet
            child: Text(
              dateString,
              style: const TextStyle(
                fontFamily: 'mgopenmodata',
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.black87,
              ),
            ),
          ),

          // Layout Avatar dan Info User
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Image View
              Container(
                width: 70, // Ukuran sedikit diperbesar agar proporsional
                height: 70,
                margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
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
                  padding: const EdgeInsets.only(top: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama (Bold, All Caps)
                      Text(
                        user.name.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'mgopenmodata',
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Font size disesuaikan
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
                          fontSize: 14,
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
                          fontSize: 14,
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
    );
  }
}