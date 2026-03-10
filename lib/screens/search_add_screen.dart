import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/app_provider.dart';
import '../models/video_item.dart';
import '../utils/constants.dart';

class SearchAddScreen extends StatefulWidget {
  const SearchAddScreen({super.key});

  @override
  State<SearchAddScreen> createState() => _SearchAddScreenState();
}

class _SearchAddScreenState extends State<SearchAddScreen> {
  final _searchController = TextEditingController();
  List<VideoItem> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;
  final Set<String> _addedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final results = await provider.searchYouTube(query);
      setState(() {
        _results = results;
        _isSearching = false;
        if (results.isEmpty) {
          _errorMessage = 'No videos found for "$query". Try a different search.';
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Search failed. Check your internet connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ytDarkBg,
      appBar: AppBar(
        backgroundColor: AppColors.ytDarkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search YouTube videos...',
            hintStyle: TextStyle(color: AppColors.ytGrey),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.ytGrey, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _results = [];
                  _hasSearched = false;
                  _errorMessage = null;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.white),
            onPressed: _search,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.ytRed),
            SizedBox(height: 16),
            Text(
              'Searching YouTube...',
              style: TextStyle(color: AppColors.ytGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: AppColors.ytGrey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.ytGrey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tip: Try searching for video titles, topics, or paste a direct YouTube URL.',
                style: TextStyle(color: AppColors.ytLightGrey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 48, color: AppColors.ytGrey),
              SizedBox(height: 16),
              Text(
                'Search for videos to add',
                style: TextStyle(color: AppColors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Search by video title, topic, or channel name.\nYou can also paste a YouTube URL directly.',
                style: TextStyle(color: AppColors.ytGrey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final video = _results[index];
        final isAdded = _addedIds.contains(video.youtubeVideoId);

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 120,
              height: 68,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.ytDarkSurface),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.ytDarkSurface,
                      child: const Icon(Icons.play_circle_outline,
                          color: AppColors.ytGrey),
                    ),
                  ),
                  if (video.duration.isNotEmpty)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          video.duration,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          title: Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.white, fontSize: 13),
          ),
          subtitle: Row(
            children: [
              Flexible(
                child: Text(
                  '${video.channelName} \u00B7 ${video.viewCount} views',
                  style:
                      const TextStyle(color: AppColors.ytGrey, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (video.isShort) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.ytRed,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'SHORT',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          trailing: isAdded
              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
              : IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.ytRed, size: 28),
                  onPressed: () async {
                    final provider =
                        Provider.of<AppProvider>(context, listen: false);
                    await provider.approveVideo(video);
                    setState(() {
                      _addedIds.add(video.youtubeVideoId);
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added: ${video.title}'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
        );
      },
    );
  }
}
