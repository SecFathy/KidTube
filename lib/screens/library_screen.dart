import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'parent_login_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Profile section
              const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.teal,
                child: Text('K',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kid',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '@kid',
                style: TextStyle(color: AppColors.ytGrey, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // History section
              _buildSection(
                context,
                icon: Icons.history,
                title: 'History',
                subtitle: '${provider.allVideos.length} videos available',
              ),
              _buildSection(
                context,
                icon: Icons.play_circle_outline,
                title: 'Your videos',
                subtitle: 'No videos',
              ),
              _buildSection(
                context,
                icon: Icons.download_outlined,
                title: 'Downloads',
                subtitle: 'No downloads',
              ),

              const Divider(color: AppColors.ytDarkSurface, height: 32),

              // Shorts section label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 22,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.ytRed, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.play_arrow,
                          size: 12, color: AppColors.ytRed),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Shorts',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.shorts.length}',
                      style:
                          const TextStyle(color: AppColors.ytGrey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              const Divider(color: AppColors.ytDarkSurface, height: 32),

              // Parent access (hidden)
              GestureDetector(
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ParentLoginScreen()),
                  );
                },
                child: _buildSection(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: '',
                ),
              ),
              _buildSection(
                context,
                icon: Icons.help_outline,
                title: 'Help & feedback',
                subtitle: '',
              ),

              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: AppColors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(color: AppColors.ytGrey, fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.ytGrey, size: 20),
    );
  }
}
