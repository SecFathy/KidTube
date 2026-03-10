import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video_item.dart';
import '../utils/constants.dart';

class ShortsPlayerScreen extends StatefulWidget {
  final List<VideoItem> shorts;
  final int initialIndex;

  const ShortsPlayerScreen({
    super.key,
    required this.shorts,
    required this.initialIndex,
  });

  @override
  State<ShortsPlayerScreen> createState() => _ShortsPlayerScreenState();
}

class _ShortsPlayerScreenState extends State<ShortsPlayerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, YoutubePlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initController(_currentIndex);
  }

  YoutubePlayerController _initController(int index) {
    if (!_controllers.containsKey(index)) {
      _controllers[index] = YoutubePlayerController(
        initialVideoId: widget.shorts[index].youtubeVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
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
    _controllers[_currentIndex]?.pause();
    setState(() => _currentIndex = index);
    _initController(index);
    _controllers[index]?.play();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.shorts.length,
            itemBuilder: (context, index) {
              final video = widget.shorts[index];
              final controller = _initController(index);

              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black),
                  // Video player
                  Center(
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: YoutubePlayer(
                        controller: controller,
                        showVideoProgressIndicator: false,
                      ),
                    ),
                  ),
                  // Right side actions
                  Positioned(
                    right: 12,
                    bottom: 100,
                    child: Column(
                      children: [
                        _buildSideAction(Icons.thumb_up_outlined, 'Like'),
                        const SizedBox(height: 24),
                        _buildSideAction(
                            Icons.thumb_down_outlined, 'Dislike'),
                        const SizedBox(height: 24),
                        _buildSideAction(Icons.comment_outlined, '0'),
                        const SizedBox(height: 24),
                        _buildFlippedAction(Icons.reply, 'Share'),
                        const SizedBox(height: 24),
                        _buildSideAction(Icons.graphic_eq, 'Remix'),
                        const SizedBox(height: 24),
                        // Music disc
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    AppColors.ytGrey.withValues(alpha: 0.5),
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
                              backgroundImage:
                                  video.channelAvatarUrl.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          video.channelAvatarUrl)
                                      : null,
                              child: video.channelAvatarUrl.isEmpty
                                  ? Text(
                                      video.channelName.isNotEmpty
                                          ? video.channelName[0]
                                              .toUpperCase()
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
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
                        Row(
                          children: [
                            const Icon(Icons.music_note,
                                color: Colors.white, size: 12),
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
                  // Progress bar at bottom
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
                          child: Container(color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Shorts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search,
                      color: Colors.white, size: 24),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white, size: 24),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFlippedAction(IconData icon, String label) {
    return Column(
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(-1.0, 1.0),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
