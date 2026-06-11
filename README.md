# よりみち日和

> 空いた時間に、興味の中からちょっと新しい体験を。

よりみち日和は、ユーザーが登録した興味カテゴリをもとに、短い空き時間でできる行動やコンテンツを提案する **Flutter アプリ**です。

当初は Web アプリとして検討していましたが、空き時間にユーザーが自分からアプリを開くよりも、スマホ通知をきっかけに使える体験の方がアプリの目的に合うため、Flutter によるネイティブアプリ開発へ方針を変更します。

MVP では **Android 版のみ**を実装・検証対象にします。iOS は MVP 完成後の発展版で導入します。

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

授業内で確実に完成させるため、MVP では機能と対象プラットフォームを絞ります。MVP の対象は **Android のみ**です。

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

## MVP 対象プラットフォーム

現時点では、チーム内に macOS 環境がありません。

そのため、MVP では **Android のみを実装・検証対象** とします。

- Android は Windows PC + Android Emulator / Android 実機で確認する
- iOS は MVP には含めない
- iOS 導入は、Mac の一時借用またはクラウドビルド + TestFlight を使う発展版タスクとして扱う

詳細は以下を参照してください。

- [iOS 導入方針と確認環境に関する懸念](./docs/iOS導入方針と確認環境の懸念.md)

---

## 技術構成

| 分類 | 使用技術 | 用途 |
|---|---|---|
| アプリフレームワーク | Flutter | MVP では Android 版を実装し、発展版で iOS に展開しやすくする |
| 言語 | Dart | Flutter アプリの実装に使う |
| UI | Material 3 | スマホ向けの画面・ボタン・ナビゲーションを構築する |
| 通知 | flutter_local_notifications 予定 | ローカル通知と通知アクションを扱う |
| 画面遷移 | Flutter 標準 / 将来的に go_router | ホーム・提案・履歴・設定画面を切り替える |
| 状態管理 | 初期は StatefulWidget、必要に応じて Riverpod | MVP では複雑化を避ける |
| 提案データ | `assets/data/suggestions.json` | 提案候補を管理する |
| 履歴保存 | shared_preferences 予定 | ログインなしで端末内に履歴を保存する |
| テスト | flutter_test | ロジック・Widget のテストを行う |

詳細は以下を参照してください。

- [Flutter 技術解説](./docs/Flutter技術解説.md)
- [AI・バックエンド・データベース導入ガイド](./docs/AI・バックエンド・データベース導入ガイド.md)
- [デザイン参考サイト集](./docs/デザイン参考サイト集.md)

---

## フロントエンド・バックエンド・データベースの考え方

MVP では、Flutter アプリ内で完結させます。

```text
フロントエンド: Flutter アプリ
バックエンド: なし
データベース: 端末内保存
初期提案データ: assets/data/suggestions.json
```

AI 提案を入れる発展 Phase では、以下の構成を検討します。

```text
Flutter アプリ
↓
Firebase Authentication
↓
Cloud Functions for Firebase
↓
OpenAI API
↓
Cloud Firestore
```

AI API キーを Flutter アプリに直接入れないため、OpenAI API は Cloud Functions から呼びます。

詳細は以下を参照してください。

- [AI・バックエンド・データベース導入ガイド](./docs/AI・バックエンド・データベース導入ガイド.md)

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
│  ├─ AI・バックエンド・データベース導入ガイド.md
│  ├─ コーディング規則の考え方.md
│  ├─ デザイン参考サイト集.md
│  ├─ 環境構築手順.md
│  ├─ ファイル分けを行う理由.md
│  ├─ Flutter技術解説.md
│  ├─ iOS導入方針と確認環境の懸念.md
│  ├─ GitHubEducation申請手順.md
│  ├─ GitHub開発フロー.md
│  ├─ 実装計画.md
│  ├─ 要件定義.md
│  ├─ 仕様要約.md
│  ├─ 企画書.md
│  └─ vscode-Git使い方メモ.md
├─ archive/
│  └─ old-web-version/
└─ .github/
   ├─ ISSUE_TEMPLATE/
   └─ pull_request_template.md
