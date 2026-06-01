# General Coding Skill

このドキュメントは、AI agent または開発者がコードを編集するときに守る、プロジェクト横断の基本的なコーディング規則を定める。

## 基本方針

コードの可読性を最優先する。

短く書くことよりも、後から読んだときに意図が分かることを優先する。複雑な一行の処理よりも、意味のある変数名・関数名を使い、処理を段階的に表現する。

実装では以下の順序を重視する。

1. 正しく動作すること
2. 読みやすいこと
3. 変更しやすいこと
4. 必要十分に簡潔であること

## 可読性

- 処理の目的が分かる名前を使う
- 複雑な式は、意味のある中間変数に分ける
- 一つの関数やコンポーネントに複数の責務を詰め込みすぎない
- 早期 return を使い、深いネストを避ける
- 将来の自分や他の開発者が読んでも理解しやすい形を優先する

避ける例:

```ts
const r = items.filter((x) => x.a <= m && x.b <= p).sort(() => Math.random() - 0.5)[0];
```

望ましい例:

```ts
const matchedItems = items.filter((item) => {
  return item.requiredMinutes <= availableMinutes
    && item.requiredBudget <= selectedBudget;
});

const selectedItem = getRandomItem(matchedItems);
```

## 命名

変数名、関数名、型名、コンポーネント名は、役割が分かる具体的な名前にする。

避ける名前:

- `data`
- `item`
- `temp`
- `result`
- `flag`
- `value`
- `handleClick`

ただし、狭いスコープで意味が明確な場合は例外としてよい。

望ましい名前:

- `activities`
- `matchedActivities`
- `selectedActivity`
- `activityRecords`
- `isHistoryEmpty`
- `handleSubmitCondition`

## マジックナンバー

意味のある数値をコード中に直接書かない。数値には名前付き定数を使い、何を表す値なのか分かるようにする。

避ける例:

```ts
if (availableMinutes >= 15) {
  // ...
}
```

望ましい例:

```ts
const MIN_ACTIVITY_MINUTES = 15;

if (availableMinutes >= MIN_ACTIVITY_MINUTES) {
  // ...
}
```

例外として、以下のように意味が明らかな値は直接書いてよい。

- 配列の先頭を表す `0`
- 1件増やすための `+ 1`
- percentage 計算の `100`
- 真偽値や空文字列など、意味が明確なプリミティブ値
- UI のごく局所的な指定値

## 型安全性

- `any` は原則使用しない
- データ構造には明示的な型を定義する
- null または undefined の可能性がある値は、事前に分岐して安全に扱う
- 型エラーを無視するための型アサーションは最小限にする
- 型定義は実際のデータ構造と一致させる

避ける例:

```ts
function saveRecord(record: any) {
  // ...
}
```

望ましい例:

```ts
type ActivityRecord = {
  id: string;
  activityId: string;
  status: "done" | "skipped";
  createdAt: string;
};

function saveRecord(record: ActivityRecord) {
  // ...
}
```

## 関数の責務

1つの関数には1つの目的だけを持たせる。

以下の処理を1つの関数に詰め込みすぎない。

- 入力値の取得
- データの絞り込み
- ランダム選択
- 保存処理
- 画面状態の更新
- 表示用テキストの生成

処理が長くなる場合は、意味のある単位で関数に分ける。

## 条件分岐

深いネストを避ける。異常系や処理できないケースを先に return し、正常系の流れを読みやすくする。

避ける例:

```ts
if (user) {
  if (records.length > 0) {
    if (selectedRecord) {
      // ...
    }
  }
}
```

望ましい例:

```ts
if (!user) {
  return;
}

if (records.length === 0) {
  return;
}

if (!selectedRecord) {
  return;
}

// ...
```

## コメント

コメントには「何をしているか」ではなく「なぜそうしているか」を書く。

避けるコメント:

```ts
// records を保存する
localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
```

望ましいコメント:

```ts
// ログインなしの MVP では、履歴をブラウザ内だけに保存する。
localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
```

コードを読めば分かる処理をそのまま説明するコメントは避ける。

## 重複と共通化

同じ処理が複数箇所に出てきた場合は共通化を検討する。

ただし、将来の使い道が不明な段階で過度に抽象化しない。まずは読みやすく素直に実装し、明確な重複が出てきた段階で共通化する。

## 副作用の扱い

副作用を持つ処理は、できるだけ分離する。

副作用の例:

- localStorage の読み書き
- API 通信
- 画面遷移
- console 出力
- 現在時刻の取得
- ランダム値の生成

純粋な計算処理と副作用を分けることで、動作確認と修正をしやすくする。

## エラーハンドリング

- 失敗する可能性がある処理にはエラー処理を用意する
- JSON.parse、localStorage、外部 API、日付変換などは失敗しうる前提で扱う
- エラー時にも画面が壊れないようにする
- ユーザーに見せるエラーメッセージは、短く具体的にする

## 依存関係

- 新しい外部ライブラリは、明確な必要性がある場合のみ追加する
- 標準機能で十分に実装できる処理に、不要なライブラリを追加しない
- ライブラリを追加する場合は、用途と影響範囲を説明する

## 変更時の注意

既存コードを変更するときは、以下を意識する。

- 変更の目的を明確にする
- 影響範囲を小さく保つ
- 関係のないリファクタリングを混ぜすぎない
- 既存の仕様やドキュメントと矛盾しないようにする
- 変更後に可能な範囲でビルドまたは動作確認を行う
