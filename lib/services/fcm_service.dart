import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:convert';
import '../services/fcm_token_service.dart';
import '../utils/notification_helper.dart';
import '../utils/storage_helper.dart';
import 'notification_router.dart';

/// Service untuk mengelola FCM (Firebase Cloud Messaging)
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi FCM Service
  /// - Meminta izin notifikasi
  /// - Mengambil dan menyimpan token ke Laravel
  /// - Setup listener untuk pesan foreground
  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    try {
      // Set navigatorKey untuk routing dari notifikasi
      NotificationRouter.navigatorKey = navigatorKey;

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

      // 3. Mengambil device info dan FCM Token
      await _getDeviceInfoAndSaveToken();

      // 4. Setup listener untuk pesan foreground
      _setupForegroundMessageListener();

      // 4b. Listener saat user tap notifikasi (FCM) dan app terbuka dari background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notifikasi di-tap (FCM): ${message.messageId}');
        NotificationRouter.handleMessageData(message.data);
      });

      // 5. Handle token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        print('FCM Token refreshed: $newToken');
        // Ambil device info yang sudah tersimpan atau ambil ulang
        final deviceName = await StorageHelper.getDeviceName() ?? await _getDeviceName();
        final deviceId = await StorageHelper.getOrCreateDeviceId();
        await FCMTokenService.saveTokenToLaravel(newToken, deviceName: deviceName, deviceId: deviceId);
      });

      // 6. Handle notifikasi saat app dibuka dari terminated state
      // NOTE: Tidak dipanggil di sini, akan dipanggil dari AuthGate setelah auth check
      // _handleInitialMessage();
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Mengambil device info dan FCM Token, simpan di local storage
  /// Token akan dikirim ke Laravel setelah user login berhasil
  static Future<void> _getDeviceInfoAndSaveToken() async {
    try {
      // 1. Ambil device info
      final deviceName = await _getDeviceName();
      final deviceId = await StorageHelper.getOrCreateDeviceId();
      
      // Simpan device name
      await StorageHelper.saveDeviceName(deviceName);
      
      // 2. Ambil FCM Token
      String? token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        print('Device Name: $deviceName');
        print('Device ID: $deviceId');
        // Simpan token di local storage saja (belum kirim ke Laravel)
        // Token akan dikirim ke Laravel setelah user login berhasil
        await StorageHelper.saveFcmToken(token);
      } else {
        print('FCM Token tidak tersedia');
      }
    } catch (e) {
      print('Error getting device info and FCM token: $e');
    }
  }

  /// Mengambil device name berdasarkan platform
  static Future<String> _getDeviceName() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} (${iosInfo.model})';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      print('Error getting device name: $e');
      return 'Unknown Device';
    }
  }

  /// Kirim FCM token ke Laravel setelah user login berhasil
  /// Method ini dipanggil dari AuthService setelah login sukses
  static Future<void> sendTokenAfterLogin() async {
    try {
      // Ambil token dari local storage atau langsung dari Firebase
      String? token = await StorageHelper.getFcmToken();
      if (token == null) {
        // Jika belum ada di local, ambil dari Firebase
        token = await _messaging.getToken();
      }
      
      // Ambil device info
      String deviceName = await StorageHelper.getDeviceName() ?? await _getDeviceName();
      String deviceId = await StorageHelper.getOrCreateDeviceId();
      
      if (token != null) {
        print('Mengirim FCM token ke Laravel setelah login: $token');
        print('Device Name: $deviceName');
        print('Device ID: $deviceId');
        await FCMTokenService.saveTokenToLaravel(
          token,
          deviceName: deviceName,
          deviceId: deviceId,
        );
      } else {
        print('FCM Token tidak tersedia untuk dikirim ke Laravel');
      }
    } catch (e) {
      print('Error sendTokenAfterLogin: $e');
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
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  /// Handle notifikasi saat aplikasi dibuka dari terminated state
  /// Method ini dipanggil dari AuthGate setelah auth check selesai
  /// Returns true jika ada initial message yang di-handle
  static Future<bool> handleInitialMessage() async {
    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('App dibuka dari terminated state via notifikasi');
        print('Title: ${initialMessage.notification?.title}');
        print('Body: ${initialMessage.notification?.body}');
        print('Data: ${initialMessage.data}');
        
        // Delay sedikit untuk memastikan navigator sudah ready
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Handle navigasi berdasarkan data notifikasi (type/id)
        NotificationRouter.handleMessageData(initialMessage.data);
        return true; // Return true jika ada initial message
      }
      return false; // Return false jika tidak ada initial message
    } catch (e) {
      print('Error handling initial message: $e');
      return false;
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
