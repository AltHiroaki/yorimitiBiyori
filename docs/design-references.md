# デザイン参考サイト集

よりみち日和の UI を考えるときに参照するサイトをまとめます。

MVP では、最初から独自デザインを作り込むのではなく、Material 3 の標準コンポーネントを使って、画面構成・余白・ボタン・カード・ナビゲーションを整える方針にします。

---

## 優先して見るサイト

| サイト | 種類 | 見る目的 | URL |
|---|---|---|---|
| Material Design 3 | 公式デザインシステム | Google の Material 3 全体像、色、余白、タイポグラフィ、コンポーネントを確認する | https://m3.material.io/ |
| Material 3 Components | 公式コンポーネント一覧 | Button、Card、Navigation Bar、Dialog などの見た目と使い方を確認する | https://m3.material.io/components |
| Material Design 3 for Flutter | 公式 Flutter 向け説明 | Flutter で Material 3 を使う前提を確認する | https://m3.material.io/develop/flutter |
| Flutter Material widgets | Flutter 公式 | Flutter で使える Material 系 Widget を確認する | https://docs.flutter.dev/ui/widgets/material |
| Android Design & Plan | Android 公式 | Android アプリとして自然な UI 設計を確認する | https://developer.android.com/design |
| Apple Human Interface Guidelines | Apple 公式 | iOS アプリとして違和感が少ない画面設計を確認する | https://developer.apple.com/design/human-interface-guidelines |
| Mobbin | 実アプリの UI 事例集 | 実在するスマホアプリの画面、一覧、設定、オンボーディングなどを参考にする | https://mobbin.com/explore/mobile |
| Pttrns | モバイル UI パターン集 | ログイン、設定、一覧、詳細画面などの典型パターンを確認する | https://app.pttrns.com/ |
| Page Flows | UX フロー事例集 | 画面単体ではなく、ユーザーがどう遷移するかを参考にする | https://pageflows.com/ |

---

## よりみち日和で特に参考にする部分

### 1. ホーム画面

参考にするもの:

- Material 3 の Card
- Material 3 の Button
- Material 3 の Navigation Bar
- Mobbin のホーム画面、ダッシュボード画面

設計方針:

- アプリの目的を短く説明する
- 「今日のよりみちを提案する」ボタンを目立たせる
- 下部ナビゲーションで、ホーム・提案・履歴・設定を移動できるようにする

---

### 2. 提案画面

参考にするもの:

- Material 3 の Card
- Material 3 の Filled button
- Material 3 の Assist chip / Filter chip
- Mobbin のレコメンド画面、カード型 UI

設計方針:

- 提案内容を 1 枚のカードで見せる
- 所要時間、カテゴリ、実施ボタン、スキップボタンを分かりやすく置く
- 15 分・30 分・60 分の選択は Chip または SegmentedButton で表現する

---

### 3. 履歴画面

参考にするもの:

- Material 3 の List
- Material 3 の ListItem
- Mobbin / Pttrns の履歴一覧、アクティビティ一覧

設計方針:

- 実施済みとスキップを一覧で確認できるようにする
- 日付、提案タイトル、カテゴリ、結果を簡潔に表示する
- MVP では検索や詳細フィルタは入れず、一覧表示を優先する

---

### 4. 設定画面

参考にするもの:

- Material 3 の List
- Material 3 の Switch
- Material 3 の Dialog
- Apple Human Interface Guidelines の Settings 系パターン

設計方針:

- 興味カテゴリ
- 通知時刻
- 履歴削除
- アプリ情報

を、上から順に分かりやすく並べる。

---

## 初心者向けの使い方

### まず見る順番

1. Material 3 Components で、ボタン・カード・ナビゲーションの見た目を確認する
2. Flutter Material widgets で、実装に使う Widget 名を確認する
3. Mobbin で、似たアプリの画面構成を探す
4. Apple Human Interface Guidelines で、iOS でも違和感が出ないか確認する

---

## MVP で使う予定の主な Flutter Widget

| 目的 | Widget |
|---|---|
| 画面の土台 | `Scaffold` |
| 上部バー | `AppBar` |
| 下部ナビゲーション | `NavigationBar` |
| メインボタン | `FilledButton` |
| サブボタン | `OutlinedButton`, `TextButton` |
| 提案カード | `Card` |
| 履歴一覧 | `ListView`, `ListTile` |
| 時間選択 | `ChoiceChip`, `FilterChip`, `SegmentedButton` |
| 設定項目 | `SwitchListTile`, `ListTile` |
| 確認ダイアログ | `AlertDialog` |

---

## デザイン方針メモ

- MVP では Material 3 の標準デザインを優先する。
- 色は `ColorScheme.fromSeed` で統一する。
- 独自 UI を増やしすぎない。
- 画面ごとの余白、角丸、ボタンの種類を揃える。
- iOS / Android の両方で大きく崩れないシンプルな構成にする。
- 実装が難しいアニメーションや複雑な装飾は、MVP 完成後に検討する。

---

## Flutter 実装時の最小テーマ例

```dart
MaterialApp(
  title: 'よりみち日和',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
    ),
  ),
  home: const HomePage(),
)
```

Flutter 3.16 以降では Material 3 が標準になっているため、基本的には `useMaterial3: true` を明示しなくてもよい。
