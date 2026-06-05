# 環境構築手順：よりみち日和 Flutter 版

作成日：2026-06-05  
対象：初めて Flutter アプリ開発をする人  
対象リポジトリ：`AltHiroaki/yorimitiBiyori`

---

## 1. このファイルの目的

このファイルは、**よりみち日和を Flutter アプリとして自分の PC で動かせる状態にするまでの手順**をまとめたものです。

現在の `よりみち日和` は、Web アプリではなく iOS / Android 向けの Flutter アプリとして開発します。

---

## 2. よりみち日和の初期実装方針

MVP では以下の方針で作ります。

- Flutter で iOS / Android アプリとして作る
- ログイン機能は入れない
- Google Calendar API は最初から入れない
- Firebase / Firestore は最初から入れない
- YouTube API や音楽サービス連携は最初から入れない
- AI API は最初から入れない
- 提案データは `assets/data/suggestions.json` で管理する
- 実施履歴や設定は端末内に保存する
- 通知から 15分 / 30分 / 60分 を選び、提案画面を表示する

まずは **「興味登録 → 通知 → 時間選択 → 提案 → 履歴保存」** という中心機能を完成させます。

---

## 3. 先に入れるもの一覧

| 入れるもの | 何のために使うか | なぜ必要か |
|---|---|---|
| VS Code | コードを書くエディタ | ファイルを見やすく編集でき、拡張機能も使えるため |
| Git | 変更履歴を管理する道具 | 誰がどこを変更したか分かり、失敗しても戻しやすいため |
| GitHub | コードを置く場所 | チームで共有できるため |
| Flutter SDK | Flutter アプリを作る本体 | Dart / Flutter のビルド・実行に必要なため |
| Android Studio | Android Emulator と Android SDK の管理 | Android 仮想端末で確認するため |
| Xcode | iOS Simulator と iOS ビルド | iOS 確認に必要。macOS のみ |
| Android Emulator | 仮想 Android 端末 | PC 上で Android アプリを確認するため |
| iOS Simulator | 仮想 iPhone 端末 | Mac 上で iOS アプリを確認するため |

---

## 4. OS ごとの注意

| 開発PC | Android Emulator | iOS Simulator |
|---|---:|---:|
| Windows | 使える | 使えない |
| macOS | 使える | 使える |
| Linux | 使える | 使えない |

iOS Simulator は Xcode に含まれるため、Mac が必要です。  
Windows だけでは iOS Simulator は使えません。

---

## 5. VS Code を入れる

公式サイト：

```text
https://code.visualstudio.com/
```

入れておくと便利な拡張機能：

| 拡張機能 | 目的 |
|---|---|
| Flutter | Flutter 開発支援 |
| Dart | Dart の補完・解析 |
| Japanese Language Pack for Visual Studio Code | VS Code を日本語化する |
| GitLens | Git の履歴を見やすくする |

---

## 6. Git を入れる

公式サイト：

```text
https://git-scm.com/
```

確認：

```bash
git --version
```

---

## 7. Flutter SDK を入れる

公式サイト：

```text
https://docs.flutter.dev/get-started/install
```

インストール後、ターミナルで確認します。

```bash
flutter --version
```

Flutter の環境診断は以下です。

```bash
flutter doctor
```

`flutter doctor` は、Flutter 開発に必要なツールが揃っているか確認するコマンドです。

---

## 8. Android Studio と Android Emulator

Android Studio 公式サイト：

```text
https://developer.android.com/studio
```

Android Studio を入れる理由：

- Android SDK を管理する
- Android Emulator を作る
- Android のビルドに必要なツールを入れる

Android Emulator の作成手順：

1. Android Studio を開く
2. Device Manager を開く
3. Create Device を選ぶ
4. Pixel 系の端末を選ぶ
5. Android の system image を選ぶ
6. Emulator を起動する

起動中の端末確認：

```bash
flutter devices
```

アプリ起動：

```bash
flutter run
```

---

## 9. Xcode と iOS Simulator

iOS を確認するには macOS と Xcode が必要です。

Xcode：

```text
https://developer.apple.com/xcode/
```

Xcode を入れた後、必要に応じて以下を実行します。

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

iOS Simulator の起動は Xcode から行うか、Flutter から起動できます。

```bash
open -a Simulator
flutter devices
flutter run
```

---

## 10. GitHub からプロジェクトを取得する

作業用フォルダを作ります。

```bash
cd Desktop
mkdir app-dev
cd app-dev
```

リポジトリを clone します。

```bash
git clone https://github.com/AltHiroaki/yorimitiBiyori.git
cd yorimitiBiyori
```

---

## 11. Flutter の platform ディレクトリを生成する

このリポジトリでは、`android/` と `ios/` は Flutter SDK で生成する前提にしています。

```bash
flutter create --platforms=android,ios .
```

すでに `lib/` や `pubspec.yaml` がある状態で実行しても、Flutter の不足している platform ファイルを補えます。

実行後、以下のようなディレクトリが作成されます。

```text
android/
ios/
```

---

## 12. パッケージを取得する

```bash
flutter pub get
```

`pubspec.yaml` に書かれている依存関係を取得します。

---

## 13. アプリを起動する

接続されている端末や Emulator / Simulator を確認します。

```bash
flutter devices
```

起動します。

```bash
flutter run
```

複数端末がある場合は、端末 ID を指定します。

```bash
flutter run -d <device-id>
```

---

## 14. 解析とテスト

コード解析：

```bash
flutter analyze
```

テスト：

```bash
flutter test
```

MVP では、まず以下をテスト対象にします。

- 選択時間以内の提案だけ出るか
- 興味カテゴリに合う提案だけ出るか
- 履歴の実施数・スキップ数を正しく数えられるか

通知機能は OS 依存があるため、自動テストだけでなく実機確認も必要です。

---

## 15. 通知機能の確認方針

通知は段階的に確認します。

```text
1. アプリ内で 15分 / 30分 / 60分 を選んで提案できる
2. ローカル通知が表示される
3. 通知をタップするとアプリが開く
4. 通知アクションから時間を受け取れる
5. 受け取った時間で提案画面に遷移する
```

最終的には以下で確認するのが望ましいです。

- Android 実機
- iPhone 実機

---

## 16. よくある確認先

| 状況 | 確認すること |
|---|---|
| `flutter` コマンドが見つからない | Flutter SDK の PATH 設定 |
| `flutter doctor` でエラーが出る | Android Studio / Xcode / SDK の設定 |
| Android Emulator が出ない | Android Studio の Device Manager |
| iOS Simulator が使えない | macOS かどうか、Xcode が入っているか |
| `flutter pub get` で失敗する | `pubspec.yaml` のインデント、ネットワーク |
| アプリが起動しない | `flutter devices`、エラーメッセージ |
| 通知が出ない | 通知許可、OS 設定、実機確認 |

---

## 17. 次に読むドキュメント

| 目的 | ファイル |
|---|---|
| Flutter を選んだ理由を知る | `docs/flutter-technology-guide.md` |
| 実装順序を確認する | `docs/implementation-plan.md` |
| 仕様を確認する | `docs/specification-summary.md` |
| GitHub の作業フローを確認する | `docs/github-workflow-guide.md` |
| VS Code の Git 操作を確認する | `docs/vscode-git-guide.md` |
