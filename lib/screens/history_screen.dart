import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rhapsody_tv/providers/auth_provider.dart';
import 'package:rhapsody_tv/services/api_service.dart';
import 'package:rhapsody_tv/screens/video_player_screen.dart';
import 'package:rhapsody_tv/screens/sign_in_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0033FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    contentType == 'channel'
                        ? Icons.live_tv
                        : Icons.play_circle_outline,
                    color: const Color(0xFF0033FF),
                    size: 28,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDate(lastWatched),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF0FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        size: 14,
                        color: Color(0xFF0033FF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Watched $watchCount ${watchCount == 1 ? 'time' : 'times'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0033FF),
                        ),
                      ),
                    ],
                  ),
                ),
                if (progressPercentage > 0 && progressPercentage < 100) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timelapse,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${progressPercentage.toInt()}% watched',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
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
      return dateStr;
    }
  }
}
