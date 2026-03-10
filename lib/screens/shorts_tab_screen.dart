import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../models/video_item.dart';
import '../utils/constants.dart';

class ShortsTabScreen extends StatefulWidget {
  const ShortsTabScreen({super.key});

  @override
  State<ShortsTabScreen> createState() => _ShortsTabScreenState();
}

class _ShortsTabScreenState extends State<ShortsTabScreen>
    with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  int _currentPage = 0;
  final Map<int, YoutubePlayerController> _controllers = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  YoutubePlayerController _getController(VideoItem video, int index) {
    if (!_controllers.containsKey(index)) {
      _controllers[index] = YoutubePlayerController(
        initialVideoId: video.youtubeVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: true,
          hideControls: true,
          showLiveFullscreenButton: false,
          controlsVisibleAtStart: false,
        ),
      );
    }
    return _controllers[index]!;
  }

  void _onPageChanged(int index) {
    _controllers[_currentPage]?.pause();
    setState(() => _currentPage = index);
    _controllers[index]?.play();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.shorts.isEmpty) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline,
                      size: 72, color: AppColors.ytGrey),
                  SizedBox(height: 16),
                  Text('No Shorts yet',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text('Ask your parent to add some Shorts!',
                      style: TextStyle(
                          color: AppColors.ytGrey, fontSize: 14)),
                ],
              ),
            ),
          );
        }

        return Container(
          color: Colors.black,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: provider.shorts.length,
            itemBuilder: (context, index) {
              final video = provider.shorts[index];
              return _ShortsPage(
                video: video,
                controller: _getController(video, index),
                isActive: index == _currentPage,
              );
            },
          ),
        );
      },
    );
  }
}

class _ShortsPage extends StatelessWidget {
  final VideoItem video;
  final YoutubePlayerController controller;
  final bool isActive;

  const _ShortsPage({
    required this.video,
    required this.controller,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.play();
      });
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Black background
        Container(color: Colors.black),

        // Video player centered
        Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: false,
            ),
          ),
        ),

        // Right side action buttons (YouTube Shorts style)
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              // Like
              _ActionButton(
                icon: Icons.thumb_up_outlined,
                label: 'Like',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Dislike
              _ActionButton(
                icon: Icons.thumb_down_outlined,
                label: 'Dislike',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Comment
              _ActionButton(
                icon: Icons.comment_outlined,
                label: '0',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Share
              _ActionButton(
                icon: Icons.reply,
                label: 'Share',
                isFlipped: true,
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Remix
              _ActionButton(
                icon: Icons.graphic_eq,
                label: 'Remix',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Rotating music disc
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.ytGrey.withValues(alpha: 0.5),
                      width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: video.channelAvatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: video.channelAvatarUrl,
                          fit: BoxFit.cover)
                      : Container(
                          color: AppColors.ytDarkSurface,
                          child: const Icon(Icons.music_note,
                              color: AppColors.white, size: 16),
                        ),
                ),
              ),
            ],
          ),
        ),

        // Bottom info
        Positioned(
          left: 12,
          right: 68,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Channel + Subscribe
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.ytDarkSurface,
                    backgroundImage: video.channelAvatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(video.channelAvatarUrl)
                        : null,
                    child: video.channelAvatarUrl.isEmpty
                        ? Text(
                            video.channelName.isNotEmpty
                                ? video.channelName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '@${video.channelName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Subscribe button
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.ytSubscribeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Subscribe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Video title
              Text(
                video.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              // Audio info
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${video.channelName} \u00B7 Original audio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Progress bar at very bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 2,
            color: Colors.white.withValues(alpha: 0.2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.3,
                child: Container(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isFlipped;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isFlipped = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: isFlipped
                ? (Matrix4.identity()..scale(-1.0, 1.0))
                : Matrix4.identity(),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
