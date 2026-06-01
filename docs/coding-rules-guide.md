# コーディング規則の考え方

このドキュメントは、開発者が `yorimitiBiyori` のコーディング規則を理解するための説明です。

AI agent に直接読ませる規則は、以下の2つにまとめています。

- [General Coding Skill](./SKILL.md)
- [AI Agent Rules for yorimitiBiyori](./AGENTS.md)

このファイルでは、規則そのものではなく「なぜそうするのか」を説明します。

---

## なぜ AI 向けの規則を英語にするのか

AI agent に渡す指示は、英語のほうが安定しやすいです。

理由は、コーディング規約、公式ドキュメント、OSS の README、Issue、Pull Request など、プログラミングに関する情報の多くが英語で書かれているためです。

例えば、次のような表現は AI agent にとって解釈しやすいです。

```md
Prioritize readability.
Avoid magic numbers.
Separate UI logic from business logic.
Do not add advanced features before the MVP is stable.
```

一方で、開発者が理由や背景を理解するには日本語のほうが読みやすい場合があります。  
そのため、このリポジトリでは次のように役割を分けます。

| ファイル | 言語 | 目的 |
|---|---|---|
| `docs/SKILL.md` | 英語 | AI agent に読ませる汎用コーディング規則 |
| `docs/AGENTS.md` | 英語 | AI agent に読ませるプロジェクト固有規則 |
| `docs/coding-rules-guide.md` | 日本語 | 開発者が規則の理由を理解するための説明 |

---

## 可読性を最優先する理由

コードは、書く時間よりも読む時間のほうが長くなります。

特にチーム開発では、自分が書いたコードを他のメンバーが読むことがあります。さらに、数日後や数週間後の自分も「他人に近い状態」でコードを読むことになります。

そのため、短く書くことよりも、意図が分かることを優先します。

避けたい例:

```ts
const r = activities.filter((x) => x.t <= m && x.b <= p).sort(() => Math.random() - 0.5)[0];
```

このコードは短いですが、`r`, `x`, `t`, `m`, `b`, `p` が何を意味するのか分かりにくいです。

望ましい例:

```ts
const matchedActivities = activities.filter((activity) => {
  return activity.durationMinutes <= availableMinutes
    && activity.budgetYen <= selectedBudgetYen;
});

const suggestedActivity = getRandomActivity(matchedActivities);
```

行数は増えますが、何をしているかが読みやすくなります。

---

## マジックナンバーを避ける理由

マジックナンバーとは、意味の説明がないままコード中に直接書かれた数値です。

避けたい例:

```ts
if (availableMinutes >= 15) {
  // ...
}
```

この `15` が何を意味するのか、コードだけでは分かりません。

望ましい例:

```ts
const MIN_ACTIVITY_MINUTES = 15;

if (availableMinutes >= MIN_ACTIVITY_MINUTES) {
  // ...
}
```

定数名を付けることで、「この値は最短の活動時間を表している」と分かります。

ただし、すべての数値を定数にする必要はありません。  
例えば、配列の先頭を表す `0` や、パーセンテージ計算の `100` は意味が明確なので、そのまま使っても構いません。

---

## 命名を具体的にする理由

曖昧な名前は、読み手に推測を強制します。

避けたい名前:

```ts
const data = getData();
const result = data.filter((item) => item.flag);
```

このコードでは、何のデータで、何の結果で、何を表すフラグなのか分かりません。

望ましい名前:

```ts
const activities = getActivities();
const matchedActivities = activities.filter((activity) => activity.isAvailable);
```

名前を具体的にするだけで、コメントがなくても処理の意味が伝わりやすくなります。

---

## 関数の責務を分ける理由

1つの関数に複数の責務を詰め込むと、修正時の影響範囲が分かりにくくなります。

避けたい例:

```ts
function suggestAndSaveActivity() {
  // 条件を取得する
  // 行動候補を絞り込む
  // ランダムに選ぶ
  // 履歴に保存する
  // 画面状態を更新する
}
```

この関数は多くのことをやりすぎています。  
どこか1つを変更したいだけでも、他の処理に影響する可能性があります。

