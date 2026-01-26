# Spesifikasi Perangkat Minimum

Dokumen ini menjelaskan spesifikasi perangkat minimum yang dibutuhkan untuk menjalankan aplikasi **testingmagangaal**.

## 📱 Android

### Versi Android Minimum
- **Android 4.4 (KitKat)** - API Level 19
- **Target SDK**: Android 13 (API Level 33)

### Spesifikasi Hardware Minimum
- **RAM**: 2 GB (disarankan 3 GB untuk performa optimal)
- **Storage**: 50 MB untuk instalasi aplikasi
- **Koneksi Internet**: Diperlukan untuk fitur:
  - Login/Autentikasi
  - Load menu dinamis
  - Load data approval
  - Export PDF
  - Activity logging

### Fitur yang Diperlukan
- ✅ Akses Internet (WiFi atau Mobile Data)
- ✅ Shared Preferences (untuk menyimpan token, user data, device ID)
- ✅ PDF Viewer (untuk melihat detail dalam bentuk PDF)

### Kompatibilitas
Aplikasi dapat berjalan di perangkat Android dengan:
- Android 4.4 (KitKat) hingga Android terbaru
- Semua ukuran layar (phone, tablet)
- Semua orientasi (portrait, landscape)

---

## 🍎 iOS

### Versi iOS Minimum
- **iOS 11.0** atau lebih tinggi
- **Target**: iOS terbaru yang didukung Flutter

### Spesifikasi Hardware Minimum
- **RAM**: 2 GB (disarankan 3 GB untuk performa optimal)
- **Storage**: 50 MB untuk instalasi aplikasi
- **Koneksi Internet**: Diperlukan untuk fitur:
  - Login/Autentikasi
  - Load menu dinamis
  - Load data approval
  - Export PDF
  - Activity logging

### Fitur yang Diperlukan
- ✅ Akses Internet (WiFi atau Cellular Data)
- ✅ UserDefaults (untuk menyimpan token, user data, device ID)
- ✅ PDF Viewer (untuk melihat detail dalam bentuk PDF)

### Kompatibilitas
Aplikasi dapat berjalan di perangkat iOS dengan:
- iPhone dan iPad
- Semua ukuran layar
- Semua orientasi (portrait, landscape)

---

## 💻 Web

### Browser Minimum
- **Chrome**: Versi 90+
- **Firefox**: Versi 88+
- **Safari**: Versi 14+
- **Edge**: Versi 90+

### Spesifikasi
- **RAM**: 2 GB
- **Koneksi Internet**: Diperlukan

---

## 🖥️ Desktop (Opsional)

### Windows
- **Windows 10** atau lebih tinggi
- **RAM**: 4 GB
- **Storage**: 100 MB

### macOS
- **macOS 10.14** (Mojave) atau lebih tinggi
- **RAM**: 4 GB
- **Storage**: 100 MB

### Linux
- **Ubuntu 18.04** atau distribusi Linux modern lainnya
- **RAM**: 4 GB
- **Storage**: 100 MB

---

## 📋 Ringkasan Spesifikasi Minimum

| Platform | Versi OS Minimum | RAM | Storage | Internet |
|----------|------------------|-----|---------|----------|
| **Android** | 4.4 (KitKat) | 2 GB | 50 MB | ✅ Wajib |
| **iOS** | 11.0 | 2 GB | 50 MB | ✅ Wajib |
| **Web** | Browser Modern | 2 GB | - | ✅ Wajib |
| **Windows** | 10 | 4 GB | 100 MB | ✅ Wajib |
| **macOS** | 10.14 | 4 GB | 100 MB | ✅ Wajib |
| **Linux** | Ubuntu 18.04+ | 4 GB | 100 MB | ✅ Wajib |

---

## 🔧 Dependencies & Requirements

### Flutter SDK
- **Minimum**: Flutter 3.10.4
- **Dart SDK**: Mengikuti Flutter SDK

### Package Dependencies
- `http: ^1.6.0` - HTTP client
- `shared_preferences: ^2.2.2` - Local storage
- `intl: ^0.19.0` - Internationalization
- `flutter_cached_pdfview: ^0.4.3` - PDF viewer

### Build Requirements
- **Android**: Java 17, Kotlin, Gradle
- **iOS**: Xcode (untuk development), Swift
- **Web**: Browser modern dengan JavaScript enabled

---

## 📝 Catatan Penting

1. **Koneksi Internet Wajib**: Aplikasi ini adalah aplikasi berbasis server, sehingga memerlukan koneksi internet aktif untuk semua fitur utama.

2. **Storage Lokal**: Aplikasi menyimpan data berikut di perangkat:
   - Token autentikasi
   - Data user
   - Device ID (untuk tracking)
   - Cache PDF (opsional)

3. **Permissions**: Aplikasi tidak memerlukan permission khusus seperti:
   - ❌ Camera
   - ❌ Location
   - ❌ Contacts
   - ❌ Storage (kecuali untuk cache PDF)

4. **Offline Mode**: Saat ini aplikasi **tidak mendukung** mode offline. Semua fitur memerlukan koneksi internet.

---

## 🚀 Rekomendasi Spesifikasi untuk Performa Optimal

### Android
- Android 8.0 (Oreo) atau lebih tinggi
- RAM: 3 GB atau lebih
- Storage: 100 MB free space

### iOS
- iOS 13.0 atau lebih tinggi
- RAM: 3 GB atau lebih
- Storage: 100 MB free space

---

## 📞 Support

Jika mengalami masalah kompatibilitas atau performa, pastikan:
1. Perangkat memenuhi spesifikasi minimum
2. Koneksi internet stabil
3. Aplikasi sudah di-update ke versi terbaru
4. Storage masih tersedia

---

**Versi Dokumen**: 1.0  
**Terakhir Diupdate**: Januari 2026
  