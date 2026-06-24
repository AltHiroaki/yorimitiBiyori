# よりみち日和

> 空いた時間に、小さなよりみちを。

よりみち日和は、ユーザーが登録した興味カテゴリと、時間・予算・移動距離の条件をもとに、空き時間でできる小さな「よりみち」を提案する **Flutter アプリ**です。

企画コンセプトは「好きなことで、いつもと違う角度から。」（企画書）。アプリ内のタグラインは「空いた時間に、小さなよりみちを。」（UI プロトタイプ）です。

当初は Web アプリとして検討していましたが、空き時間にユーザーが自分からアプリを開くよりも、スマホ通知をきっかけに使える体験の方がアプリの目的に合うため、Flutter によるネイティブアプリ開発へ方針を変更します。

MVP では **Android 版のみ**を実装・検証対象にします。iOS は MVP 完成後の発展版で導入します。

---

## 仕様の正本

仕様の正本は以下の 2 つです。リポジトリ内のドキュメントと食い違う場合は、こちらを優先します。

| 正本 | 担当する内容 |
|---|---|
| 企画書（[docs/spec/企画書.md](./docs/spec/企画書.md)・提出版 PDF） | コンセプト、データ設計（行動カタログ）、処理フロー、発展方針 |
| [よりみち日和 UIプロトタイプ/](./よりみち日和%20UIプロトタイプ/) | 画面構成、UI 文言、操作フロー（Figma 書き出しの React プロトタイプ。**参照専用**） |

実装者向けの要約は [仕様要約](./docs/spec/仕様要約.md) にまとめています。

---

## 企画の位置づけ

本アプリは、予定管理アプリではなく、空き時間に「何をするか」を軽く決めるための提案アプリです。

このアプリで扱う「寄り道」は、物理的な移動だけではありません。

- 近くを 15 分だけ散歩する
- 普段聴かない音楽を 1 曲だけ聴く
- 気になるテーマを少し調べる
- 近くのカフェで本を読む

つまり、**興味の寄り道**を提案するアプリとして設計します。

---

## 初期実装版 MVP

授業内で確実に完成させるため、MVP では機能と対象プラットフォームを絞ります。MVP の対象は **Android のみ**です。

### 初期実装で入れるもの

- オンボーディング（初回起動モーダル → 興味カテゴリ選択 → 通知許可）
- 興味カテゴリの登録（散歩 / 音楽 / 読書 / 学習 / カフェ / 写真 / 整理 / 休憩 / 運動 / 買い物 の 10 種から複数選択）
- 提案設定（使える時間・予算・移動距離は初期表示「指定なし」。プルダウンで変更、カテゴリは複数選択）
- 通知時刻の設定（デフォルト 17:30）とローカル通知の表示
- 通知アクションによる時間選択
  - 15 分
  - 30 分
  - 60 分
- 条件に合う提案の表示（現在の提案条件カード＋今日のよりみちカード）
- 別の提案の再表示（表示中の提案はスキップとして記録）
- 実施記録（完了モーダルで「よかった / 普通 / 合わなかった」のフィードバック付き）
- 履歴表示（実施数 / スキップ数 / 合計時間＋履歴一覧）
- 履歴削除（確認付き）
- 設定画面

### 初期実装で入れないもの

- ユーザーログイン・Google アカウント連携（設定画面に「未連携」表示のみ）
- Google Calendar API
- Firebase Authentication
- Firestore
- Google Maps API / Places API
- 位置情報取得
- YouTube API 連携
- 音楽サービス連携
- AI API（Claude API）によるリアルタイム生成

これらは発展機能として、MVP が完成した後に段階的に検討します。

---

## MVP 対象プラットフォーム

現時点では、チーム内に macOS 環境がありません。

そのため、MVP では **Android のみを実装・検証対象** とします。

- Android は Windows PC + Android Emulator / Android 実機で確認する
- iOS は MVP には含めない
- iOS 導入は、Mac の一時借用またはクラウドビルド + TestFlight を使う発展版タスクとして扱う

