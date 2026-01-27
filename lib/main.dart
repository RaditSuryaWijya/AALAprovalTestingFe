import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/fcm_service.dart';
import 'models/auth_user_model.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// Top-level function untuk background message handler
// Harus berada di luar class (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Menangani pesan background: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");
  
  // Tampilkan notifikasi lokal saat app di background/terminated
  // Ini akan membuat heads-up notification muncul di atas layar
  if (message.notification != null) {
    // Import diperlukan untuk menggunakan NotificationHelper
    // Tapi karena ini top-level function, kita perlu inisialisasi ulang
    final FlutterLocalNotificationsPlugin localNotifications = 
        FlutterLocalNotificationsPlugin();
    
    // Inisialisasi dengan channel yang sama
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await localNotifications.initialize(initializationSettings);
    
    // Buat notification channel dengan importance MAX untuk heads-up
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'approval_notifications',
      'Approval Notifications',
      description: 'Notifikasi untuk approval request',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    // Tampilkan notifikasi dengan priority MAX untuk heads-up
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'approval_notifications',
      'Approval Notifications',
      channelDescription: 'Notifikasi untuk approval request',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.message,
      styleInformation: BigTextStyleInformation(
        message.notification?.body ?? '',
      ),
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Inisialisasi FCM Service
  await FCMService.initialize(appNavigatorKey);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Approval System',
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'mgopenmodata',
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
      // Setup named routes - 100% Server-Driven
      // Routes akan di-resolve secara dinamis dari menuLink server
      routes: AppRoutes.routes,
      // Handler untuk route yang tidak ditemukan di routes map
      // Akan di-resolve secara dinamis menggunakan DynamicRouteResolver
      onGenerateRoute: (settings) {
        final routeName = settings.name;
        if (routeName == null) return null;

        // Coba resolve route secara dinamis
        final builder = AppRoutes.getRoute(routeName);
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }

        // Jika tidak ditemukan, return null (akan di-handle oleh onUnknownRoute)
        return null;
      },
      // Handle route yang tidak ditemukan
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Route "${settings.name}" tidak ditemukan',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
    );
      },
    );
}
}
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  bool _isAuthenticated = false;
  AuthUserModel? _user;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = await AuthService.isAuthenticated();
    final user = await AuthService.getCurrentUser();

    if (!mounted) return;

    // Update state dulu supaya UI tidak “kedip” ke LoginPage saat token valid
    setState(() {
      _checking = false;
      _isAuthenticated = isAuthenticated && user != null;
      _user = user;
    });

    // Jika sudah login, handle initial message (terminated -> tap notifikasi)
    // Kita trigger setelah frame pertama agar navigator/context sudah siap.
    if (_isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await FCMService.handleInitialMessage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sementara cek auth, tampilkan loading sederhana (tanpa logo custom)
    if (_checking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      );
    }

    if (_isAuthenticated && _user != null) {
      // Render langsung dashboard agar tidak ada flicker LoginPage.
      // Jika dibuka dari notifikasi, halaman detail akan di-push di atas dashboard.
      return DashboardPage(user: _user!);
    }

    return const LoginPage();
  }
}
