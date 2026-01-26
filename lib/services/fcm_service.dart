import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/fcm_token_service.dart';
import '../utils/notification_helper.dart';

/// Service untuk mengelola FCM (Firebase Cloud Messaging)
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi FCM Service
  /// - Meminta izin notifikasi
  /// - Mengambil dan menyimpan token ke Laravel
  /// - Setup listener untuk pesan foreground
  static Future<void> initialize() async {
    try {
      // 1. Inisialisasi Local Notifications
      await NotificationHelper.initialize(_localNotifications);

      // 2. Meminta izin notifikasi (wajib untuk Android 13+)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission untuk notifikasi');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined atau belum memberikan izin notifikasi');
        return;
      }

      // 3. Mengambil FCM Token dan kirim ke Laravel
      await _getAndSaveToken();

      // 4. Setup listener untuk pesan foreground
      _setupForegroundMessageListener();

      // 5. Handle token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        FCMTokenService.saveTokenToLaravel(newToken);
      });

      // 6. Handle notifikasi saat app dibuka dari terminated state
      _handleInitialMessage();
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Mengambil FCM Token dan mengirim ke Laravel
  static Future<void> _getAndSaveToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        // Kirim token ke Laravel untuk disimpan di database
        await FCMTokenService.saveTokenToLaravel(token);
      } else {
        print('FCM Token tidak tersedia');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Setup listener untuk menangani pesan saat aplikasi sedang dibuka (foreground)
  static void _setupForegroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Pesan foreground diterima: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // Tampilkan notifikasi lokal saat aplikasi sedang dibuka
      if (message.notification != null) {
        NotificationHelper.showNotification(
          _localNotifications,
          id: message.hashCode,
          title: message.notification!.title ?? 'Notifikasi',
          body: message.notification!.body ?? '',
          payload: message.data.toString(),
        );
      }
    });
  }

  /// Handle notifikasi saat aplikasi dibuka dari terminated state
  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('App dibuka dari terminated state via notifikasi');
      print('Title: ${initialMessage.notification?.title}');
      print('Body: ${initialMessage.notification?.body}');
      print('Data: ${initialMessage.data}');
      // Di sini bisa handle navigasi atau action berdasarkan data notifikasi
    }
  }

  /// Subscribe ke topic tertentu (opsional)
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe dari topic (opsional)
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Get current FCM token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
}
