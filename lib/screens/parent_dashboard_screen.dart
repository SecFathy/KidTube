import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'manage_videos_screen.dart';
import 'manage_channels_screen.dart';
import 'search_add_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ytDarkBg,
      appBar: AppBar(
        backgroundColor: AppColors.ytDarkBg,
        title: const Text('Parent Dashboard',
            style: TextStyle(color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            Provider.of<AppProvider>(context, listen: false).exitParentMode();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                Row(
                  children: [
                    _buildStatCard(
                      'Videos',
                      '${provider.allVideos.length}',
                      Icons.play_circle_outline,
                      AppColors.ytRed,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageVideosScreen()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Shorts',
                      '${provider.shorts.length}',
                      Icons.flash_on,
                      Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageVideosScreen()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Channels',
                      '${provider.allowedChannels.length}',
                      Icons.people_outline,
                      Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageChannelsScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                _buildActionTile(
                  context,
                  Icons.add_circle_outline,
                  'Add Video by URL',
                  'Paste a YouTube video URL to add it',
                  () => _showAddVideoDialog(context),
                ),
                _buildActionTile(
                  context,
                  Icons.search,
                  'Search & Add Videos',
                  'Search YouTube and approve videos',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchAddScreen()),
                  ),
                ),
                _buildActionTile(
                  context,
                  Icons.playlist_add,
                  'Add Channel',
                  'Add all videos from a YouTube channel',
                  () => _showAddChannelDialog(context),
                ),
                _buildActionTile(
                  context,
                  Icons.video_library,
                  'Manage Videos',
                  'View and remove approved videos',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageVideosScreen()),
                  ),
                ),
                _buildActionTile(
                  context,
                  Icons.people,
                  'Manage Channels',
                  'Allow or block channels',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageChannelsScreen()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.ytDarkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: AppColors.ytGrey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.ytDarkSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.ytRed, size: 24),
      ),
      title: Text(title,
          style: const TextStyle(color: AppColors.white, fontSize: 15)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: AppColors.ytGrey, fontSize: 12)),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.ytGrey, size: 20),
      onTap: onTap,
    );
  }

  void _showAddVideoDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ytDarkSurface,
        title: const Text('Add Video',
            style: TextStyle(color: AppColors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste a YouTube video URL:',
              style: TextStyle(color: AppColors.ytGrey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'https://youtube.com/watch?v=...',
                hintStyle: const TextStyle(color: AppColors.ytGrey),
                filled: true,
                fillColor: AppColors.ytDarkBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.ytGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider =
                  Provider.of<AppProvider>(context, listen: false);
              final video = await provider.addVideoByUrl(controller.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(video != null
                        ? 'Video added: ${video.title}'
                        : 'Failed to add video. Check URL.'),
                    backgroundColor:
                        video != null ? Colors.green : AppColors.ytRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ytRed),
            child: const Text('Add', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddChannelDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ytDarkSurface,
        title: const Text('Add Channel',
            style: TextStyle(color: AppColors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste a YouTube channel URL:',
              style: TextStyle(color: AppColors.ytGrey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'https://youtube.com/@channel',
                hintStyle: const TextStyle(color: AppColors.ytGrey),
                filled: true,
                fillColor: AppColors.ytDarkBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.ytGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider =
                  Provider.of<AppProvider>(context, listen: false);
              final channel =
                  await provider.addChannelByUrl(controller.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(channel != null
                        ? 'Channel added: ${channel.name}'
                        : 'Failed to add channel. Check URL.'),
                    backgroundColor:
                        channel != null ? Colors.green : AppColors.ytRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ytRed),
            child: const Text('Add', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ytDarkSurface,
        title: const Text('Change PIN',
            style: TextStyle(color: AppColors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a new 4-6 digit PIN:',
              style: TextStyle(color: AppColors.ytGrey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.white, fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.ytDarkBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.ytGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newPin = controller.text.trim();
              if (newPin.length >= 4) {
                Provider.of<AppProvider>(context, listen: false)
                    .setParentPin(newPin);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ytRed),
            child:
                const Text('Update', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
