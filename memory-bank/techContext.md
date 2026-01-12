# Tech Context - testingmagangaal

## Teknologi Stack

### Core Framework
- **Flutter SDK**: ^3.10.4
- **Dart Language**: Mengikuti SDK Flutter
- **Material Design**: UI framework default

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8  # iOS style icons
  http: ^1.6.0              # HTTP client untuk API calls
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0     # Linting rules
```

## Platform Support

### Android
- **Namespace**: `com.example.testingmagangaal`
- **Application ID**: `com.example.testingmagangaal`
- **Java Version**: 17
- **Kotlin**: JVM Target 17
- **Build Tool**: Gradle (Kotlin DSL)
- **Gradle Plugin**: Flutter Gradle Plugin

### iOS
- **Language**: Swift
- **Build System**: Xcode
- **Framework**: Flutter App Framework

### Web
- Standar Flutter web support
- HTML/CSS/JS output

### Desktop
- Linux (CMake)
- macOS (Xcode)
- Windows (CMake/Visual Studio)

## Development Setup

### Prerequisites
1. Flutter SDK 3.10.4 atau lebih tinggi
2. Dart SDK (bundled dengan Flutter)
3. Android Studio / VS Code dengan Flutter extension
4. Xcode (untuk iOS development - macOS only)
5. Git (untuk version control)

### Build Commands
```bash
# Run app
flutter run

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Build Web
flutter build web
```

### Development Tools
- **Analysis Options**: `analysis_options.yaml` - Konfigurasi linter
- **Flutter Lints**: Rekomendasi best practices
- **Hot Reload**: Fast development cycle
- **Hot Restart**: Full restart saat diperlukan

## API Integration

### External Service
- **MockAPI.io**: `https://695dc6b72556fd22f6766306.mockapi.io/api/magangaal`
- **Endpoint**: `/user`
- **Protocol**: HTTPS
- **Method**: GET

### HTTP Client
- Package: `http` (pub.dev)
- Version: 1.6.0
- Pattern: Async/await dengan Future

### API Configuration
Lokasi: `lib/config/api_config.dart`
- Static constants untuk URLs
- Base URL dapat diubah dengan mudah
- Endpoints didefinisikan sebagai static const

## Constraints

### Technical Constraints
1. **SDK Version**: Minimum Flutter 3.10.4
2. **Platform**: Multi-platform support (mungkin ada perbedaan behavior)
3. **API**: Bergantung pada external service (MockAPI)
4. **State Management**: Belum menggunakan state management library (masih setState)

### Development Constraints
1. **Android**: Perlu Android SDK dan emulator/device
2. **iOS**: Hanya bisa di-develop di macOS dengan Xcode
3. **Testing**: Basic widget test sudah ada template

## Dependencies Management

### Version Control
- `pubspec.yaml`: Mendefinisikan dependencies
- `pubspec.lock`: Lock file untuk version consistency

### Package Management
- Menggunakan **pub** (Dart package manager)
- Dependencies di-resolve dari pub.dev

### Update Commands
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check outdated packages
flutter pub outdated
```

## Build Configuration

### Android
- Gradle dengan Kotlin DSL
- Source compatibility: Java 17
- Target compatibility: Java 17

### iOS
- Swift-based
- Xcode project configuration

### Web
- Default Flutter web configuration

## Environment Variables
Saat ini tidak ada environment variables yang digunakan. Jika diperlukan di masa depan, dapat menggunakan:
- `.env` file dengan `flutter_dotenv` package
- Build configuration files
- Platform-specific configuration

## Known Technical Debt
1. Error handling masih basic (print statements)
2. Belum ada loading indicators
3. Belum ada offline handling
4. State management masih menggunakan setState (bisa di-scale dengan Provider/Riverpod/Bloc)
5. Belum ada proper logging system

