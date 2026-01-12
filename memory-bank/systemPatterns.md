# System Patterns - testingmagangaal

## Arsitektur Sistem
Aplikasi menggunakan arsitektur Material Design dengan pola stateless dan stateful widgets standar Flutter.

## Struktur Folder
```
lib/
├── main.dart              # Entry point aplikasi
├── halamanKedua.dart     # Halaman kedua untuk API integration
└── config/
    └── api_config.dart   # Konfigurasi API endpoints
```

## Pola Desain yang Digunakan

### 1. StatelessWidget Pattern
- **MyApp**: Widget root yang tidak memerlukan state
- Konfigurasi aplikasi dasar (theme, title, home)

### 2. StatefulWidget Pattern
- **MyHomePage**: Mengelola state counter
- **HalamanKedua**: Mengelola state data dari API

### 3. Navigator Pattern
Menggunakan MaterialPageRoute untuk navigasi:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const HalamanKedua()),
);
```

### 4. API Integration Pattern
- Menggunakan `http` package untuk HTTP requests
- Konfigurasi API terpusat di `ApiConfig` class
- Async/await untuk handling asynchronous operations
- setState untuk update UI setelah data diterima

### 5. Configuration Pattern
- API configuration dipisah ke file terpisah (`api_config.dart`)
- Menggunakan static constants untuk base URL dan endpoints
- Memudahkan perubahan base URL tanpa mengubah kode di multiple places

## Komponen Utama

### MyApp (lib/main.dart)
- Root widget aplikasi
- Mengatur MaterialApp dengan theme
- Menetapkan MyHomePage sebagai home screen

### MyHomePage
- StatefulWidget dengan counter state
- FloatingActionButton untuk increment
- ElevatedButton untuk navigasi

### HalamanKedua
- StatefulWidget untuk menampilkan data API
- Method `ambilDataInternet()` untuk fetch data
- Error handling dengan try-catch

### ApiConfig
- Static class untuk menyimpan konfigurasi API
- Base URL: `https://695dc6b72556fd22f6766306.mockapi.io/api/magangaal`
- Endpoint users: `$baseUrl/user`

## State Management
Saat ini menggunakan **StatefulWidget** dengan **setState** untuk:
- Counter state di MyHomePage
- API data state di HalamanKedua

## Data Flow
```
User Action (Button Click)
    ↓
State Change Trigger
    ↓
API Call (if needed)
    ↓
setState() called
    ↓
UI Rebuild
    ↓
Display Updated Data
```

## Error Handling
- Try-catch blocks pada API calls
- Status code checking (200 untuk success)
- Print statements untuk debugging

## Key Technical Decisions
1. **Material Design**: Menggunakan Material Design untuk konsistensi UI
2. **HTTP Package**: Menggunakan `http` package standar untuk API calls
3. **MockAPI**: Menggunakan MockAPI.io untuk testing tanpa backend real
4. **Stateless vs Stateful**: Memilih widget type berdasarkan kebutuhan state

## Relasi Komponen
```
MyApp
 └── MyHomePage (StatefulWidget)
      └── HalamanKedua (StatefulWidget)
           └── ApiConfig (Static Class)
                └── MockAPI External Service
```

