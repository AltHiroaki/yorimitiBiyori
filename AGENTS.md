# AI Agent Rules for yorimitiBiyori

このドキュメントは、AI agent が `yorimitiBiyori` のコードを編集するときに守るプロジェクト固有の規則を定める。

汎用的なコード品質ルールは `SKILL.md` を参照する。このファイルでは、`yorimitiBiyori` 固有の技術構成、MVP 方針、ディレクトリ責務、実装上の制約を扱う。

## 最優先方針

このプロジェクトでは、まず MVP の完成を最優先する。

中心機能は以下である。

1. 空き時間・強度・場所・予算を入力する
2. 条件に合う行動を提案する
3. 実施・スキップを記録する
4. 履歴と実施率を表示する

MVP 完成前に、発展機能を勝手に追加しない。

## MVP で実装する機能

初期実装で扱う機能は以下に限定する。

- 空き時間の手動入力
- 強度の選択
- 場所の選択
- 予算の選択
- 条件に合う行動提案
- 別の提案の再表示
- 実施記録
- スキップ記録
- 履歴表示
- 実施率の表示

## MVP では実装しない機能

以下は MVP 完成後の発展機能とする。明確な指示がない限り実装しない。

- Google ログイン
- Google Calendar API
- Firebase Authentication
- Firestore
- Google Maps API / Places API
- 位置情報取得
- 予定間の空き時間自動検出
- ユーザーごとのクラウド保存

## 技術スタック

このプロジェクトでは以下を基本技術として使用する。

- React
- TypeScript
- Vite
- Tailwind CSS
- React Router
- localStorage
- JSON データ

新しい外部ライブラリは、明確な指示がある場合のみ追加する。単純な処理は、まず TypeScript と React の標準的な機能で実装する。

## ディレクトリ責務

基本的なディレクトリ責務は以下とする。

- `src/app/`
  - ルーティングやアプリ全体の設定を置く
  - 例: `router.tsx`

- `src/pages/`
  - 画面単位のコンポーネントを置く
  - 例: `HomePage.tsx`, `SuggestPage.tsx`, `HistoryPage.tsx`, `SettingsPage.tsx`

- `src/components/`
  - 複数画面で再利用する UI コンポーネントを置く
  - layout や button/card などの共通 UI を含める

- `src/features/`
  - 機能単位のロジックやコンポーネントを置く
  - 例: `activities`, `recommendation`, `records`

- `src/data/`
  - アプリ内で使用する静的データを置く
  - 行動候補は `activities.json` にまとめる

- `src/types/`
  - アプリ全体で使う TypeScript 型を置く

- `src/utils/`
  - 汎用的な関数を置く

既存のディレクトリ構成を大きく変更しない。変更が必要な場合は、目的と影響範囲を明確にする。

## TypeScript ルール

- `any` は原則使用しない
- 行動データ、検索条件、履歴データには明示的な型を定義する
- 複数箇所で使う型は `src/types/` に置く
- 画面内だけで使う小さな型は、そのファイル内に定義してよい
- null または undefined の可能性がある値は、事前に分岐して扱う

想定する代表的な型の例:

```ts
type Intensity = "low" | "medium" | "high";

type Activity = {
  id: string;
  title: string;
  description: string;
  durationMinutes: number;
  intensity: Intensity;
  location: string;
  budgetYen: number;
};

type ActivityRecord = {
  id: string;
  activityId: string;
  status: "done" | "skipped";
  createdAt: string;
};
```

実際の型は、`activities.json` と画面仕様に合わせて調整する。

## React ルール

- コンポーネントは関数コンポーネントで書く
- props には TypeScript の型を付ける
- ページコンポーネントには画面全体の責務を持たせる
- 再利用できる UI は `src/components/` に分離する
- ビジネスロジックが大きくなった場合は `src/features/` または `src/utils/` に分離する
- JSX 内に複雑な条件分岐や配列処理を書きすぎない

## UI とロジックの分離

React コンポーネントには、できるだけ表示の責務を持たせる。

以下の処理は、必要に応じて `features` または `utils` に分離する。

- 行動候補の絞り込み
- ランダム提案
- 実施率の計算
- localStorage の読み書き
- 入力値の変換
- 日付や時刻の整形

## 行動データ

行動候補は `src/data/activities.json` で管理する。

行動データを変更する場合は、以下に注意する。

- 各データに一意な `id` を持たせる
- 表示名と説明文は、ユーザーにとって分かりやすくする
- 空き時間、強度、場所、予算による絞り込みに必要な値を欠かさない
- JSON の構造を変更する場合は、対応する TypeScript 型も更新する

## 行動提案ロジック

- 提案条件は、空き時間・強度・場所・予算を基本とする
- 条件に合う行動を `activities.json` から抽出する
- 提案ロジックは UI コンポーネントに直接書かず、関数として分離する
- ランダム提案は、同じ条件で再利用できるように実装する
- 条件に合う候補がない場合の表示も必ず用意する
- 同じ提案を再表示しすぎないようにする場合も、まずは単純な実装を優先する

## 履歴保存

履歴保存には `localStorage` を使用する。

- 保存キーは定数として定義する
- localStorage の読み書き処理は、直接ページに書かず、専用関数に分離する
- `JSON.parse` は失敗する可能性があるため、安全に扱う
- 保存データの形式を変更する場合は、既存データとの互換性に注意する
- 履歴削除機能では、削除対象が分かる UI にする

保存キーの例:

```ts
const STORAGE_KEY = "yorimiti-biyori-records";
```

## 実施率の計算

実施率は、履歴のうち `done` と `skipped` の合計に対する `done` の割合として扱う。

履歴が 0 件の場合は、0% または未記録として扱い、ゼロ除算を避ける。

## スタイリング

- スタイリングは Tailwind CSS を基本とする
- 似た見た目のボタンやカードは共通コンポーネント化する
- 同じクラスのまとまりを何度も書かない
- スマートフォン表示を優先する
- 色、余白、角丸、影の使い方はアプリ全体で統一する
- UI は大学生が短い空き時間に使いやすい、軽く分かりやすい見た目を優先する

## ルーティング

ルーティング設定は `src/app/router.tsx` にまとめる。

基本パスは以下とする。

```text
/
/suggest
/history
/settings
```

ページコンポーネントは `src/pages/` に置く。

## 変更後の確認

コードを変更した場合は、可能な限り以下を実行する。

```bash
npm run build
```

ビルドエラーが出る場合は、エラー内容を確認して修正する。

ローカルで確認できない場合は、未確認であることを明示する。

## 禁止事項

- 指示なしに外部ライブラリを追加しない
- MVP 範囲外の機能を勝手に実装しない
- Google API、Firebase、Maps API、位置情報取得を勝手に追加しない
- 既存のディレクトリ構成を大きく変更しない
- `any` を多用しない
- UI とロジックを過度に混在させない
- README や docs に書かれた仕様と矛盾する実装をしない
- 動いている機能を大きく書き換える場合に、影響範囲を説明せず変更しない
- 既存の目的と関係のないリファクタリングを混ぜすぎない

## 判断に迷った場合

判断に迷った場合は、以下の優先順位で決める。

1. README と docs に書かれた仕様を守る
2. MVP 完成に近づく変更を優先する
3. 可読性と保守性を優先する
4. 実装を複雑にしすぎない
5. 発展機能は後回しにする
