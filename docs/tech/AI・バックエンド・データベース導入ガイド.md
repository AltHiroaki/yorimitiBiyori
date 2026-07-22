# AI・バックエンド・データベース導入ガイド

このドキュメントは、`よりみち日和` の発展機能として AI 提案を導入する場合に、フロントエンド・バックエンド・データベースがどのような構成になるかを整理するものです。

ここで扱う Phase は、MVP 実装計画の `Phase 4: 興味カテゴリ登録` ではなく、MVP 完成後の **発展 Phase: AI バックエンド導入** を指します。

---

## 結論

MVP では、バックエンドやクラウドデータベースは使いません。

```text
Flutter アプリ
├─ 画面
├─ 提案ロジック
├─ カテゴリ別提案JSON
├─ ローカル通知
└─ 端末内保存
```

AI 提案を入れる発展 Phase では、以下の構成にします。

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

---

## 役割分担

| 役割 | 技術 | 何をするか |
|---|---|---|
| フロントエンド | Flutter | 興味入力、通知、提案表示、履歴表示 |
| 認証 | Firebase Authentication | ユーザーを識別する |
| バックエンド | Cloud Functions for Firebase | OpenAI API を安全に呼ぶ |
| AI | OpenAI API | 提案候補を生成する |
| データベース | Cloud Firestore | 生成候補、履歴、設定を保存する |
| セキュリティ | Firebase Security Rules / App Check | 不正アクセスや乱用を抑える |

---

## なぜバックエンドが必要なのか

AI 提案を Flutter アプリから直接 OpenAI API に問い合わせる構成は避けます。

悪い構成：

```text
Flutter アプリ
↓
OpenAI API
```

この構成では、OpenAI API キーをアプリ内に入れる必要があります。

スマホアプリは利用者の端末に配布されるため、アプリ内に入れた秘密情報は解析される可能性があります。

そのため、API キーはアプリ側ではなく、バックエンド側で管理します。

安全な構成：

```text
Flutter アプリ
↓
Cloud Functions
↓
OpenAI API
```

Flutter アプリは Cloud Functions を呼び、Cloud Functions が OpenAI API を呼びます。

---

## AI を毎回呼ばない理由

通知のたびに AI を呼ぶ設計は避けます。

理由は以下です。

- 通信が遅いと提案表示が遅れる
- 通信エラー時に提案できない
- API 利用料金が増える
- 連打されたときにコストが読みにくい
- 同じような提案を何度も生成しやすい

そのため、AI は **提案候補をまとめて生成する係** として使います。

推奨フロー：

```text
興味カテゴリを登録
↓
AI で候補を 20〜50 件まとめて生成
↓
Firestore に保存
↓
通知時は保存済み候補からランダム表示
```

通知時は AI を呼ばず、Firestore に保存済みの候補から選びます。

---

## Phase 分割

AI バックエンド導入は、一度に全部やらず段階的に進めます。

## Phase A: ユーザー識別

目的：ユーザーごとに興味・提案・履歴を分ける。

使う技術：

- Firebase Authentication
- 匿名認証

最初はメールアドレスや Google ログインを使わず、匿名認証で十分です。

```text
ユーザーA
├─ 興味: 音楽, YouTube
├─ AI生成候補
└─ 履歴

ユーザーB
├─ 興味: 読書, 散歩
├─ AI生成候補
└─ 履歴
```

---

## Phase B: クラウド保存

目的：端末内保存から、ユーザーごとのクラウド保存へ移行する。

使う技術：

- Cloud Firestore
- Firebase Security Rules

Firestore には、以下のような形で保存します。

```text
users/{userId}
├─ settings
│  ├─ interests: ["音楽", "YouTube", "読書"]
│  └─ notificationTime: "18:00"
│
├─ generatedSuggestions/{suggestionId}
│  ├─ title
│  ├─ description
│  ├─ category
│  ├─ durationMinutes
│  ├─ interestTags
│  ├─ generatedBy: "ai"
│  └─ createdAt
│
└─ records/{recordId}
   ├─ suggestionId
   ├─ status: "done" | "skipped"
   ├─ selectedMinutes
   └─ createdAt
```

---

## Phase C: AI 生成 API

目的：ユーザーの興味カテゴリをもとに提案候補を生成する。

使う技術：

- Cloud Functions for Firebase
- OpenAI API
- Secret Manager または Functions の環境変数

処理の流れ：

```text
Flutter アプリが generateSuggestions を呼ぶ
↓
Cloud Functions が認証ユーザーを確認する
↓
興味カテゴリを受け取る
↓
OpenAI API に候補生成を依頼する
↓
JSON 形式で結果を受け取る
↓
形式と内容を検証する
↓
Firestore に保存する
↓
Flutter アプリに結果を返す
```

---

## Phase D: 生成結果の検証

AI の出力をそのまま保存しないようにします。

検証する内容：

