import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class NotificationPollingService {
  static final NotificationPollingService _instance = NotificationPollingService._internal();
  factory NotificationPollingService() => _instance;
  NotificationPollingService._internal();

  Timer? _pollingTimer;
  Set<String> _seenNotificationIds = {};
  bool _isPolling = false;
  Function? _onNewNotification;

  /// Set callback to be called when new notification arrives
  void setOnNewNotificationCallback(Function callback) {
    _onNewNotification = callback;
  }

  /// Start polling for new notifications every 10 seconds
  Future<void> startPolling() async {
    if (_isPolling) return;

    _isPolling = true;

    // Load previously seen notification IDs
    await _loadSeenNotifications();

    // Update badge count on startup
    await _updateBadgeFromBackend();

    // Poll immediately
    await _checkForNewNotifications();

    // Then poll every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkForNewNotifications();
    });
  }

  /// Update badge count based on backend notifications (called on startup)
  Future<void> _updateBadgeFromBackend() async {
    try {
      final response = await ApiService.getNotifications();

      if (response['success'] == true) {
        final notificationsData = response['data']['notifications'] as List;

        // Count unread notifications (those not in read list, not seen list)
        final prefs = await SharedPreferences.getInstance();
        final readIds = prefs.getStringList('read_notifications') ?? [];
        final readSet = readIds.toSet();

        final unreadCount = notificationsData.where((n) => !readSet.contains(n['id'])).length;

        // Update badge with unread count
        await NotificationService().updateBadge(unreadCount);
      }
    } catch (e) {
      print('Error updating badge on startup: $e');
    }
  }

  /// Stop polling for notifications
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  Future<void> _loadSeenNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIds = prefs.getStringList('seen_notifications') ?? [];
    _seenNotificationIds = seenIds.toSet();
  }

  Future<void> _saveSeenNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('seen_notifications', _seenNotificationIds.toList());
  }

  Future<void> _checkForNewNotifications() async {
    try {
      final response = await ApiService.getNotifications();

      if (response['success'] == true) {
        final notificationsData = response['data']['notifications'] as List;

        // Load read notifications to calculate unread count
        final prefs = await SharedPreferences.getInstance();
        final readIds = prefs.getStringList('read_notifications') ?? [];
        final readSet = readIds.toSet();

        // Calculate unread count (based on read status, not seen status)
        final unreadCount = notificationsData.where((n) => !readSet.contains(n['id'])).length;

        for (var notificationJson in notificationsData) {
          final id = notificationJson['id'] as String;

          // If this is a new notification we haven't seen before (to show push notification)
          if (!_seenNotificationIds.contains(id)) {
            // Show push notification
            final title = notificationJson['title'] as String? ?? 'New Notification';
            final message = notificationJson['message'] as String? ?? '';

            await NotificationService().showNotification(
              id: id.hashCode,
              title: title,
              body: message,
              badgeNumber: unreadCount,
            );

            // Mark as seen (so we don't show the push notification again)
            _seenNotificationIds.add(id);

            // Trigger callback if set
            if (_onNewNotification != null) {
              _onNewNotification!();
            }
          }
        }

        // Save updated seen IDs
        await _saveSeenNotifications();

        // Always update badge with total unread count (based on read status)
        await NotificationService().updateBadge(unreadCount);
      }
    } catch (e) {
      // Silently fail - don't interrupt the app
      print('Error checking for new notifications: $e');
    }
  }

  /// Clear all seen notification history (useful for testing or reset)
  Future<void> clearSeenNotifications() async {
    _seenNotificationIds.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('seen_notifications');
  }
}
