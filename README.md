# 🎥 Flutter Portfolio Viewer

An offline portfolio viewer app built with **Flutter** — designed for showcasing your videos, images, and captions locally on iOS, macOS, and Web.

No internet connection required.  
Perfect for artists, designers, and developers who want to present their work elegantly, even offline.

---

## 📦 Project Structure

```
portfolio-viewer/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── portfolio_item.dart
│   ├── services/
│   │   └── portfolio_service.dart
│   └── views/
│       ├── portfolio_list_view.dart
│       ├── portfolio_card_view.dart
│       └── portfolio_detail_view.dart
├── assets/
│   ├── portfolio.json
│   ├── images/
│   └── videos/
├── ios/
├── macos/
├── web/
└── pubspec.yaml
```

---

## 🛠️ Setup

### Prerequisites

- Flutter SDK (>=3.0.0)
- Xcode (for iOS/macOS development)
- CocoaPods (for iOS dependencies)

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd swiftui-portfolio-viewer
```

2. **Install Flutter dependencies**

```bash
flutter pub get
```

3. **Install iOS dependencies (for iOS/macOS)**

```bash
cd ios
pod install
cd ..
```

4. **Run the app**

```bash
# iOS実機
flutter run -d sakiyama --profile

# iOS Simulator
flutter run

# macOS
flutter run -d macos

# Web
flutter run -d chrome
```

---

## 📝 Adding Your Portfolio Items

1. **Place your media files:**
   - Images: `assets/images/`
   - Videos: `assets/videos/`

2. **Update `assets/portfolio.json`:**

```json
[
  {
    "id": "work001",
    "title": "作品タイトル",
    "caption": "作品の説明文",
    "thumbnail": "images/image001.jpg",
    "video": "videos/video001.mov",
    "tags": ["タグ1", "タグ2"],
    "year": 2024
  }
]
```

**Important:**
- File names should **NOT** contain spaces or special characters (日本語ファイル名は避けることを推奨)
- Use lowercase letters, numbers, and underscores (`_`) or hyphens (`-`)
- Match the file names exactly in `portfolio.json`

---

## 🎯 Features

- ✅ Offline-first design (no internet required)
- ✅ Clean, modern UI built with Flutter
- ✅ Video playback with `video_player` package
- ✅ Image display
- ✅ Tag support
- ✅ Cross-platform (iOS, macOS, Web)
- ✅ Easy to customize and extend

---

## 📱 Running on iOS Device

### First Time Setup

1. **Open Xcode project:**

```bash
open ios/Runner.xcworkspace
```

2. **Configure code signing:**
   - Select **Runner** project in Xcode
   - Go to **Signing & Capabilities**
   - Check **Automatically manage signing**
   - Select your **Team** (add Apple ID if needed)

3. **Run from terminal:**

```bash
flutter run -d sakiyama --profile
```

**Note:** Debug mode apps on iOS 14+ can only be launched from Flutter tools, IDEs with Flutter plugins, or Xcode. Use `--profile` or `--release` mode to launch from home screen.

---

## 🖥️ Environment

- **Language**: Dart (Flutter)
- **Platforms**: iOS, macOS, Web
- **IDE**: VS Code / Android Studio / Xcode
- **Version Control**: Git
- **License**: MIT License

---

## 📄 License

This project is licensed under the MIT License.
See the LICENSE file for details.
