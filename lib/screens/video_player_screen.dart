import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/video_item.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/video_card.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _titleExpanded = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;

  // Streams fetched from youtube_explode
  List<MuxedStreamInfo> _streams = [];
  MuxedStreamInfo? _currentStream;

  final YoutubeExplode _yt = YoutubeExplode();

  @override
  void initState() {
    super.initState();
    _loadStreams();
  }

  Future<void> _loadStreams() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final manifest = await _yt.videos.streamsClient
          .getManifest(widget.video.youtubeVideoId);

      final streams = manifest.muxed.toList();
      streams.sort((a, b) =>
          a.videoResolution.height.compareTo(b.videoResolution.height));

      if (streams.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No streams available for this video.';
          _isLoading = false;
        });
        return;
      }

      // Pick stream based on saved quality preference
      final provider = context.read<AppProvider>();
      final savedQuality = provider.videoQuality;
      MuxedStreamInfo selected = streams.last; // default: highest

      if (savedQuality != 'auto') {
        final targetHeight = int.tryParse(savedQuality) ?? 0;
        final match = streams.where(
            (s) => s.videoResolution.height <= targetHeight).toList();
        if (match.isNotEmpty) selected = match.last;
      }

      setState(() {
        _streams = streams;
        _currentStream = selected;
      });

      await _initPlayer(selected.url.toString());
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _initPlayer(String url) async {
    await _controller?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    controller.play();

    setState(() {
      _controller = controller;
      _isLoading = false;
    });
  }

  Future<void> _switchQuality(MuxedStreamInfo stream) async {
    final position = _controller?.value.position ?? Duration.zero;
    setState(() => _isLoading = true);

    await _controller?.dispose();

    final controller = VideoPlayerController.networkUrl(
        Uri.parse(stream.url.toString()));
    await controller.initialize();
    await controller.seekTo(position);
    controller.play();

    setState(() {
      _controller = controller;
      _currentStream = stream;
      _isLoading = false;
    });
  }

  void _showQualitySelector(BuildContext context) {
    final provider = context.read<AppProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Video quality',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
          ),
          const Divider(color: Colors.white12, height: 1),
          ..._streams.reversed.map((stream) {
            final height = stream.videoResolution.height;
            final isSelected = _currentStream == stream;
            final savedQ = height <= 240 ? 'Saves data' : null;

            return ListTile(
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? AppColors.ytRed : Colors.white54,
                size: 20,
              ),
              title: Text(
                '${height}p',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                stream.videoQuality.toString().replaceAll('VideoQuality.', ''),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              trailing: savedQ != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Text(savedQ,
                          style: const TextStyle(
                              color: Colors.green, fontSize: 10)),
                    )
                  : null,
              onTap: () async {
                Navigator.pop(context);
                provider.setVideoQuality(height.toString());
                await _switchQuality(stream);
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _yt.close();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ytDarkBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Player
            _buildPlayer(),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    const Divider(height: 0.5),
                    _buildChannelSection(),
                    const Divider(height: 0.5),
                    _buildActionButtons(),
                    const Divider(height: 0.5),
                    _buildCommentsPreview(),
                    const Divider(height: 0.5),
                    _buildSuggestedVideos(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.ytRed))
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white54, size: 40),
                        const SizedBox(height: 8),
                        Text(_errorMessage,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _loadStreams,
                          child: const Text('Retry',
                              style: TextStyle(color: AppColors.ytRed)),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () =>
                        setState(() => _showControls = !_showControls),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_controller!),
                        // Progress bar
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: AppColors.ytRed,
                              bufferedColor: Colors.white24,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                        ),
                        // Play/pause overlay
                        if (_showControls)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller!.value.isPlaying
                                    ? _controller!.pause()
                                    : _controller!.play();
                              });
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _controller!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return GestureDetector(
      onTap: () => setState(() => _titleExpanded = !_titleExpanded),
      child: Container(
        color: AppColors.ytDarkBg,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.video.title,
                    maxLines: _titleExpanded ? 10 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    _titleExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.video.viewCount} views \u00B7 ${timeago.format(widget.video.publishedAt)}',
              style: const TextStyle(color: AppColors.ytGrey, fontSize: 12),
            ),
            if (_titleExpanded) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: [
                  _buildTag('#safetube'),
                  _buildTag('#kids'),
                  _buildTag('#safe'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Text(
      tag,
      style: const TextStyle(
        color: Color(0xFF3EA6FF),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildChannelSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.ytDarkSurface,
            child: Text(
              widget.video.channelName.isNotEmpty
                  ? widget.video.channelName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.video.channelName,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Subscribe',
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) => Row(
          children: [
            // Quality button
            GestureDetector(
              onTap: _streams.isEmpty
                  ? null
                  : () => _showQualitySelector(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.ytChipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hd, color: AppColors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      _currentStream != null
                          ? '${_currentStream!.videoResolution.height}p'
                          : 'Quality',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildActionChip(Icons.thumb_up_outlined, 'Like'),
            const SizedBox(width: 8),
            _buildActionChip(Icons.thumb_down_outlined, ''),
            const SizedBox(width: 8),
            _buildActionChip(Icons.reply, 'Share', flipped: true),
            const SizedBox(width: 8),
            _buildActionChip(Icons.download_outlined, 'Download'),
            const SizedBox(width: 8),
            _buildActionChip(Icons.content_cut, 'Clip'),
            const SizedBox(width: 8),
            _buildActionChip(Icons.bookmark_border, 'Save'),
            const SizedBox(width: 8),
            _buildActionChip(Icons.flag_outlined, 'Report'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label,
      {bool flipped = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ytChipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: flipped
                ? (Matrix4.identity()..scale(-1.0, 1.0))
                : Matrix4.identity(),
            child: Icon(icon, color: AppColors.white, size: 18),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ytDarkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Comments',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              Text('0',
                  style:
                      TextStyle(color: AppColors.ytGrey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.ytChipBg,
                child: const Icon(Icons.person,
                    color: AppColors.ytGrey, size: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Add a comment...',
                    style: TextStyle(
                        color: AppColors.ytGrey, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedVideos() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final suggested = provider.regularVideos
            .where((v) => v.id != widget.video.id && !v.isShort)
            .toList();

        if (suggested.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...suggested.map((video) => VideoCard(
                  video: video,
                  compact: true,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(video: video),
                      ),
                    );
                  },
                )),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
