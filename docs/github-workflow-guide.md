# GitHub 開発フロー：Issue・Branch・Pull Request の理由

このドキュメントは、`yorimitiBiyori` の開発で **Issue、Branch、Pull Request** をなぜ使うのかを説明するためのものです。

Git や GitHub の操作は、最初は手順だけを覚えがちです。  
しかし、なぜその手順を踏むのかを理解しておくと、チーム開発で迷いにくくなります。

---

## 結論

Issue、Branch、Pull Request の役割は次の通りです。

| 仕組み | 何のために使うか | 一言で言うと |
|---|---|---|
| Issue | 作業内容や問題を整理する | やることメモ |
| Branch | `main` を壊さずに作業する | 安全な作業場所 |
| Pull Request | 作業内容を確認してから取り込む | 変更の確認場所 |

基本の流れは以下です。

```text
Issue を作る
↓
Branch を作る
↓
作業する
↓
Commit する
↓
Push する
↓
Pull Request を作る
↓
確認する
↓
Merge する
```

---

## まず main ブランチを直接触らない理由

`main` ブランチは、プロジェクトの中心となるブランチです。

このリポジトリでは、`main` は「動く状態を保つ場所」と考えます。

もし全員が `main` に直接作業すると、次の問題が起きやすくなります。

- 作りかけのコードが `main` に入る
- ビルドできない状態になる
- 誰の変更で壊れたのか分かりにくい
- 複数人の変更が混ざって確認しづらい
- Vercel などの自動デプロイと連携したときに、壊れた状態が公開される可能性がある

そのため、普段の作業では `main` から作業用ブランチを作り、そこで変更します。

---

## Issue を作る理由

Issue は、これからやる作業や、直したい問題を記録する場所です。

例えば、次のような内容を Issue にします。

- ホーム画面を作る
- 提案画面を作る
- 履歴保存処理を実装する
- 実施率の計算を修正する
- README の説明を追加する
- Flutter の画面表示が崩れる問題を直す

---

## Issue を作らない世界線

Issue を作らずに開発すると、作業内容が会話や記憶に残るだけになります。

その結果、次のような問題が起きます。

### 何をする予定だったか忘れる

口頭やチャットで「あとで履歴画面を直そう」と話しても、数日後には忘れる可能性があります。

Issue にしておけば、未対応の作業として残ります。

### 作業の優先順位が分からない

Issue がないと、何から手を付けるべきか分かりにくくなります。

MVP では、まず中心機能を完成させる必要があります。  
Issue にしておけば、「今やるべきこと」と「後回しでよいこと」を分けられます。

### 誰が何をしているか分からない

チーム開発では、同じ作業を複数人が重複して進めてしまうことがあります。

Issue に担当者や進行状況を書いておけば、作業の重複を避けやすくなります。

### Pull Request の目的が分かりにくくなる

Pull Request だけを見ると、「なぜこの変更をしたのか」が分かりにくい場合があります。

Issue があれば、Pull Request から Issue を参照して、変更の背景を確認できます。

---

## Issue に書くとよい内容

Issue には、最低限次の内容を書きます。

```md
## やること

- 何を実装・修正するか

## 理由

- なぜ必要か

## 完了条件

- 何ができれば完了か
```

例:

```md
## やること

履歴画面で、実施済み・スキップ済みの記録を一覧表示する。

## 理由

ユーザーが過去にどの行動を実施したか確認できるようにするため。

## 完了条件

- 実施済みの記録が表示される
- スキップした記録が表示される
- 記録が0件の場合の表示がある
```

Issue は完璧な文章である必要はありません。  
作業の目的と完了条件が分かれば十分です。

---

## Branch を作る理由

Branch は、`main` とは別に作業するための場所です。

`main` を直接変更せず、作業ごとにブランチを分けます。

例えば、履歴画面を作るなら次のようなブランチを作ります。

```text
feature/history-page
```

ビルドエラーを直すなら、次のような名前にします。

```text
fix/build-error
```

---

## Branch を作らない世界線

