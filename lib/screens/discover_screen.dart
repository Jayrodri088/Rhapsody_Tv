import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rhapsody_tv/screens/video_player_screen.dart';
import 'package:rhapsody_tv/screens/profile_screen.dart';
import 'package:rhapsody_tv/screens/channel_detail_screen.dart';
import 'package:rhapsody_tv/screens/category_detail_screen.dart';
import 'package:rhapsody_tv/screens/notification_detail_screen.dart';
import 'package:rhapsody_tv/screens/history_screen.dart';
import 'package:rhapsody_tv/providers/auth_provider.dart';
import 'package:rhapsody_tv/providers/channel_provider.dart';
import 'package:rhapsody_tv/providers/category_provider.dart';
import 'package:rhapsody_tv/providers/notification_provider.dart';
import 'package:rhapsody_tv/models/channel_model.dart';
import 'package:rhapsody_tv/models/category_model.dart';
import 'package:rhapsody_tv/models/notification_model.dart';
import 'package:rhapsody_tv/services/notification_polling_service.dart';
import 'package:rhapsody_tv/services/notification_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch channels, categories and notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChannelProvider>().fetchChannels();
      context.read<CategoryProvider>().fetchCategories();
      context.read<NotificationProvider>().fetchNotifications();
    });

    // Set up callback to refresh notifications when new ones arrive
    NotificationPollingService().setOnNewNotificationCallback(() {
      if (mounted) {
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top blue section with DISCOVER header and search
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0033FF),
                  const Color(0xFF0044FF),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and text
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/logo/logo.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DISCOVER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return Text(
                                    authProvider.user != null && authProvider.user!.name != null
                                        ? 'Welcome, ${authProvider.user!.name}!'
                                        : 'Find something new',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Notifications icon with badge
                        Consumer<NotificationProvider>(
                          builder: (context, notificationProvider, child) {
                            return GestureDetector(
                              onTap: () {
                                _showNotificationsModal(context);
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  if (notificationProvider.unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Text(
                                          '${notificationProvider.unreadCount > 9 ? '9+' : notificationProvider.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF0033FF),
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: Color(0xFF0033FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: Color(0xFF0033FF),
                            size: 24,
                          ),
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Color(0xFF0033FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Yellow wave divider
          Container(
            height: 30,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFC700),
                ],
              ),
            ),
          ),

          // Channels / Categories tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              indicatorColor: const Color(0xFFFFD700),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'CHANNELS'),
                Tab(text: 'CATEGORIES'),
              ],
            ),
          ),

          // Content area with channel cards - now swipeable!
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChannelsContent(),
                _buildCategoriesContent(),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF0033FF),
              const Color(0xFF0044FF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.explore, 'Discover', 0),
                _buildNavItem(Icons.history, 'History', 1),
                _buildNavItem(Icons.play_circle_outline, 'Live', 2),
                _buildNavItem(Icons.person_outline, 'Account', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          // Navigate to History screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HistoryScreen(),
            ),
          );
        } else if (index == 2) {
          // Navigate to Live stream (RhapsodyTV)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VideoPlayerScreen(
                channelName: 'RhapsodyTV',
                streamUrl: 'https://2nbyjxnbl53k-hls-live.5centscdn.com/RTV/59a49be6dc0f146c57cd9ee54da323b1.sdp/playlist.m3u8',
              ),
            ),
          );
        } else if (index == 3) {
          // Navigate to profile screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFFD700) : Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFD700) : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelsContent() {
    return Consumer<ChannelProvider>(
      builder: (context, channelProvider, child) {
        if (channelProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0033FF),
            ),
          );
        }

        if (channelProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  channelProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => channelProvider.fetchChannels(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final channels = channelProvider.channels.where((channel) {
          if (_searchQuery.isEmpty) return true;
          return channel.name.toLowerCase().contains(_searchQuery);
        }).toList();

        if (channels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.tv_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No channels available'
                      : 'No channels found',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => channelProvider.fetchChannels(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildChannelCard(channel),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesContent() {
    return Consumer2<CategoryProvider, ChannelProvider>(
      builder: (context, categoryProvider, channelProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0033FF),
            ),
          );
        }

        if (categoryProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  categoryProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => categoryProvider.fetchCategories(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final categories = categoryProvider.categories;

        if (categories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No categories available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => categoryProvider.fetchCategories(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final channelsInCategory = channelProvider.getChannelsByCategory(category.slug);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCategoryCard(category, channelsInCategory),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChannelCard(Channel channel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChannelDetailScreen(channel: channel),
          ),
        );
      },
      child: Container(
        height: channel.isFeatured ? 200 : 150,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background with thumbnail or gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: channel.thumbnail != null
                    ? Stack(
                        children: [
                          Image.network(
                            channel.thumbnail!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black54,
                                      Colors.black87,
                                    ],
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black54,
                                      Colors.black87,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black54,
                              Colors.black87,
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            // Live badge
            if (channel.isLive)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 8,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Featured badge
            if (channel.isFeatured)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'FEATURED',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Channel title
            Center(
              child: Text(
                channel.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: channel.isFeatured ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category, List<Channel> channels) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
          ),
        );
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0033FF),
                      ),
                    ),
                    Text(
                      '${channels.length} ${channels.length == 1 ? 'channel' : 'channels'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF0033FF),
                size: 20,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0033FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    if (notificationProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0033FF),
                        ),
                      );
                    }

                    if (notificationProvider.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              notificationProvider.errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final notifications = notificationProvider.notifications;

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(notifications[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return GestureDetector(
      onTap: () async {
        // Mark as read
        context.read<NotificationProvider>().markAsRead(notification.id);

        // Update badge count (decrement)
        final unreadCount = context.read<NotificationProvider>().unreadCount;
        await NotificationService().updateBadge(unreadCount);

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailScreen(notification: notification),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFEFF0FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF0033FF).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.transparent : const Color(0xFF0033FF),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
