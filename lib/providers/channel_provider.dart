import 'package:flutter/material.dart';
import '../models/channel_model.dart';
import '../services/api_service.dart';

class ChannelProvider with ChangeNotifier {
  List<Channel> _channels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Channel> get channels => _channels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Channel> get liveChannels =>
      _channels.where((channel) => channel.isLive).toList();

  List<Channel> get featuredChannels =>
      _channels.where((channel) => channel.isFeatured).toList();

  List<Channel> getChannelsByCategory(String category) {
    return _channels.where((channel) => channel.category == category).toList();
  }

  Future<void> fetchChannels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.getChannels();

      if (response['success'] == true) {
        final channelsData = response['data']['channels'] as List;
        _channels = channelsData.map((json) => Channel.fromJson(json)).toList();

        // Sort by order
        _channels.sort((a, b) => a.order.compareTo(b.order));

        _errorMessage = null;
      } else {
        _errorMessage = response['message'] ?? 'Failed to load channels';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Channel? getChannelById(String id) {
    try {
      return _channels.firstWhere((channel) => channel.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearChannels() {
    _channels = [];
    _errorMessage = null;
    notifyListeners();
  }
}