望ましい分け方:

```ts
const matchedActivities = filterActivities(activities, condition);
const suggestedActivity = getRandomActivity(matchedActivities);
saveActivityRecord(suggestedActivity);
```

処理を分けることで、それぞれの関数の目的が明確になります。

---

## UI とロジックを分ける理由

React コンポーネントにすべての処理を書くと、画面表示とアプリのロジックが混ざります。

混ざりやすい処理の例:

- 行動候補の絞り込み
- ランダム提案
- 実施率の計算
- localStorage の読み書き
- 日付表示の整形

これらをページコンポーネントに直接書きすぎると、画面が大きくなり、修正しづらくなります。

例えば、提案ロジックは以下のように分けると扱いやすくなります。

```ts
const matchedActivities = filterActivities(activities, condition);
const suggestedActivity = getRandomActivity(matchedActivities);
```

画面側は「何を表示するか」に集中し、ロジック側は「どう計算するか」に集中できます。

---

## MVP を優先する理由

`yorimitiBiyori` では、まず授業内で完成できる範囲の MVP を作ることを優先します。

Google ログイン、Google Calendar API、Firebase、Google Maps API、位置情報取得などは便利ですが、初期段階では実装難度が上がります。  
これらを早く入れすぎると、中心機能である「条件入力 → 行動提案 → 履歴保存」が完成しない可能性があります。

そのため、MVP では次の流れを安定させることを優先します。

```text
条件入力 → 行動提案 → 実施 / スキップ記録 → 履歴表示
```

発展機能は、MVP が動いてから追加します。

---

## localStorage を使う理由

MVP ではログイン機能やクラウド保存を使わないため、履歴は `localStorage` に保存します。

これにより、Firebase や認証機能を実装しなくても、ブラウザ内に履歴を残せます。

ただし、`localStorage` には注意点があります。

- ユーザーがブラウザデータを消すと履歴も消える
- 別の端末とは共有されない
- `JSON.parse` に失敗する可能性がある
- 保存データの形式を変えると古いデータと合わなくなる可能性がある

そのため、読み書き処理は専用関数に分け、安全に扱う必要があります。

---

## 外部ライブラリを勝手に追加しない理由

外部ライブラリを追加すると、一見便利になりますが、管理するものも増えます。

- 依存関係が増える
- バージョン管理が必要になる
- ビルドサイズが増える可能性がある
- 使い方をチーム全員が理解する必要がある
- 将来の更新や互換性対応が必要になる

小さな処理であれば、TypeScript、React、ブラウザ標準 API で十分な場合が多いです。

そのため、新しいライブラリは「本当に必要な場合だけ」追加します。

---

## コメントには「なぜ」を書く理由

コードを読めば分かる内容をコメントしても、あまり役に立ちません。

避けたい例:

```ts
// records を保存する
localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
```

このコメントは、コードを読めば分かる内容を繰り返しているだけです。

望ましい例:

```ts
// MVP ではログイン機能を使わないため、履歴はブラウザ内だけに保存する。
localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
```

このコメントは「なぜ localStorage なのか」を説明しています。  
後から読んだ人が設計意図を理解しやすくなります。

---

## 過度な抽象化を避ける理由

共通化は重要ですが、早すぎる共通化は逆に読みにくくなることがあります。

まだ1箇所でしか使っていない処理を無理に汎用化すると、実際には不要な引数や分岐が増えることがあります。

基本方針は次の通りです。

1. まずは素直に書く
2. 同じ処理が複数回出てきたら共通化を検討する
3. 共通化するときは、名前と責務を明確にする

「重複を避けること」よりも「読みやすく保つこと」を優先します。

---

## 開発時の使い方

AI agent に作業を依頼するときは、必要に応じて次のファイルを渡します。

```text
docs/SKILL.md
docs/AGENTS.md
```

開発者がルールの理由を確認したいときは、このファイルを読みます。

```text
docs/coding-rules-guide.md
```

AI にそのまま指示したい場合は、`docs/SKILL.md` または `docs/AGENTS.md` のコードブロック部分をコピーして使います。
