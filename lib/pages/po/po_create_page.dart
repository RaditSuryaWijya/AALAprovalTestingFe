import 'package:flutter/material.dart';
import '../../services/po_service.dart';

class POCreatePage extends StatefulWidget {
  const POCreatePage({super.key});

  @override
  State<POCreatePage> createState() => _POCreatePageState();
}

class _POCreatePageState extends State<POCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaBarangController = TextEditingController();
  final _totalHargaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaBarangController.dispose();
    _totalHargaController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final totalHarga = double.tryParse(
        _totalHargaController.text.replaceAll('.', '').replaceAll(',', ''),
      );

      if (totalHarga == null || totalHarga <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total harga tidak valid')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await POService.createPO(
        namaBarang: _namaBarangController.text.trim(),
        totalHarga: totalHarga,
      );

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Request PO berhasil dibuat'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal membuat request'),
              backgroundColor: Colors.red,
            ),
          );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Barang
              TextFormField(
                controller: _namaBarangController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  hintText: 'Contoh: Laptop Dell XPS 15',
                  prefixIcon: Icon(Icons.shopping_cart),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang tidak boleh kosong';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Total Harga
              TextFormField(
                controller: _totalHargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Harga',
                  hintText: '25000000',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Total harga tidak boleh kosong';
                  }
                  final harga = double.tryParse(
                    value.replaceAll('.', '').replaceAll(',', ''),
                  );
                  if (harga == null || harga <= 0) {
                    return 'Total harga harus lebih dari 0';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Buat Request PO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

