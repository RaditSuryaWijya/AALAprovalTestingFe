# Setup Instructions

## Install Dependencies

Setelah modifikasi aplikasi, Anda perlu menginstall dependencies yang baru ditambahkan:

```bash
flutter pub get
```

## Dependencies yang Ditambahkan

1. **shared_preferences: ^2.2.2** - Untuk menyimpan token dan user data
2. **intl: ^0.19.0** - Untuk format tanggal (sudah diganti dengan DateHelper custom)

## Catatan

- Error `package:intl/intl.dart` sudah diperbaiki dengan membuat `DateHelper` custom
- Error `package:shared_preferences/shared_preferences.dart` akan hilang setelah menjalankan `flutter pub get`

## Cara Menjalankan

1. Buka terminal di folder project
2. Jalankan: `flutter pub get`
3. Jalankan: `flutter run`

## Jika Masih Ada Error

Pastikan:
- Flutter SDK sudah terinstall dengan benar
- PATH environment variable sudah diset dengan benar
- Atau gunakan IDE (VS Code / Android Studio) untuk menjalankan `flutter pub get` secara otomatis

