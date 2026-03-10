import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/video_item.dart';
import '../models/channel_item.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('safe_tube.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE videos (
        id TEXT PRIMARY KEY,
        youtubeVideoId TEXT NOT NULL,
        title TEXT NOT NULL,
        channelName TEXT NOT NULL,
        channelId TEXT NOT NULL,
        thumbnailUrl TEXT NOT NULL,
        channelAvatarUrl TEXT DEFAULT '',
        duration TEXT DEFAULT '',
        viewCount TEXT DEFAULT '0',
        publishedAt TEXT NOT NULL,
        isShort INTEGER DEFAULT 0,
        isApproved INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE channels (
        id TEXT PRIMARY KEY,
        youtubeChannelId TEXT NOT NULL,
        name TEXT NOT NULL,
        avatarUrl TEXT DEFAULT '',
        subscriberCount TEXT DEFAULT '0',
        isAllowed INTEGER DEFAULT 1,
        isBlocked INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // Video operations
  Future<void> insertVideo(VideoItem video) async {
    final db = await database;
    await db.insert('videos', video.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteVideo(String id) async {
    final db = await database;
    await db.delete('videos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<VideoItem>> getApprovedVideos() async {
    final db = await database;
    final maps = await db.query('videos', where: 'isApproved = ?', whereArgs: [1]);
    return maps.map((map) => VideoItem.fromMap(map)).toList();
  }

  Future<List<VideoItem>> getApprovedShorts() async {
    final db = await database;
    final maps = await db.query('videos',
        where: 'isApproved = ? AND isShort = ?', whereArgs: [1, 1]);
    return maps.map((map) => VideoItem.fromMap(map)).toList();
  }

  Future<List<VideoItem>> getApprovedRegularVideos() async {
    final db = await database;
    final maps = await db.query('videos',
        where: 'isApproved = ? AND isShort = ?', whereArgs: [1, 0]);
    return maps.map((map) => VideoItem.fromMap(map)).toList();
  }

  Future<List<VideoItem>> getAllVideos() async {
    final db = await database;
    final maps = await db.query('videos');
    return maps.map((map) => VideoItem.fromMap(map)).toList();
  }

  Future<List<VideoItem>> getVideosByChannel(String channelId) async {
    final db = await database;
    final maps = await db.query('videos',
        where: 'channelId = ? AND isApproved = ?', whereArgs: [channelId, 1]);
    return maps.map((map) => VideoItem.fromMap(map)).toList();
  }

  // Channel operations
  Future<void> insertChannel(ChannelItem channel) async {
    final db = await database;
    await db.insert('channels', channel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteChannel(String id) async {
    final db = await database;
    await db.delete('channels', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ChannelItem>> getAllowedChannels() async {
    final db = await database;
    final maps = await db.query('channels',
        where: 'isAllowed = ? AND isBlocked = ?', whereArgs: [1, 0]);
    return maps.map((map) => ChannelItem.fromMap(map)).toList();
  }

  Future<List<ChannelItem>> getBlockedChannels() async {
    final db = await database;
    final maps = await db.query('channels', where: 'isBlocked = ?', whereArgs: [1]);
    return maps.map((map) => ChannelItem.fromMap(map)).toList();
  }

  Future<List<ChannelItem>> getAllChannels() async {
    final db = await database;
    final maps = await db.query('channels');
    return maps.map((map) => ChannelItem.fromMap(map)).toList();
  }

  Future<void> updateChannel(ChannelItem channel) async {
    final db = await database;
    await db.update('channels', channel.toMap(),
        where: 'id = ?', whereArgs: [channel.id]);
  }

  Future<bool> isChannelBlocked(String youtubeChannelId) async {
    final db = await database;
    final maps = await db.query('channels',
        where: 'youtubeChannelId = ? AND isBlocked = ?',
        whereArgs: [youtubeChannelId, 1]);
    return maps.isNotEmpty;
  }

  // Settings operations
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }
}
