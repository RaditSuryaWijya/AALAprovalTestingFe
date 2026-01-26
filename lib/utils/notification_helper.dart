import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Helper untuk menampilkan notifikasi lokal saat aplikasi sedang dibuka (foreground)
class NotificationHelper {
  /// Inisialisasi Local Notifications
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin localNotifications) async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings (opsional, jika nanti support iOS)
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
  static Future<void> _createNotificationChannel(
      FlutterLocalNotificationsPlugin localNotifications) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'approval_notifications', // id
      'Approval Notifications', // name
      description: 'Notifikasi untuk approval request', // description
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Menampilkan notifikasi lokal
  static Future<void> showNotification(
    FlutterLocalNotificationsPlugin localNotifications, {
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'approval_notifications', // channel id (harus sama dengan channel)
      'Approval Notifications', // channel name
      channelDescription: 'Notifikasi untuk approval request',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
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
    // Di sini bisa handle navigasi berdasarkan payload
    // Contoh: jika payload berisi route, bisa navigate ke halaman tersebut
  }
}
