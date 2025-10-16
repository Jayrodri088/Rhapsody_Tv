import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String channelName;
  final String streamUrl;
  final String? thumbnailUrl;

  const VideoPlayerScreen({
    super.key,
    required this.channelName,
    required this.streamUrl,
    this.thumbnailUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  int _selectedTab = 0;
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoadingComments = false;
  bool _isSendingComment = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadComments();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadComments();
    });
    // Track viewing history initially and every 30 seconds
    _trackViewingHistory();
    Timer.periodic(const Duration(seconds: 30), (_) {
      _trackViewingHistory();
    });
  }

  Future<void> _trackViewingHistory() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        await ApiService.addToViewingHistory(
          token: user.token,
          contentId: widget.streamUrl,
          contentType: 'channel',
          contentTitle: widget.channelName,
          thumbnailUrl: widget.thumbnailUrl,
        );
      }
    } catch (e) {
      debugPrint('Failed to track viewing history: $e');
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.streamUrl),
    );

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFFFD700),
        handleColor: const Color(0xFFFFD700),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white70,
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFD700),
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );

    setState(() {});
  }

  Future<void> _loadComments() async {
    if (_isLoadingComments) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final response = await ApiService.getComments();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _comments = response['data']['comments'] ?? [];
          _isLoadingComments = false;
        });
      } else {
        setState(() {
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      debugPrint('Error loading comments: $e');
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSendingComment = true;
    });

    try {
      final response = await ApiService.addComment(
        userId: user.id,
        username: user.name ?? user.email.split('@')[0],
        comment: _commentController.text.trim(),
      );

      if (response['success'] == true) {
        _commentController.clear();
        await _loadComments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment posted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to post comment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally{
      if (mounted) {
        setState(() {
          _isSendingComment = false;
        });
      }
    }
  }

  String _getTimeAgo(String createdAt) {
    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(created);

      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0033FF),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Now Watching',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    widget.channelName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/logo/logo.png',
              width: 35,
              height: 35,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
              aspectRatio: 16 / 9,
              child: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ),
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade800,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTab('Comments', 0),
                  _buildTab('Donate', 1),
                  _buildTab('Salvation', 2),
                ],
              ),
          ),
          Expanded(
            child: Container(
              color: Colors.black87,
              child: _selectedTab == 0
                  ? _buildCommentsSection()
                  : _selectedTab == 1
                      ? _buildDonateSection()
                      : _buildSalvationSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 60,
            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade800,
                width: 1,
              ),
            ),
          ),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey,
                      child: user != null && user.name != null
                          ? Text(
                              user.name![0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.person, size: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Add Comments',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isSendingComment
                          ? Colors.grey
                          : const Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSendingComment
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Color(0xFF0033FF)),
                      onPressed: _isSendingComment ? null : _sendComment,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: _isLoadingComments && _comments.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD700),
                  ),
                )
              : _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Be the first to comment!',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFFFFD700),
                      onRefresh: _loadComments,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentItem(
                            '@${comment['username'] ?? 'Anonymous'}',
                            _getTimeAgo(comment['created_at'] ?? ''),
                            comment['comment'] ?? '',
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(String username, String time, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0033FF),
                  const Color(0xFFFFD700),
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Text(
                username.length > 1 ? username[1].toUpperCase() : 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonateSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Support Our Ministry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your donations help us spread the gospel\nand reach more souls worldwide',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Donation options coming soon'),
                    backgroundColor: Color(0xFF0033FF),
                  ),
                );
              },
              child: const Text(
                'Donate Now',
                style: TextStyle(
                  color: Color(0xFF0033FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalvationSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Salvation Prayer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Make Jesus the Lord of your life today',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 2,
              ),
            ),
            child: const Text(
              'Dear Lord Jesus,\n\n'
              'I come to You today and I confess that You are the Son of God. '
              'You died for my sins and rose again from the dead.\n\n'
              'I accept You as my Lord and Savior. I believe in my heart and confess '
              'with my mouth that Jesus is Lord, and I am saved!\n\n'
              'Thank You Lord for saving me. Amen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey.shade900,
                  title: const Text(
                    'Welcome to the Family!',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    'Congratulations on making the most important decision of your life! '
                    'We celebrate with you and look forward to seeing you grow in Christ.',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Amen!',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'I Prayed This Prayer',
              style: TextStyle(
                color: Color(0xFF0033FF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
