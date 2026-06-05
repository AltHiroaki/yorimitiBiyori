# よりみち日和

> 空いた時間に、興味の中からちょっと新しい体験を。

よりみち日和は、ユーザーが登録した興味カテゴリをもとに、短い空き時間でできる行動やコンテンツを提案する **iOS / Android 向け Flutter アプリ**です。

当初は Web アプリとして検討していましたが、空き時間にユーザーが自分からアプリを開くよりも、スマホ通知をきっかけに使える体験の方がアプリの目的に合うため、Flutter によるネイティブアプリ開発へ方針を変更します。

---

## 企画の位置づけ

本アプリは、予定管理アプリではなく、空き時間に「何をするか」を軽く決めるための提案アプリです。

従来の寄り道案では、場所・予算・強度から外出行動を提案する想定でした。  
しかし、ターゲットユーザー層が広くなりやすいため、ユーザーが最初に登録した興味カテゴリをもとに、短時間でできる小さな行動を提案する形に変更します。

このアプリで扱う「寄り道」は、物理的な移動だけではありません。

- 普段見ない動画を見る
- 普段聴かない音楽を聴く
- 気になるテーマを少し調べる
- 散歩や読書など、短時間でできる行動を試す

つまり、**興味の寄り道**を提案するアプリとして設計します。

---

## 初期実装版 MVP

授業内で確実に完成させるため、MVP では機能を絞ります。

### 初期実装で入れるもの

- 興味カテゴリの登録
- 通知時刻の設定
- ローカル通知の表示
- 通知アクションによる時間選択
  - 15 分
  - 30 分
  - 60 分
- 選択時間に合う提案の表示
- 別の提案の再表示
- 実施記録
- スキップ記録
- 履歴表示
- 設定画面

### 初期実装で入れないもの

- ユーザーログイン
- Google Calendar API
- Firebase Authentication
- Firestore
- Google Maps API / Places API
- 位置情報取得
- YouTube API 連携
- 音楽サービス連携
- AI API によるリアルタイム生成

これらは発展機能として、MVP が完成した後に段階的に検討します。

---

## 技術構成

| 分類 | 使用技術 | 用途 |
|---|---|---|
| アプリフレームワーク | Flutter | iOS / Android を 1 つのコードベースで開発する |
| 言語 | Dart | Flutter アプリの実装に使う |
| UI | Material 3 | スマホ向けの画面・ボタン・ナビゲーションを構築する |
| 通知 | flutter_local_notifications | ローカル通知と通知アクションを扱う |
| 画面遷移 | Flutter 標準 / 将来的に go_router | ホーム・提案・履歴・設定画面を切り替える |
| 状態管理 | 初期は StatefulWidget、必要に応じて Riverpod | MVP では複雑化を避ける |
| 提案データ | `assets/data/suggestions.json` | 提案候補を管理する |
| 履歴保存 | shared_preferences 予定 | ログインなしで端末内に履歴を保存する |
| テスト | flutter_test | ロジック・Widget のテストを行う |

詳細は以下を参照してください。

- [Flutter 技術解説](./docs/flutter-technology-guide.md)

---

## 画面構成

| 画面 | 役割 |
|---|---|
| ホーム画面 | アプリ説明、MVP 方針、現在の状態を表示する |
| 提案画面 | 通知または手動選択された時間に合う提案を表示する |
| 履歴画面 | 実施済み・スキップした提案を一覧表示する |
| 設定画面 | 興味カテゴリ、通知時刻、履歴削除などを管理する |

---

## ディレクトリ構成

```text
yorimitiBiyori/
├─ README.md
├─ pubspec.yaml
├─ analysis_options.yaml
├─ assets/
│  └─ data/
│     └─ suggestions.json
├─ lib/
│  ├─ main.dart
│  └─ src/
│     ├─ app/
│     │  └─ yorimiti_biyori_app.dart
│     ├─ pages/
│     │  ├─ home_page.dart
│     │  ├─ suggestion_page.dart
│     │  ├─ history_page.dart
│     │  └─ settings_page.dart
│     └─ widgets/
│        └─ section_card.dart
├─ docs/
│  ├─ AGENTS.md
│  ├─ SKILL.md
│  ├─ coding-rules-guide.md
│  ├─ environment-setup.md
│  ├─ file-separation-guide.md
│  ├─ flutter-technology-guide.md
│  ├─ github-education-application.md
│  ├─ github-workflow-guide.md
│  ├─ implementation-plan.md
│  ├─ specification-summary.md
│  └─ vscode-git-guide.md
└─ .github/
   ├─ ISSUE_TEMPLATE/
   └─ pull_request_template.md
```

`android/` と `ios/` は Flutter の生成ファイルが多いため、開発環境で以下を実行して生成します。

