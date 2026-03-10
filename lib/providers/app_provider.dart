import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../models/channel_item.dart';
import '../services/database_service.dart';
import '../services/youtube_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final YouTubeService _yt = YouTubeService();

  List<VideoItem> _allVideos = [];
  List<VideoItem> _regularVideos = [];
  List<VideoItem> _shorts = [];
  List<ChannelItem> _allowedChannels = [];
  List<ChannelItem> _blockedChannels = [];
  bool _isLoading = false;
  bool _isParentMode = false;
  String _parentPin = '1234';

  List<VideoItem> get allVideos => _allVideos;
  List<VideoItem> get regularVideos => _regularVideos;
  List<VideoItem> get shorts => _shorts;
  List<ChannelItem> get allowedChannels => _allowedChannels;
  List<ChannelItem> get blockedChannels => _blockedChannels;
  bool get isLoading => _isLoading;
  bool get isParentMode => _isParentMode;
  String get parentPin => _parentPin;

  Future<void> init() async {
    final savedPin = await _db.getSetting('parent_pin');
    if (savedPin != null) _parentPin = savedPin;
    await loadAllData();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    _allVideos = await _db.getApprovedVideos();
    _regularVideos = await _db.getApprovedRegularVideos();
    _shorts = await _db.getApprovedShorts();
    _allowedChannels = await _db.getAllowedChannels();
    _blockedChannels = await _db.getBlockedChannels();

    _isLoading = false;
    notifyListeners();
  }

  bool verifyPin(String pin) {
    return pin == _parentPin;
  }

  Future<void> setParentPin(String newPin) async {
    _parentPin = newPin;
    await _db.setSetting('parent_pin', newPin);
    notifyListeners();
  }

  void enterParentMode() {
    _isParentMode = true;
    notifyListeners();
  }

  void exitParentMode() {
    _isParentMode = false;
    notifyListeners();
  }

  // Video management
  Future<VideoItem?> addVideoByUrl(String url) async {
    _isLoading = true;
    notifyListeners();

    final video = await _yt.getVideoInfo(url);
    if (video != null) {
      final isBlocked = await _db.isChannelBlocked(video.channelId);
      if (!isBlocked) {
        await _db.insertVideo(video);
        await loadAllData();
        return video;
      }
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> removeVideo(String id) async {
    await _db.deleteVideo(id);
    await loadAllData();
  }

  // Channel management
  Future<ChannelItem?> addChannelByUrl(String url) async {
    _isLoading = true;
    notifyListeners();

    final channel = await _yt.getChannelInfo(url);
    if (channel != null) {
      await _db.insertChannel(channel);
      // Also fetch and add channel videos
      final videos = await _yt.getChannelVideos(url, limit: 30);
      for (final video in videos) {
        final isBlocked = await _db.isChannelBlocked(video.channelId);
        if (!isBlocked) {
          await _db.insertVideo(video);
        }
      }
      await loadAllData();
      return channel;
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> blockChannel(ChannelItem channel) async {
    final blocked = ChannelItem(
      id: channel.id,
      youtubeChannelId: channel.youtubeChannelId,
      name: channel.name,
      avatarUrl: channel.avatarUrl,
      subscriberCount: channel.subscriberCount,
      isAllowed: false,
      isBlocked: true,
    );
    await _db.updateChannel(blocked);
    await loadAllData();
  }

  Future<void> unblockChannel(ChannelItem channel) async {
    final unblocked = ChannelItem(
      id: channel.id,
      youtubeChannelId: channel.youtubeChannelId,
      name: channel.name,
      avatarUrl: channel.avatarUrl,
      subscriberCount: channel.subscriberCount,
      isAllowed: true,
      isBlocked: false,
    );
    await _db.updateChannel(unblocked);
    await loadAllData();
  }

  Future<void> removeChannel(String id) async {
    await _db.deleteChannel(id);
    await loadAllData();
  }

  // Search (for parent mode - search YouTube to add content)
  Future<List<VideoItem>> searchYouTube(String query) async {
    return await _yt.searchVideos(query);
  }

  Future<void> approveVideo(VideoItem video) async {
    await _db.insertVideo(video);
    await loadAllData();
  }

  @override
  void dispose() {
    _yt.dispose();
    super.dispose();
  }
}
