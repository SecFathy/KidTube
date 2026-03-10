class VideoItem {
  final String id;
  final String youtubeVideoId;
  final String title;
  final String channelName;
  final String channelId;
  final String thumbnailUrl;
  final String channelAvatarUrl;
  final String duration;
  final String viewCount;
  final DateTime publishedAt;
  final bool isShort;
  final bool isApproved;

  VideoItem({
    required this.id,
    required this.youtubeVideoId,
    required this.title,
    required this.channelName,
    required this.channelId,
    required this.thumbnailUrl,
    this.channelAvatarUrl = '',
    this.duration = '',
    this.viewCount = '0',
    DateTime? publishedAt,
    this.isShort = false,
    this.isApproved = true,
  }) : publishedAt = publishedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'youtubeVideoId': youtubeVideoId,
      'title': title,
      'channelName': channelName,
      'channelId': channelId,
      'thumbnailUrl': thumbnailUrl,
      'channelAvatarUrl': channelAvatarUrl,
      'duration': duration,
      'viewCount': viewCount,
      'publishedAt': publishedAt.toIso8601String(),
      'isShort': isShort ? 1 : 0,
      'isApproved': isApproved ? 1 : 0,
    };
  }

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    return VideoItem(
      id: map['id'] as String,
      youtubeVideoId: map['youtubeVideoId'] as String,
      title: map['title'] as String,
      channelName: map['channelName'] as String,
      channelId: map['channelId'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      channelAvatarUrl: map['channelAvatarUrl'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      viewCount: map['viewCount'] as String? ?? '0',
      publishedAt: DateTime.tryParse(map['publishedAt'] as String? ?? '') ?? DateTime.now(),
      isShort: (map['isShort'] as int?) == 1,
      isApproved: (map['isApproved'] as int?) == 1,
    );
  }
}