```bash
flutter create --platforms=android,ios .
```

---

## セットアップ

詳しい手順は以下を参照してください。

- [環境構築手順](./docs/environment-setup.md)

基本的な起動手順は以下です。

```bash
flutter pub get
flutter run
```

解析・テストは以下です。

```bash
flutter analyze
flutter test
```

---

## 開発ルール

このリポジトリでは、AI agent 向けの指示と、開発者向けの説明を分けて管理します。

| 用途 | 見るページ |
|---|---|
| AI agent に読ませる汎用コーディング規則 | [General Coding Skill](./docs/SKILL.md) |
| AI agent に読ませるよりみち日和専用規則 | [AI Agent Rules](./docs/AGENTS.md) |
| Flutter 技術構成と選定理由 | [Flutter 技術解説](./docs/flutter-technology-guide.md) |
| 開発者向けのコーディング規則の説明 | [コーディング規則の考え方](./docs/coding-rules-guide.md) |
| ファイル分けを行う理由の説明 | [ファイル分けを行う理由](./docs/file-separation-guide.md) |
| Issue・Branch・Pull Request を使う理由 | [GitHub 開発フロー](./docs/github-workflow-guide.md) |
| VS Code で Git を操作する方法 | [VS Code Git 操作ガイド](./docs/vscode-git-guide.md) |

---

## 困ったときのリンク集

### このリポジトリ内の資料

| 分からないこと | 見るページ |
|---|---|
| 環境構築、起動方法、エミュレータ確認 | [環境構築手順](./docs/environment-setup.md) |
| 何から実装すればよいか | [実装計画](./docs/implementation-plan.md) |
| アプリの仕様を確認したい | [仕様要約](./docs/specification-summary.md) |
| Flutter を選ぶ理由や技術構成を確認したい | [Flutter 技術解説](./docs/flutter-technology-guide.md) |
| コーディング規則の理由を確認したい | [コーディング規則の考え方](./docs/coding-rules-guide.md) |
| ファイル分けの理由を確認したい | [ファイル分けを行う理由](./docs/file-separation-guide.md) |
| Issue・Branch・Pull Request の理由を確認したい | [GitHub 開発フロー](./docs/github-workflow-guide.md) |
| VS Code で Git 操作をしたい | [VS Code Git 操作ガイド](./docs/vscode-git-guide.md) |
| AI agent に守らせる規則を確認したい | [AI Agent Rules](./docs/AGENTS.md) |
| GitHub Education に応募したい | [GitHub Education 申請手順](./docs/github-education-application.md) |

### 技術ごとの公式ドキュメント

| 分からないこと | 見るページ |
|---|---|
| Flutter の基本 | [Flutter Docs](https://docs.flutter.dev/) |
| Dart の文法 | [Dart Docs](https://dart.dev/guides) |
| Flutter のテスト | [Flutter Testing](https://docs.flutter.dev/testing) |
| Android Studio / Emulator | [Android Studio](https://developer.android.com/studio) |
| iOS Simulator / Xcode | [Xcode](https://developer.apple.com/xcode/) |
| GitHub の基本操作 | [GitHub Docs](https://docs.github.com/) |
| VS Code の Source Control | [VS Code Source Control](https://code.visualstudio.com/docs/sourcecontrol/overview) |

---

## 実装順序

1. Flutter プロジェクトとして起動できる状態にする
2. ホーム・提案・履歴・設定画面を作る
3. 興味カテゴリの登録 UI を作る
4. `suggestions.json` の提案データを増やす
5. 選択時間に合う提案を抽出する
6. ランダム提案を実装する
7. 通知時刻設定を作る
8. ローカル通知を実装する
9. 通知アクションから提案画面へ遷移する
10. 実施・スキップ履歴を保存する
11. Android Emulator / iOS Simulator / 実機で確認する

詳細は以下を参照してください。

- [実装計画](./docs/implementation-plan.md)
- [仕様要約](./docs/specification-summary.md)
- [Flutter 技術解説](./docs/flutter-technology-guide.md)

---

## 発展機能

MVP 完成後、余裕があれば以下を検討します。

- AI API による提案候補生成
- YouTube API 連携
- 音楽サービス連携
- Google Calendar 連携
- 予定間の空き時間自動検出
- Firestore によるユーザー別履歴保存
- 位置情報や周辺スポット提案

---

## メンバー

アプリデザイン総合演習 2026  
グループ L 班

- 信寛昭
- 久保孝輔
- 山本竜聖

---

## 開発メモ

このリポジトリでは、まず MVP を完成させることを優先します。  
AI API、YouTube、音楽連携、位置情報は魅力的ですが、初期段階では実装難度が高いため、中心機能である「興味登録 → 通知 → 時間選択 → 提案 → 履歴保存」を先に安定させます。
