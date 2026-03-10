class ChannelItem {
  final String id;
  final String youtubeChannelId;
  final String name;
  final String avatarUrl;
  final String subscriberCount;
  final bool isAllowed;
  final bool isBlocked;

  ChannelItem({
    required this.id,
    required this.youtubeChannelId,
    required this.name,
    this.avatarUrl = '',
    this.subscriberCount = '0',
    this.isAllowed = true,
    this.isBlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'youtubeChannelId': youtubeChannelId,
      'name': name,
      'avatarUrl': avatarUrl,
      'subscriberCount': subscriberCount,
      'isAllowed': isAllowed ? 1 : 0,
      'isBlocked': isBlocked ? 1 : 0,
    };
  }

  factory ChannelItem.fromMap(Map<String, dynamic> map) {
    return ChannelItem(
      id: map['id'] as String,
      youtubeChannelId: map['youtubeChannelId'] as String,
      name: map['name'] as String,
      avatarUrl: map['avatarUrl'] as String? ?? '',
      subscriberCount: map['subscriberCount'] as String? ?? '0',
      isAllowed: (map['isAllowed'] as int?) == 1,
      isBlocked: (map['isBlocked'] as int?) == 1,
    );
  }
}
