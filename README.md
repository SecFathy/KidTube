<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge" alt="License"/>
</p>

<h1 align="center">KidTube</h1>

<p align="center">
  <strong>A safe, YouTube-like video app for children with full parental controls.</strong>
</p>

<p align="center">
  Parents control everything. Kids see only what you approve.<br/>
  YouTube-like interface. Zero exposure to unwanted content.
</p>

> **Disclaimer:** KidTube is **not** affiliated with, endorsed by, or associated with YouTube or Google in any way. The app uses a YouTube-like UI design purely to provide a familiar viewing experience for children. All YouTube trademarks belong to Google LLC. This is an independent, open-source parental control project.

---

## The Problem

YouTube has billions of videos. Not all of them are safe for children. Even YouTube Kids has been criticized for letting inappropriate content slip through automated filters.

**KidTube** gives parents complete, manual control over every single video their children can watch — while keeping the interface familiar and easy to use. The app mimics the look and feel of the YouTube mobile app so children feel comfortable using it, but every piece of content is hand-approved by a parent.

## How It Works

| Role | What They See |
|------|--------------|
| **Child** | A YouTube-like app with only parent-approved videos and channels |
| **Parent** | A PIN-protected dashboard to add, remove, and manage all content |

Children **cannot** search YouTube, browse freely, or access anything the parent hasn't explicitly approved. The familiar YouTube-style interface means kids won't notice the difference — they just see a curated, safe version.

## Features

### For Kids
- YouTube-style dark mode UI (looks and feels like the real app)
- Home feed with filter chips (All, Music, Gaming, etc.)
- Shorts with full-screen vertical swipe player
- Subscriptions tab with channel avatars
- Video player with suggestions
- Library / "You" tab
- Auto-shuffled homepage when 4+ channels are added for content variety

### For Parents (PIN-Protected)
- **Add videos by URL** — paste any YouTube link
- **Add entire channels** — fetches up to 30 videos automatically (supports `@handle` URLs)
- **Search YouTube** — find and approve individual videos
- **Block channels** — blocked channels can never have videos added
- **Remove videos** — swipe to delete or tap remove
- **Change PIN** — set a custom 4-6 digit PIN
- **Clickable dashboard stats** — tap Videos, Shorts, or Channels cards to jump directly to management screens

### Technical
- Embedded YouTube player (no external app needed)
- SQLite local database — all data stored on-device
- No account required, no data sent to any server
- Works offline for previously loaded content

## Screenshots

> *Coming soon — contributions welcome!*

## Architecture

```
lib/
├── main.dart                        # App entry point
├── utils/
│   └── constants.dart               # YouTube dark theme & colors
├── models/
│   ├── video_item.dart              # Video data model
│   └── channel_item.dart            # Channel data model
├── services/
│   ├── database_service.dart        # SQLite CRUD operations
│   └── youtube_service.dart         # YouTube data fetching
├── providers/
│   └── app_provider.dart            # State management (ChangeNotifier)
├── screens/
│   ├── main_shell.dart              # Bottom navigation (5 tabs)
│   ├── home_screen.dart             # Home feed with chips + Shorts shelf
│   ├── shorts_tab_screen.dart       # Full-screen vertical Shorts player
│   ├── shorts_player_screen.dart    # Standalone Shorts player
│   ├── video_player_screen.dart     # Video player + suggestions
│   ├── subscriptions_screen.dart    # Channel list + videos
│   ├── library_screen.dart          # "You" tab / Library
│   ├── parent_login_screen.dart     # PIN entry screen
│   ├── parent_dashboard_screen.dart # Admin panel
│   ├── search_add_screen.dart       # Search YouTube + approve
│   ├── manage_videos_screen.dart    # View/remove videos
│   └── manage_channels_screen.dart  # Allow/block channels
└── widgets/
    ├── video_card.dart              # YouTube-style video card
    └── shorts_card.dart             # Shorts thumbnail card
```

## Getting Started

### Prerequisites

- Flutter SDK (3.6+)
- Android Studio or Xcode
- A physical device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/SecFathy/KidTube.git
cd KidTube

# Install dependencies
flutter pub get

# Run on a connected device
flutter run

# Build release APK
flutter build apk --release

# Build release IPA (requires Xcode)
flutter build ipa --release
```

### First Launch

1. Open the app — you'll see the YouTube-style home screen (empty)
2. **Long-press** the profile avatar (top-right) to access Parent Mode
3. Enter the default PIN: **`1234`**
4. Start adding videos and channels from the Parent Dashboard

## Parent Dashboard Guide

| Action | How To |
|--------|--------|
| Add a video | Tap "Add Video by URL" → paste a YouTube link |
| Add a channel | Tap "Add Channel" → paste channel URL (e.g., `https://youtube.com/@Cocomelon`) |
| Search & add | Tap "Search & Add Videos" → search by topic → tap + to approve |
| Remove a video | "Manage Videos" → swipe left or tap trash icon |
| Quick manage | Tap the Videos, Shorts, or Channels stat cards to jump directly to management |
| Block a channel | "Manage Channels" → Allowed tab → tap block icon |
| Unblock a channel | "Manage Channels" → Blocked tab → tap unblock icon |
| Change PIN | Tap the gear icon → enter new 4-6 digit PIN |

## Dependencies

| Package | Purpose |
|---------|---------|
| `youtube_player_flutter` | Embedded YouTube video player |
| `youtube_explode_dart` | YouTube data fetching (no API key needed) |
| `provider` | State management |
| `sqflite` | Local SQLite database |
| `cached_network_image` | Image caching for thumbnails |
| `shared_preferences` | Simple key-value storage |
| `timeago` | Human-readable timestamps |
| `uuid` | Unique ID generation |

## Privacy & Security

- **No data collection** — all data is stored locally on the device
- **No API keys** — uses `youtube_explode_dart` which scrapes public YouTube data
- **No accounts** — no sign-up, no login, no tracking
- **PIN-protected** — parent controls are hidden behind a PIN that kids won't discover easily (long-press on avatar)

## Disclaimer

This project is **not** an official YouTube product. It is not affiliated with, endorsed by, or connected to YouTube, Google, or Alphabet Inc. in any way. The YouTube-like interface is used solely to provide children with a familiar and comfortable viewing experience. All content is fetched from publicly available YouTube data. "YouTube" and the YouTube logo are trademarks of Google LLC.

This app is intended for personal, non-commercial use as a parental control tool.

## Roadmap

- [ ] Watch time limits (daily/weekly)
- [ ] Bedtime schedule (auto-lock after a set time)
- [ ] Multiple child profiles
- [ ] Watch history tracking for parents
- [ ] Export/import approved content lists
- [ ] iOS App Store & Google Play Store release

## Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- UI design inspired by the [YouTube](https://youtube.com) mobile app (not affiliated)
- Built with [Flutter](https://flutter.dev)
- YouTube data powered by [youtube_explode_dart](https://pub.dev/packages/youtube_explode_dart)

---

<p align="center">
  <strong>Built with care for parents who want their kids safe online.</strong><br/>
  <sub>This is an independent project. Not affiliated with YouTube or Google.</sub>
</p>