詳細は以下を参照してください。

- [iOS 導入方針と確認環境に関する懸念](./docs/tech/iOS導入方針と確認環境の懸念.md)

---

## 技術構成

| 分類 | 使用技術 | 用途 |
|---|---|---|
| アプリフレームワーク | Flutter | MVP では Android 版を実装し、発展版で iOS に展開しやすくする |
| 言語 | Dart | Flutter アプリの実装に使う |
| UI | Material 3 | グリーン基調（プロトタイプの primary `#3F6F44`）。カード・チップ・ナビゲーションを構築する |
| 通知 | flutter_local_notifications 予定 | ローカル通知と通知アクションを扱う |
| 画面遷移 | Flutter 標準 / 将来的に go_router | 提案・履歴・設定画面と提案設定サブ画面を切り替える |
| 状態管理 | 初期は StatefulWidget、必要に応じて Riverpod | MVP では複雑化を避ける |
| 提案データ | `assets/data/suggestions.json` | 提案候補を管理する（企画書スキーマ・50 件以上） |
| 履歴保存 | shared_preferences 予定 | ログインなしで端末内に履歴を保存する |
| テスト | flutter_test | ロジック・Widget のテストを行う |

詳細は以下を参照してください。

- [Flutter 技術解説](./docs/tech/Flutter技術解説.md)
- [AI・バックエンド・データベース導入ガイド](./docs/tech/AI・バックエンド・データベース導入ガイド.md)
- [デザイン参考サイト集](./docs/tech/デザイン参考サイト集.md)

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
Claude API
↓
Cloud Firestore
```

AI API キーを Flutter アプリに直接入れないため、Claude API は Cloud Functions から呼びます。

詳細は以下を参照してください。

- [AI・バックエンド・データベース導入ガイド](./docs/tech/AI・バックエンド・データベース導入ガイド.md)

---

## 画面構成

UI プロトタイプ（`よりみち日和 UIプロトタイプ/`）の 3 タブ構成に従います。**ホーム画面はありません**（提案タブがトップ画面）。

| 画面 | 役割 |
|---|---|
| 提案画面（タブ1） | 現在の提案条件カードと「今日のよりみち」を表示する。やってみる / 別の提案 |
| 履歴画面（タブ2） | 実施数・スキップ数・合計時間と、実施・スキップした提案の一覧を表示する |
| 設定画面（タブ3） | 提案設定・興味カテゴリ・通知時刻・通知 ON/OFF・履歴削除などを管理する |
| 提案設定画面（サブ） | 使える時間・予算・移動距離・興味カテゴリを編集する |
| オンボーディング | 初回起動モーダル → 興味カテゴリ選択 → 通知許可モーダル |
| 提案完了モーダル | 「やってみる」後にフィードバック（よかった / 普通 / 合わなかった）を記録する |

---

## ディレクトリ構成

```text
yorimitiBiyori/
├─ README.md
├─ CLAUDE.md                  ← AI agent 向けの入口（docs/rules/AGENTS.md へ誘導）
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
│     │  ├─ suggestion_page.dart
│     │  ├─ history_page.dart
│     │  └─ settings_page.dart
│     └─ widgets/
│        └─ section_card.dart
├─ test/
│  └─ widget_test.dart
├─ docs/
│  ├─ rules/
│  │  ├─ AGENTS.md
│  │  ├─ SKILL.md
│  │  ├─ コーディング規則の考え方.md
│  │  └─ ファイル分けを行う理由.md
│  ├─ spec/
│  │  ├─ 企画書.md
│  │  ├─ 仕様書.md
│  │  ├─ 仕様要約.md
│  │  └─ 要件定義.md
│  ├─ planning/
│  │  ├─ 実装計画.md
│  │  ├─ これからやること.md
│  │  └─ 工程計画.md
│  ├─ setup/
│  │  ├─ 環境構築手順.md
│  │  └─ GitHubEducation申請手順.md
│  ├─ git/
│  │  ├─ GitHub開発フロー.md
│  │  ├─ Git操作ガイド.md
│  │  └─ Gitの動作理由メモ.md
│  └─ tech/
│     ├─ Flutter技術解説.md
│     ├─ AI・バックエンド・データベース導入ガイド.md
│     ├─ iOS導入方針と確認環境の懸念.md
│     └─ デザイン参考サイト集.md
├─ よりみち日和 UIプロトタイプ/   ← Figma 書き出しの React プロトタイプ（参照専用）
├─ android/                      ← flutter create --platforms=android . で生成
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

