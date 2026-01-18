import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueAccent, // Sesuaikan tema Anda
        foregroundColor: Colors.white,
      ),
      body: PDF(
        enableSwipe: true,
        swipeHorizontal: false, // Scroll vertikal seperti web
        autoSpacing: false,
        pageFling: false,
      ).fromUrl(
        url,
        placeholder: (progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(
                '$progress %',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        errorWidget: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                "Gagal memuat PDF: $error",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}