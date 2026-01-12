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
            child: Icon(Icons.person, size: 40, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'mgopenmodata',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.jabatan.toUpperCase(),
                  style: TextStyle(fontFamily: 'mgopenmodata', fontSize: 16, color: Colors.grey.shade700),
                ),
                // ... (Sisa text email dan department sama seperti kode awal Anda)
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dateString,
                    style: TextStyle(fontFamily: 'mgopenmodata', fontSize: 16, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}