`よりみち日和 UIプロトタイプ/` は Figma から書き出した React プロジェクトで、画面デザイン・文言・操作フローの参照専用です。React のコードや依存を Flutter 実装に持ち込まないでください。

---

## セットアップ

詳しい手順は以下を参照してください。

- [環境構築手順](./docs/setup/環境構築手順.md)

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
| AI agent に読ませる汎用コーディング規則 | [General Coding Skill](./docs/rules/SKILL.md) |
| AI agent に読ませるよりみち日和専用規則 | [AI Agent Rules](./docs/rules/AGENTS.md) |
| Flutter 技術構成と選定理由 | [Flutter 技術解説](./docs/tech/Flutter技術解説.md) |
| AI・バックエンド・DB導入方針 | [AI・バックエンド・データベース導入ガイド](./docs/tech/AI・バックエンド・データベース導入ガイド.md) |
| iOS 導入方針と確認環境の懸念 | [iOS 導入方針と確認環境に関する懸念](./docs/tech/iOS導入方針と確認環境の懸念.md) |
| Material 3 やスマホ UI の参考例 | [デザイン参考サイト集](./docs/tech/デザイン参考サイト集.md) |
| 開発者向けのコーディング規則の説明 | [コーディング規則の考え方](./docs/rules/コーディング規則の考え方.md) |
| ファイル分けを行う理由の説明 | [ファイル分けを行う理由](./docs/rules/ファイル分けを行う理由.md) |
| Issue・Branch・Pull Request を使う理由 | [GitHub 開発フロー](./docs/git/GitHub開発フロー.md) |
| VS Code で Git を操作する方法 | [Git 操作ガイド](./docs/git/Git操作ガイド.md) |

---

## 困ったときのリンク集

| 分からないこと | 見るページ |
|---|---|
| 環境構築、起動方法、エミュレータ確認 | [環境構築手順](./docs/setup/環境構築手順.md) |
| 次に何をやるか知りたい | [これからやること](./docs/planning/これからやること.md) |
| 何から実装すればよいか | [実装計画](./docs/planning/実装計画.md) |
| Issue をどの順番で立てればよいか | [工程計画](./docs/planning/工程計画.md) |
| アプリの仕様を確認したい | [仕様書](./docs/spec/仕様書.md)（詳細）/ [仕様要約](./docs/spec/仕様要約.md)（短縮版） |
| 要件を確認したい | [要件定義](./docs/spec/要件定義.md) |
| Flutter を選ぶ理由や技術構成を確認したい | [Flutter 技術解説](./docs/tech/Flutter技術解説.md) |
| AI・バックエンド・データベース構成を確認したい | [AI・バックエンド・データベース導入ガイド](./docs/tech/AI・バックエンド・データベース導入ガイド.md) |
| iOS 導入方針と確認環境のリスクを確認したい | [iOS 導入方針と確認環境に関する懸念](./docs/tech/iOS導入方針と確認環境の懸念.md) |
| Material 3 やスマホ UI の参考サイトを確認したい | [デザイン参考サイト集](./docs/tech/デザイン参考サイト集.md) |
| コーディング規則の理由を確認したい | [コーディング規則の考え方](./docs/rules/コーディング規則の考え方.md) |
| ファイル分けの理由を確認したい | [ファイル分けを行う理由](./docs/rules/ファイル分けを行う理由.md) |
| Issue・Branch・Pull Request の理由を確認したい | [GitHub 開発フロー](./docs/git/GitHub開発フロー.md) |
| Git のコマンドを確認したい | [Git 操作ガイド](./docs/git/Git操作ガイド.md) / [Git の動作理由メモ](./docs/git/Gitの動作理由メモ.md) |
| VS Code で Git 操作をしたい | [Git 操作ガイド](./docs/git/Git操作ガイド.md) |
| AI agent に守らせる規則を確認したい | [AI Agent Rules](./docs/rules/AGENTS.md) |
| GitHub Education に応募したい | [GitHub Education 申請手順](./docs/setup/GitHubEducation申請手順.md) |