ブランチを作らず、全員が `main` に直接作業するとします。

最初は簡単に見えます。

```text
main に直接変更する
↓
commit する
↓
push する
```

しかし、チーム開発ではすぐに問題が出ます。

### 作りかけのコードが main に入る

例えば、提案画面を作っている途中でまだビルドエラーがある状態でも、`main` に push できてしまいます。

すると、他のメンバーが pull したときに、動かないコードを受け取ることになります。

### 複数人の作業が混ざる

A さんが履歴画面を作り、B さんが設定画面を作っているとします。

両方が `main` で直接作業すると、変更が同じ場所でぶつかりやすくなります。

### 戻す範囲が分かりにくい

何か壊れたときに、どの変更を戻せばよいか分かりにくくなります。

ブランチごとに作業していれば、「この Pull Request の変更を確認する」と範囲を絞れます。

---

## Branch 名の付け方

ブランチ名は、何の作業か分かる名前にします。

おすすめの形式:

```text
種類/作業内容
```

例:

```text
feature/home-page
feature/history-page
feature/activity-filter
fix/build-error
fix/history-storage
update/readme-docs
```

よく使う prefix:

| prefix | 用途 | 例 |
|---|---|---|
| `feature/` | 新機能追加 | `feature/history-page` |
| `fix/` | バグ修正 | `fix/build-error` |
| `update/` | 既存内容の更新 | `update/readme-docs` |
| `docs/` | ドキュメント変更 | `docs/github-workflow-guide` |

避けたい名前:

```text
test
work
update
hiroaki
branch1
```

名前だけで作業内容が分からないためです。

---

## Commit を作る理由

Commit は、作業の保存ポイントです。

ファイルを保存するだけでは、Git の履歴には残りません。  
commit して初めて、「この時点の変更」として記録されます。

commit を分ける理由は、あとで履歴を追いやすくするためです。

例えば、次のように分けます。

```text
Add history page layout
Add record storage helpers
Fix completion rate calculation
```

逆に、すべてを1つの commit にすると、何を変更したのか分かりにくくなります。

```text
いろいろ修正
```

commit は「あとから読める作業記録」と考えるとよいです。

---

## Pull Request を作る理由

Pull Request は、作業ブランチの変更を `main` に取り込む前に確認する場所です。

Pull Request では、次のことを確認します。

- 何を変更したか
- なぜ変更したか
- どのファイルを変更したか
- 差分に不要な変更が混ざっていないか
- ビルドや動作確認ができているか
- README や docs と矛盾していないか

Pull Request は、単に merge するためのボタンではありません。  
変更内容を説明し、確認し、記録する場所です。

---

## Pull Request を作らない世界線

Pull Request を作らずに `main` に直接 push すると、変更内容を確認する場所がありません。

その結果、次のような問題が起きます。

### レビューできない

他のメンバーが変更内容を見る前に、`main` に反映されます。

もし間違いがあっても、気づくのが遅れます。

### 変更理由が残りにくい

commit だけでは、作業の背景や確認内容まで書きにくいです。

Pull Request には、Issue へのリンク、変更理由、確認したことを書けます。

### 関係ない変更が混ざりやすい

Pull Request の差分を見ることで、「このファイルは関係ないのでは？」と気づけます。

直接 push では、その確認のタイミングが弱くなります。

### main が壊れやすい

Pull Request で確認せずに merge すると、ビルドエラーや仕様違いが `main` に入りやすくなります。

`main` はできるだけ安定した状態に保つべきです。

---

## Pull Request に書くとよい内容

Pull Request には、最低限次の内容を書きます。

```md
## 概要

- 何を変更したか

## 関連 Issue

- Close #番号

## 確認したこと

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] 画面表示を確認
- [ ] 関係ない変更が混ざっていないことを確認

## 補足

- 気になる点や未対応のこと
```

例:

```md
## 概要

履歴画面を追加し、実施済み・スキップ済みの行動を一覧表示できるようにしました。

## 関連 Issue

Close #12

## 確認したこと

- [x] `flutter analyze`
- [x] `flutter test`
- [x] 履歴が0件の場合の表示
- [x] 実施済み記録の表示
- [x] スキップ記録の表示

## 補足

端末内保存の形式は今後変更する可能性があります。
```

