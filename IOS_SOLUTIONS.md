# iOS740日の有効期限問題の解決策

## 無料アカウントの制限

残念ながら、**無料のApple Developerアカウント（Personal Team）では、7日間の有効期限を完全に回避することはできません**。これはAppleのセキュリティポリシーです。

## 解決策の選択肢

### 1. 手動で実行（最も簡単）

Cursorやターミナルで直接実行：

```bash
flutter run -d sakiyama --profile
```

これで証明書が自動的に更新され、さらに7日間有効になります。

### 2. Apple Developer Programに加入（年間99ドル）

**メリット**：
- 証明書が1年間有効
- Ad Hoc配布が可能（100台のデバイスに1年間有効）
- App Storeに公開可能
- TestFlightで配布可能（90日間有効、再アップロードで延長可能）

**最も確実な方法**ですが、費用がかかります。

### 3. AltStore / Sideloadly（非公式）

- AltStoreやSideloadlyといったツールを使用
- ただし、これらも7日間の制限があるため、自動更新が必要
- Appleの規約に違反する可能性があるため、自己責任

### 4. Ad Hoc配布（有料アカウント必要）

1年間有効のipaファイルを作成可能：

```bash
# Xcodeでビルド
flutter build ios --release

# XcodeでArchive → Distribute → Ad Hoc
```

その後、`.ipa`ファイルを直接デバイスにインストール可能。

### 5. TestFlight配布（有料アカウント必要）

- 有料アカウントが必要
- 最大10,000人のテスター
- 90日間有効（再アップロードで延長可能）
- App Store Connect経由で簡単に配布

## 推奨順序

1. **個人使用 + 無料で済ませたい**: 週1回 `flutter run -d sakiyama --profile` を実行
2. **本格的に使いたい / 配布したい**: Apple Developer Programに加入（年間99ドル）


## 結論

**無料で使う場合は、7日ごとの更新が必須**です。本格的に使いたい場合は、**Apple Developer Program（年間99ドル）への加入を検討**してください。

