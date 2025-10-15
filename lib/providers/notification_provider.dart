import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  Set<String> _readNotificationIds = {};

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load read notification IDs from storage
      await _loadReadNotifications();

      final response = await ApiService.getNotifications();

      if (response['success'] == true) {
        final notificationsData = response['data']['notifications'] as List;
        _notifications = notificationsData
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Mark notifications as read if they're in the read set
        for (var notification in _notifications) {
          notification.isRead = _readNotificationIds.contains(notification.id);
        }

        _errorMessage = null;
      } else {
        _errorMessage = response['message'] ?? 'Failed to load notifications';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList('read_notifications') ?? [];
    _readNotificationIds = readIds.toSet();
  }

  Future<void> markAsRead(String notificationId) async {
    _readNotificationIds.add(notificationId);

    // Update in memory
    final notification = _notifications.firstWhere(
      (n) => n.id == notificationId,
      orElse: () => _notifications.first,
    );
    notification.isRead = true;

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', _readNotificationIds.toList());

    notifyListeners();
  }

  void clearNotifications() {
    _notifications = [];
    _errorMessage = null;
    notifyListeners();
  }
}