`Close #12` のように書くと、Pull Request が merge されたときに該当 Issue を自動で閉じられます。

---

## Issue・Branch・Pull Request の関係

3つは別々のものですが、つながっています。

```text
Issue
何をやるかを決める

↓

Branch
安全に作業する

↓

Pull Request
作業内容を確認して main に入れる
```

具体例:

```text
Issue #12
履歴画面を作る

↓

Branch
feature/history-page

↓

Pull Request
Add history page
Close #12
```

この流れにすると、「何のための作業だったのか」「どの変更で対応したのか」が後から追いやすくなります。

---

## yorimitiBiyori でのおすすめ作業フロー

このプロジェクトでは、次の流れを基本にします。

```text
1. Issue を作る
2. main を最新にする
3. Issue に対応する branch を作る
4. 作業する
5. 差分を確認する
6. commit する
7. push する
8. Pull Request を作る
9. 内容を確認する
10. 問題なければ merge する
```

VS Code を使う場合は、次の操作に対応します。

| 手順 | VS Code / GitHub での操作 |
|---|---|
| main を最新にする | VS Code で Pull / Sync Changes |
| branch を作る | 左下のブランチ名 → Create new branch |
| 差分を見る | Source Control で変更ファイルをクリック |
| stage する | ファイル横の `+` |
| commit する | message を書いて Commit |
| push する | Push / Sync Changes |
| Pull Request を作る | GitHub 上で Compare & pull request |

---

## 小さい作業でも Issue と Pull Request は必要か

小さい作業では、毎回厳密に Issue を作るのが重く感じることがあります。

目安は次の通りです。

| 作業内容 | Issue | Branch | Pull Request |
|---|---|---|---|
| README の誤字修正 | なくてもよい | あると安全 | あると安全 |
| 小さな docs 追加 | あるとよい | あるとよい | あるとよい |
| 画面追加 | 作る | 作る | 作る |
| ロジック変更 | 作る | 作る | 作る |
| 端末内保存形式の変更 | 作る | 作る | 作る |
| API や認証の追加 | 作る | 作る | 作る |

授業や少人数開発では、すべてを厳密に運用しすぎる必要はありません。  
ただし、アプリの動作に影響する変更では、Issue、Branch、Pull Request を使うほうが安全です。

---

## よくある失敗

### Issue が大きすぎる

悪い例:

```text
アプリを完成させる
```

これでは範囲が大きすぎます。

良い例:

```text
ホーム画面の入力フォームを作る
提案条件に合う行動を抽出する
履歴を端末内に保存する
```

Issue は、1つの Pull Request で対応できる大きさに分けると扱いやすいです。

### Branch 名が曖昧

悪い例:

```text
work
fix
new
```

良い例:

```text
feature/suggest-page
fix/local-storage-parse
```

### Pull Request が大きすぎる

1つの Pull Request に多くの変更を入れすぎると、確認が難しくなります。

避けたい例:

```text
ホーム画面、提案画面、履歴画面、設定画面、README 更新を全部1つの PR に入れる
```

できるだけ、1つの Pull Request は1つの目的に絞ります。

### Pull Request の説明が空

説明がない Pull Request は、あとから見たときに何のための変更か分かりません。

最低限、「何を変えたか」「確認したこと」は書きます。

---

## まとめ

Issue、Branch、Pull Request は、面倒な手順ではなく、チーム開発で安全に進めるための仕組みです。

```text
Issue = やることを整理する
Branch = main を壊さずに作業する
Pull Request = 変更を確認してから取り込む
```

`yorimitiBiyori` では、MVP を確実に完成させるために、作業の目的と変更範囲を小さく保つことが重要です。

そのため、画面追加やロジック変更など、アプリの動作に関わる作業では、次の流れを基本にします。

```text
Issue → Branch → Commit → Push → Pull Request → Merge
```