- `title` が空ではないか
- `description` が空ではないか
- `estimated_minutes` が妥当な正の値か（目安所要時間）
- 危険な行動を含んでいないか
- 高額な費用を前提にしていないか
- ユーザーに過度な個人情報入力を求めていないか
- 重複候補が多すぎないか

AI は便利ですが、出力の品質を必ずアプリ側で確認します。

---

## Phase E: 利用状況に応じた改善

履歴を使って、次回生成の条件を改善します。

例：

```text
散歩系をよくスキップしている
↓
屋内でできる提案を多めにする
```

```text
音楽系をよく実施している
↓
音楽系の新しいジャンル提案を増やす
```

ただし、これは発展機能です。最初の AI 導入では必須にしません。

---

## Flutter 側で使うパッケージ候補

AI バックエンド導入時の Flutter 側候補です。

```yaml
dependencies:
  firebase_core:
  firebase_auth:
  cloud_firestore:
  cloud_functions:
```

通知機能は MVP から継続して使います。

```yaml
  flutter_local_notifications:
```

状態管理が複雑になってきたら検討します。

```yaml
  flutter_riverpod:
```

最初から全部入れる必要はありません。

---

## Cloud Functions 側の構成例

Cloud Functions は TypeScript で書く想定です。

```text
functions/
├─ src/
│  ├─ index.ts
│  ├─ generateSuggestions.ts
│  ├─ validateSuggestions.ts
│  └─ rateLimit.ts
├─ package.json
└─ tsconfig.json
```

主な関数：

| 関数 | 役割 |
|---|---|
| `generateSuggestions` | 興味カテゴリから AI 提案候補を生成する |
| `validateSuggestions` | AI 出力を保存前に検証する |
| `rateLimit` | 1ユーザーあたりの生成回数を制限する |

---

## OpenAI に渡す情報

OpenAI API には、必要な情報だけを渡します。

渡す情報：

- ユーザーの興味カテゴリ
- 希望する提案数
- 15分 / 30分 / 60分でできること
- 大学生が空き時間に試しやすいこと
- 1人で実行しやすいこと
- 高額な費用を必要としないこと

渡さない情報：

- 氏名
- メールアドレス
- 正確な位置情報
- カレンダー予定の詳細
- 個人を特定できる情報

---

## AI 出力の形式

AI には、アプリで扱いやすい JSON 形式で返させます。

例：

```json
{
  "suggestions": [
    {
      "title": "普段聴かないジャンルを1曲だけ聴く",
      "description": "好きな音楽に近いジャンルから1曲だけ聴いてみる。",
      "category": "音楽",
      "duration_minutes": 15,
      "interest_tags": ["音楽", "発見"]
    }
  ]
}
```

自由文だけで返させると、アプリ側で扱いにくくなります。

---

## セキュリティ方針

### API キー管理

OpenAI API キーは Flutter アプリに入れません。

Cloud Functions 側の Secret Manager または環境変数で管理します。

### 生成回数制限

AI 生成はコストが発生するため、制限を入れます。

例：

```text
1ユーザー1日3回まで
1回の生成は最大20件まで
同じ興味カテゴリでは短時間に再生成しない
```

### Firestore Security Rules

ユーザーAがユーザーBの提案候補や履歴を読めないようにします。

```text
users/{userId}/...
```

を使い、ログイン中のユーザーIDと一致する場合だけ読み書き可能にします。

### App Check

アプリ以外から Functions や Firestore を叩かれにくくするため、Firebase App Check も検討します。

---

## MVP には入れない理由

AI バックエンドを入れると、以下が増えます。

- Firebase 設定
- 認証
- Firestore 設計
- Security Rules
- Cloud Functions
- OpenAI API キー管理
- 課金管理
- レート制限
- 通信エラー処理
- 生成結果の品質確認

そのため、授業内 MVP では入れません。

MVP では以下で完成させます。

```text
Flutter
カテゴリ別提案JSON
端末内保存
ローカル通知
ランダム提案
```

AI バックエンドは、MVP が動いた後の発展機能として扱います。

---

## まとめ

AI 提案を入れる場合の推奨構成は以下です。

```text
Flutter
↓
Firebase Authentication
↓
Cloud Functions for Firebase
↓
OpenAI API
↓
Cloud Firestore
```

ただし、通知時に毎回 AI を呼ぶのではなく、AI で提案候補をまとめて生成し、Firestore に保存します。

通知時は保存済み候補からランダムに選ぶことで、速度・コスト・安定性を保ちます。

---

## 参考ドキュメント

- OpenAI API Production best practices: https://developers.openai.com/api/docs/guides/production-best-practices
- Firebase Authentication: https://firebase.google.com/docs/auth
- Cloud Functions for Firebase: https://firebase.google.com/docs/functions
- Cloud Firestore: https://firebase.google.com/docs/firestore
- Firebase App Check: https://firebase.google.com/docs/app-check
