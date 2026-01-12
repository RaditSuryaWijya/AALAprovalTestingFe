import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../models/lov_model.dart';
import '../widgets/lov_dropdown.dart';
import '../utils/lov_data.dart';

class FormUserPage extends StatefulWidget {
  final UserModel? user; // null untuk create, ada value untuk edit

  const FormUserPage({super.key, this.user});

  @override
  State<FormUserPage> createState() => _FormUserPageState();
}

class _FormUserPageState extends State<FormUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  LovModel? _selectedAvatar; // Menggunakan LOV untuk avatar
  bool _isLoading = false;
  bool _isEditMode = false;
  final List<LovModel> _avatarList = LovData.getAvatarList();

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.user != null;
    if (_isEditMode) {
      _nameController.text = widget.user!.name;
      // Cari avatar yang sesuai dari LOV atau buat custom
      try {
        _selectedAvatar = _avatarList.firstWhere(
          (item) => item.code == widget.user!.avatar,
        );
      } catch (e) {
        // Jika tidak ditemukan di LOV, buat custom entry
        _selectedAvatar = LovModel(
          code: widget.user!.avatar,
          description: 'Custom Avatar',
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditMode) {
        // Update user
        var updatedUser = await UserService.updateUser(
          id: widget.user!.id,
          name: _nameController.text.trim(),
          avatar: _selectedAvatar?.code ?? '',
        );

        if (updatedUser != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User berhasil diupdate')),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal mengupdate user')),
            );
          }
        }
      } else {
        // Create user baru
        var newUser = await UserService.createUser(
          name: _nameController.text.trim(),
          avatar: _selectedAvatar?.code ?? '',
        );

        if (newUser != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User berhasil ditambahkan')),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal menambahkan user')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit User' : 'Tambah User'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview avatar jika ada
              if (_selectedAvatar != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_selectedAvatar!.code),
                      onBackgroundImageError: (_, __) {},
                      child: const Icon(Icons.person, size: 50),
                    ),
                  ),
                ),

              // Field Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama user',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),

              const SizedBox(height: 16),

              // Field Avatar dengan LOV Dropdown
              LovDropdown(
                label: 'Avatar',
                hint: 'Pilih Avatar',
                value: _selectedAvatar,
                items: _avatarList,
                prefixIcon: Icons.image,
                validator: (value) {
                  if (value == null) {
                    return 'Avatar harus dipilih';
                  }
                  return null;
                },
                enabled: !_isLoading,
                onChanged: (LovModel? value) {
                  setState(() {
                    _selectedAvatar = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveUser,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isEditMode ? Icons.save : Icons.add),
                label: Text(_isLoading
                    ? 'Menyimpan...'
                    : (_isEditMode ? 'Update User' : 'Tambah User')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Info
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isEditMode
                              ? 'Edit data user yang sudah ada'
                              : 'Tambah user baru ke dalam sistem',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

