import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_router.dart';

/// Helper untuk menampilkan notifikasi lokal saat aplikasi sedang dibuka (foreground)
class NotificationHelper {
  /// Inisialisasi Local Notifications
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin localNotifications) async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings untuk kedua platform
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inisialisasi plugin
    await localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Buat notification channel untuk Android 8.0+
    await _createNotificationChannel(localNotifications);
  }

  /// Membuat notification channel untuk Android
  /// Menggunakan Importance.max untuk heads-up notification (muncul di atas layar)
  static Future<void> _createNotificationChannel(
      FlutterLocalNotificationsPlugin localNotifications) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'approval_notifications', // id
      'Approval Notifications', // name
      description: 'Notifikasi untuk approval request', // description
      importance: Importance.max, // MAX untuk heads-up notification
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Menampilkan notifikasi lokal
  /// Menggunakan priority MAX untuk heads-up notification (muncul di atas layar)
  static Future<void> showNotification(
    FlutterLocalNotificationsPlugin localNotifications, {
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'approval_notifications', // channel id (harus sama dengan channel)
      'Approval Notifications', // channel name
      channelDescription: 'Notifikasi untuk approval request',
      importance: Importance.max, // MAX untuk heads-up notification
      priority: Priority.max, // MAX untuk heads-up notification
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true, // Muncul di atas layar saat app tertutup
      category: AndroidNotificationCategory.message, // Kategori message untuk heads-up
      styleInformation: BigTextStyleInformation(body), // Style untuk notifikasi panjang
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
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Handler ketika notifikasi di-tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notifikasi di-tap: ${response.payload}');
    // Arahkan berdasarkan payload JSON (type/id)
    NotificationRouter.handlePayload(response.payload);
  }
}
