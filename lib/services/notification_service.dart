import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _badgeCount = 0;

  Future<void> initialize() async {
    if (_initialized) return;

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        // Can add custom handlers here if needed
      },
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    // Request notification permission
    final status = await Permission.notification.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // User denied permission - just return false, don't open settings
      return false;
    } else if (status.isPermanentlyDenied) {
      // User permanently denied - just return false, don't auto-open settings
      // Only open settings if user explicitly requests it from app settings
      return false;
    }

    return false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    int? badgeNumber,
  }) async {
    // Increment badge count
    _badgeCount++;

    final notificationDetails = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        badgeNumber: badgeNumber ?? _badgeCount,
        // Important: These settings ensure notification shows in all states
        interruptionLevel: InterruptionLevel.active,
      ),
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
    );

    // Update app badge
    await updateBadge(badgeNumber ?? _badgeCount);
  }

  /// Update app badge count
  Future<void> updateBadge(int count) async {
    try {
      if (count > 0) {
        await FlutterAppBadger.updateBadgeCount(count);
      } else {
        await FlutterAppBadger.removeBadge();
      }
      _badgeCount = count;
    } catch (e) {
      print('Error updating badge: $e');
    }
  }

  /// Clear app badge
  Future<void> clearBadge() async {
    try {
      await FlutterAppBadger.removeBadge();
      _badgeCount = 0;
    } catch (e) {
      print('Error clearing badge: $e');
    }
  }

  /// Get current badge count
  int get badgeCount => _badgeCount;
}