---

## 実装順序

1. Flutter プロジェクトとして起動できる状態にする
2. 提案・履歴・設定の 3 タブと提案設定サブ画面の骨格を作る
3. `suggestions.json` を企画書スキーマで整備する（50 件以上）
4. 提案ロジック（時間・予算・移動距離・カテゴリ・直近除外・weight）を実装する
5. オンボーディング（初回起動 → カテゴリ選択 → 通知許可）を作る
6. 提案設定画面と「現在の提案条件」カードを作る
7. 完了モーダル（フィードバック）と実施・スキップ履歴の保存を作る
8. Android で通知時刻設定・ローカル通知を実装する
9. Android で通知アクションから提案画面へ遷移する
10. UI をプロトタイプのデザインに合わせて調整する
11. Android 版 MVP として動作確認する

詳細は以下を参照してください。

- [これからやること](./docs/planning/これからやること.md)
- [実装計画](./docs/planning/実装計画.md)
- [工程計画（Issue 化用ロードマップ）](./docs/planning/工程計画.md)
- [仕様書](./docs/spec/仕様書.md)

---

## 発展機能

MVP 完成後、余裕があれば以下を検討します。

- 提案候補の増加（各カテゴリ 20 件以上、料理・映画カテゴリの追加）
- 通知時間帯のランダム化（例：17:00〜21:00 の範囲を指定し、その範囲内で毎日 1 回ランダムに通知する）
- Claude API による提案詳細（detail）の動的生成
- iOS 版の platform ファイル生成、ビルド、実機確認
- iOS 通知許可・ローカル通知・通知アクション対応
- iOS 実機確認の自動化または TestFlight 配布
- Firebase Authentication によるユーザー識別（設定画面の Google アカウント連携を有効化）
- Cloud Functions によるバックエンド処理
- Cloud Firestore によるクラウド保存
- YouTube API 連携
- 音楽サービス連携
- Google Calendar 連携・予定間の空き時間自動検出
- 位置情報や周辺スポット提案

---

## メンバー

アプリデザイン総合演習 2026
グループ L1 班

- 信寛昭
- 久保孝輔
- 山本竜聖

---

## 開発メモ

このリポジトリでは、まず MVP を完成させることを優先します。
AI API、YouTube、音楽連携、位置情報は魅力的ですが、初期段階では実装難度が高いため、中心機能である「オンボーディング → 通知 → 時間選択 → 提案 → 履歴保存」を先に安定させます。

iOS については、チーム内に macOS 環境がないため、MVP には含めず、Android 版 MVP が成立した後の発展版で導入します。

AI 提案を導入する場合も、通知時に毎回 AI を呼ぶのではなく、AI で提案候補をまとめて生成して保存し、通知時は保存済み候補からランダムに表示する方針にします。

通知時刻は MVP では固定時刻（デフォルト 17:30）で実装し、発展版ではユーザーが通知時間帯を設定し、その範囲内で毎日ランダムな時刻に通知する方式を検討します。完全な時刻指定よりも、ユーザーの生活リズムに合う範囲だけを決める方が、授業中や深夜など意図しない通知を避けやすくなります。