```

`android/` と `ios/` は Flutter の生成ファイルが多いため、開発環境で生成します。

MVP では Android 用 platform ファイルだけを生成します。

```bash
flutter create --platforms=android .
```

発展版で iOS を導入する段階になったら、iOS 用 platform ファイルを追加生成します。

```bash
flutter create --platforms=ios .
```

旧Web版の `src/` やGoogle Calendar前提の古い要件書は、現在のFlutter版と混ざらないように `archive/old-web-version/` へ移動しています。通常の開発では、リポジトリ直下の `lib/`、`assets/`、`docs/` を見ます。

---

## セットアップ

詳しい手順は以下を参照してください。

- [環境構築手順](./docs/環境構築手順.md)

Flutter 公式サイトが見にくい場合は、まず上の環境構築手順にある「Windows + VS Code で入れる最短手順」だけ確認してください。このリポジトリの MVP では Android 開発に必要な内容へ絞っています。

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
| Flutter 技術構成と選定理由 | [Flutter 技術解説](./docs/Flutter技術解説.md) |
| AI・バックエンド・DB導入方針 | [AI・バックエンド・データベース導入ガイド](./docs/AI・バックエンド・データベース導入ガイド.md) |
| iOS 導入方針と確認環境の懸念 | [iOS 導入方針と確認環境に関する懸念](./docs/iOS導入方針と確認環境の懸念.md) |
| Material 3 やスマホ UI の参考例 | [デザイン参考サイト集](./docs/デザイン参考サイト集.md) |
| 開発者向けのコーディング規則の説明 | [コーディング規則の考え方](./docs/コーディング規則の考え方.md) |
| ファイル分けを行う理由の説明 | [ファイル分けを行う理由](./docs/ファイル分けを行う理由.md) |
| Issue・Branch・Pull Request を使う理由 | [GitHub 開発フロー](./docs/GitHub開発フロー.md) |
| VS Code で Git を操作する方法 | [VS Code Git 操作ガイド](./docs/vscode-Git使い方メモ.md) |

---

## 困ったときのリンク集

| 分からないこと | 見るページ |
|---|---|
| 環境構築、起動方法、エミュレータ確認 | [環境構築手順](./docs/環境構築手順.md) |
| 何から実装すればよいか | [実装計画](./docs/実装計画.md) |
| アプリの仕様を確認したい | [仕様要約](./docs/仕様要約.md) |
| Flutter を選ぶ理由や技術構成を確認したい | [Flutter 技術解説](./docs/Flutter技術解説.md) |
| AI・バックエンド・データベース構成を確認したい | [AI・バックエンド・データベース導入ガイド](./docs/AI・バックエンド・データベース導入ガイド.md) |
| iOS 導入方針と確認環境のリスクを確認したい | [iOS 導入方針と確認環境に関する懸念](./docs/iOS導入方針と確認環境の懸念.md) |
| Material 3 やスマホ UI の参考サイトを確認したい | [デザイン参考サイト集](./docs/デザイン参考サイト集.md) |
| コーディング規則の理由を確認したい | [コーディング規則の考え方](./docs/コーディング規則の考え方.md) |
| ファイル分けの理由を確認したい | [ファイル分けを行う理由](./docs/ファイル分けを行う理由.md) |
| Issue・Branch・Pull Request の理由を確認したい | [GitHub 開発フロー](./docs/GitHub開発フロー.md) |
| VS Code で Git 操作をしたい | [VS Code Git 操作ガイド](./docs/vscode-Git使い方メモ.md) |
| AI agent に守らせる規則を確認したい | [AI Agent Rules](./docs/AGENTS.md) |
| GitHub Education に応募したい | [GitHub Education 申請手順](./docs/GitHubEducation申請手順.md) |

---

## 実装順序

1. Flutter プロジェクトとして起動できる状態にする
2. ホーム・提案・履歴・設定画面を作る
3. 興味カテゴリの登録 UI を作る
4. `suggestions.json` の提案データを増やす
5. 選択時間に合う提案を抽出する
6. ランダム提案を実装する
7. Android で通知時刻設定を作る
8. Android でローカル通知を実装する
9. Android で通知アクションから提案画面へ遷移する
10. 実施・スキップ履歴を保存する
11. Android 版 MVP として動作確認する

詳細は以下を参照してください。

- [実装計画](./docs/実装計画.md)
- [仕様要約](./docs/仕様要約.md)
- [Flutter 技術解説](./docs/Flutter技術解説.md)
- [AI・バックエンド・データベース導入ガイド](./docs/AI・バックエンド・データベース導入ガイド.md)
- [iOS 導入方針と確認環境に関する懸念](./docs/iOS導入方針と確認環境の懸念.md)

---

## 発展機能

MVP 完成後、余裕があれば以下を検討します。

- iOS 版の platform ファイル生成、ビルド、実機確認
- iOS 通知許可・ローカル通知・通知アクション対応
- iOS 実機確認の自動化または TestFlight 配布
- AI API による提案候補生成
- Firebase Authentication によるユーザー識別
- Cloud Functions によるバックエンド処理
- Cloud Firestore によるクラウド保存
- YouTube API 連携
- 音楽サービス連携
- Google Calendar 連携
- 予定間の空き時間自動検出
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

iOS については、チーム内に macOS 環境がないため、MVP には含めず、Android 版 MVP が成立した後の発展版で導入します。

AI 提案を導入する場合も、通知時に毎回 AI を呼ぶのではなく、AI で提案候補をまとめて生成して保存し、通知時は保存済み候補からランダムに表示する方針にします。
