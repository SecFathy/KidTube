import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/video_card.dart';
import '../widgets/shorts_card.dart';
import 'video_player_screen.dart';
import 'shorts_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedChip = 0;
  final List<String> _chips = [
    'All',
    'Music',
    'Gaming',
    'Recently uploaded',
    'Watched',
    'New to you',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          color: AppColors.ytRed,
          backgroundColor: AppColors.ytDarkSurface,
          onRefresh: () => provider.loadAllData(),
          child: CustomScrollView(
            slivers: [
              // Filter chips bar
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.ytDarkBg,
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _chips.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedChip == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedChip = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.ytChipBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _chips[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : AppColors.white,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.ytRed),
                  ),
                )
              // Empty state
              else if (provider.allVideos.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline,
                            size: 72, color: AppColors.ytGrey),
                        const SizedBox(height: 16),
                        const Text(
                          'No videos yet',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ask your parent to add some videos!',
                          style: TextStyle(
                              color: AppColors.ytGrey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              // Content
              else ...[
                // Regular video cards (first batch)
                if (provider.regularVideos.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Insert Shorts shelf after 2 videos
                        if (index == 2 && provider.shorts.isNotEmpty) {
                          return _buildShortsShelf(provider);
                        }

                        // Adjust index for the shorts shelf insertion
                        final videoIndex = (index > 2 && provider.shorts.isNotEmpty)
                            ? index - 1
                            : index;

                        if (videoIndex >= provider.regularVideos.length) {
                          return const SizedBox.shrink();
                        }

                        final video = provider.regularVideos[videoIndex];
                        return VideoCard(
                          video: video,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayerScreen(video: video),
                              ),
                            );
                          },
                        );
                      },
                      childCount: provider.regularVideos.length +
                          (provider.shorts.isNotEmpty ? 1 : 0),
                    ),
                  ),

                // If only shorts and no regular videos
                if (provider.regularVideos.isEmpty &&
                    provider.shorts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildShortsShelf(provider),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  // YouTube-style Shorts shelf
  Widget _buildShortsShelf(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top divider
        Container(
          height: 4,
          color: AppColors.ytDarkSurface,
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              // Shorts icon
              Container(
                width: 22,
                height: 26,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.ytRed, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.play_arrow,
                    size: 14, color: AppColors.ytRed),
              ),
              const SizedBox(width: 8),
              const Text(
                'Shorts',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        // Shorts horizontal list
        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: provider.shorts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 160,
                  child: Column(
                    children: [
                      Expanded(
                        child: ShortsCard(
                          video: provider.shorts[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShortsPlayerScreen(
                                  shorts: provider.shorts,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Bottom divider
        Container(
          height: 4,
          color: AppColors.ytDarkSurface,
        ),
      ],
    );
  }
}
