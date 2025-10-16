import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rhapsody_tv/providers/auth_provider.dart';
import 'package:rhapsody_tv/services/api_service.dart';
import 'package:rhapsody_tv/screens/video_player_screen.dart';
import 'package:rhapsody_tv/screens/sign_in_screen.dart';
import 'dart:async';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Auto-refresh every 10 seconds to update timestamps
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    // Only show loading spinner if history is empty (first load)
    if (_history.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        setState(() {
          _errorMessage = 'Please login to view history';
          _isLoading = false;
        });
        return;
      }

      if (user.token.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid authentication token. Please login again.';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getViewingHistory(
        token: user.token,
        limit: 50,
      );

      if (response['success'] == true) {
        setState(() {
          _history = response['data']['history'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load history';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading history: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0033FF),
        title: const Text(
          'Watch History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0033FF),
        ),
      );
    }

    if (_errorMessage != null) {
      // Check if it's an authentication error
      final isAuthError = _errorMessage!.toLowerCase().contains('login') ||
                          _errorMessage!.toLowerCase().contains('unauthorized') ||
                          _errorMessage!.toLowerCase().contains('token');

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthError ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: isAuthError ? const Color(0xFF0033FF) : Colors.red,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                isAuthError
                    ? 'Please login to view your watch history'
                    : _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isAuthError ? Colors.black87 : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isAuthError)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  ).then((_) => _loadHistory());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0033FF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Login Now',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              ElevatedButton(
                onPressed: _loadHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0033FF),
                ),
                child: const Text('Retry'),
              ),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No viewing history yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start watching channels to build your history',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildHistoryItem(item),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(dynamic item) {
    final contentTitle = item['content_title'] ?? 'Unknown';
    final contentType = item['content_type'] ?? 'video';
    final lastWatched = item['last_watched'] ?? '';
    final watchCount = item['watch_count'] ?? 1;
    final progressPercentage = item['progress_percentage'] ?? 0;
    final thumbnailUrl = item['thumbnail_url'];

    return GestureDetector(
      onTap: () {
        // For now, navigate to video player if it's a channel
        if (contentType == 'channel' || contentType == 'video') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                streamUrl: item['content_id'] ?? '',
                channelName: contentTitle,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFF0FF), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 75,
                    color: const Color(0xFF0033FF).withOpacity(0.1),
                    child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                contentType == 'channel'
                                    ? Icons.live_tv
                                    : Icons.play_circle_outline,
                                color: const Color(0xFF0033FF),
                                size: 32,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF0033FF),
                                ),
                              );
                            },
                          )
                        : Icon(
                            contentType == 'channel'
                                ? Icons.live_tv
                                : Icons.play_circle_outline,
                            color: const Color(0xFF0033FF),
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contentTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0033FF),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (lastWatched.isNotEmpty)
                        Text(
                          _formatDate(lastWatched),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF0033FF),
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      // Parse the date string and convert to local time if needed
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 30) {
        return 'Just now';
      } else if (difference.inMinutes < 1) {
        return '${difference.inSeconds} sec ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hr ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      debugPrint('Error parsing date: $dateStr - Error: $e');
      return dateStr;
    }
  }
}
