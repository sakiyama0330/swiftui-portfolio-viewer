# アプリアイコンの設定手順

## 設定完了

`pubspec.yaml`に`flutter_launcher_icons`を追加しました。アーティストロゴ（白透過）をアイコンとして使用します。

## アイコンを生成する手順

ターミナルで以下のコマンドを実行してください：

```bash
# 依存関係をインストール
flutter pub get

# アイコンを生成（ロゴから各プラットフォーム用に出力）
dart run flutter_launcher_icons
```

これで、指定した画像から各プラットフォーム用のアイコンが自動生成されます。

## 生成されるアイコン

- **iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` に生成
- **macOS**: `macos/Runner/Assets.xcassets/AppIcon.appiconset/` に生成
- **Web**: `web/icons/` に生成
- **Android**: `android/app/src/main/res/` に生成（Androidが追加された場合）

## アイコンを反映させる

### iOS/macOS
Xcodeでプロジェクトを開いて再ビルドするか、Flutterから実行：

```bash
flutter run -d sakiyama --profile
```

### Web
```bash
flutter run -d chrome
```

## 注意事項

- 使用画像: `assets/images/sakiyama_logo_white.png`
- iOS用のアイコンは透明度（alpha）が削除されます（`remove_alpha_ios: true`）
- Web用は黒背景（#000000）で生成されます


