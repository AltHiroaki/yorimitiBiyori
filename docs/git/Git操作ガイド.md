# Git 操作ガイド（コマンド & VS Code）

このドキュメントは、`yorimitiBiyori` の開発で Git を使うときの操作をまとめたものです。

Git はターミナルのコマンドで操作できますが、VS Code の Source Control 機能を使うと、変更内容の確認、stage、commit、push、pull、ブランチ切り替えなどを画面上で行えます。どちらで操作しても裏側は同じ Git なので、このガイドではコマンドと VS Code 操作を対応させて説明します。

なぜこの手順（ブランチを切る・PR を経由する等）を守るのかは [Gitの動作理由メモ](./Gitの動作理由メモ.md) を、Issue・Branch・PR を使う理由そのものは [GitHub 開発フロー](./GitHub開発フロー.md) を参照してください。

---

## 1. 前提

PC に Git がインストールされている必要があります。

```bash
git --version
```

初回だけ、ユーザー名とメールアドレスを設定します。

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
git config --global init.defaultBranch main
```

設定確認:

```bash
git config --global --list
```

VS Code は Git を内蔵しているわけではなく、PC に入っている Git を使って操作します。

---

## 2. コマンドと VS Code 操作の対応表

| やりたいこと | Git コマンド | VS Code での操作 |
|---|---|---|
| 変更状況を見る | `git status` | Source Control を見る |
| 変更内容を見る | `git diff` | 変更ファイルをクリックする |
| stage する | `git add ファイル名` | ファイル横の `+` を押す |
| すべて stage する | `git add .` | `Changes` 見出し横の `+` を押す |
| stage を取り消す | `git restore --staged ファイル名` | `Staged Changes` のファイル横の `-` を押す |
| commit する | `git commit -m "message"` | メッセージを書いて `Commit` を押す |
| GitHub に送る | `git push` | `Push` または `Sync Changes` を押す |
| GitHub から取る | `git pull` | `Pull` または `Sync Changes` を押す |
| ブランチを確認する | `git branch` | 左下のブランチ名を見る |
| ブランチを切り替える | `git switch ブランチ名` | 左下のブランチ名から切り替える |
| 新しいブランチを作る | `git switch -c ブランチ名` | 左下のブランチ名 → `Create new branch` |
| 変更を破棄する | `git restore ファイル名` | `Discard Changes` を選ぶ |

Source Control はショートカット `Ctrl + Shift + G`（macOS は `Control + Shift + G`）でも開けます。

---

## 3. 日常の基本フロー

1. 最新を取得する

```bash
git switch main
git fetch origin
git pull origin main
```

VS Code では `Pull` または `Sync Changes` を押します。

補足：

- `git fetch origin` は「取得だけ」を行う
- `git pull origin main` は「取得 + 取り込み」を行う
- 先に fetch しておくと、取り込み前に差分確認しやすい

2. 作業ブランチを切る

```bash
git switch -c issue-12-history-screen
```

VS Code では左下のブランチ名をクリックし、`Create new branch` を選びます。ブランチ名の形式は [GitHub 開発フロー](./GitHub開発フロー.md#branch-名の付け方) の規則（`issue-<Issue番号>-<短い内容>`）に従ってください。

3. 変更を確認する

```bash
git status
git diff
```

VS Code では Source Control を開くと変更ファイルが一覧表示され、ファイルをクリックすると差分が見られます。commit する前に必ず差分を見て、次の点を確認します。

- 意図したファイルだけを変更しているか
- 不要な変更が混ざっていないか
- 消してはいけない行を消していないか
- デバッグ用の `console.log` などが残っていないか

4. 変更をステージしてコミットする

```bash
git add .
git commit -m "ログインUIを追加"
```

VS Code では、ファイル横の `+` で stage し（`Changes` 見出し横の `+` で全件 stage）、上部の入力欄にメッセージを書いて `Commit` を押します。

良いコミットメッセージの例：

```text
Add history page layout
Add record storage helpers
Fix completion rate calculation
```

避けたい例：

```text
修正
更新
いろいろ変更
test
```

5. リモートへ push する

```bash
git push -u origin issue-12-history-screen
```

VS Code では `Sync Changes` または `Push` を押します。commit しただけでは GitHub に反映されないので注意してください。

6. GitHub で Pull Request を作成する

- ベース: `main`
- 比較: 作業ブランチ
- 変更内容と確認ポイントを簡潔に記載する（書く内容は [GitHub 開発フロー](./GitHub開発フロー.md#pull-request-に書くとよい内容) を参照）

---

## 4. よく使うコマンド（CLI 限定）

履歴を見やすく表示:

```bash
git log --oneline --graph --decorate --all
```

リモートの更新だけ先に取得して確認:

```bash
git fetch origin
git log --oneline --graph --decorate --all main..origin/main
```

ブランチ一覧:

```bash
git branch
git branch -r
git branch -a
```

追跡していないファイルを含めて状態確認:

```bash
git status -sb
```

---

## 5. Sync Changes とは

VS Code の `Sync Changes` は、基本的に pull と push をまとめて行う操作です。

```bash
git pull
git push
```

ただし状況によっては競合が発生することがあります。競合が起きた場合は、VS Code がどのファイルで競合しているかを表示するので、内容を確認してどちらの変更を残すか決めます。

---

## 6. コンフリクト対応

1. `git pull origin main` で競合が出たら対象ファイルを開く（VS Code は競合箇所を表示してくれる）
2. `<<<<<<<`, `=======`, `>>>>>>>` を解消する
3. 解消したファイルをステージする
4. コミットして push する

```bash
git add <conflicted-file>
git commit -m "コンフリクト解消"
git push
```

---

## 7. 取り消し系コマンド（注意して使う）

直前コミットだけ取り消し（変更は残す）:

```bash
git reset --soft HEAD~1
```

ステージだけ外す:

```bash
git restore --staged <file>
```

VS Code では `Staged Changes` のファイル横の `-` ボタンに対応します。

作業ツリーの変更を戻す:

```bash
git restore <file>
```

VS Code では変更ファイルを右クリックして `Discard Changes` を選びます。**この操作は元に戻せない前提で考えてください**。実行前に必ず差分を確認します。

迷ったときの判断基準：

- 変更を次のコミットに入れたい → `git add`
- コミット対象から外したい → `git restore --staged`
- 作業自体を破棄したい → `git restore`
- 直前コミットだけ取り消したい（変更は残す） → `git reset --soft HEAD~1`

---

## 8. このプロジェクトでのおすすめ運用

- `main` に直接コミットしない
- 1 タスク 1 ブランチで作業する
- ブランチ名・Issue の運用ルールは [GitHub 開発フロー](./GitHub開発フロー.md) に従う
- コミットメッセージは「何をしたか」を短く明確に書く
- Pull Request の説明に「目的」「変更点」「確認方法」を書く

例：1 機能追加の一連コマンド

```bash
git switch main
git fetch origin
git pull origin main
git switch -c issue-12-calendar-sync
# 実装
# 動作確認
git add .
git commit -m "カレンダー同期処理を追加"
git push -u origin issue-12-calendar-sync
```

---

## 9. よくあるミス

### commit したのに GitHub に反映されない

commit だけでは GitHub に反映されません。push または Sync Changes を実行してください。

### 関係ないファイルまで commit してしまう

commit 前に Source Control で差分を確認してください。必要なファイルだけ stage すれば、関係ない変更を commit に含めずに済みます。

### 変更を破棄して作業内容が消えた

`Discard Changes` / `git restore` は未 commit の変更を消します。使う前に必ず差分を確認してください。

### Pull したら競合した

同じファイルの同じ場所を複数人が変更すると競合が起きます。VS Code は競合箇所を表示してくれるので、内容を確認して残す変更を選びます。

---

## 10. 参考リンク

VS Code の公式ドキュメント:

```text
https://code.visualstudio.com/docs/sourcecontrol/overview
https://code.visualstudio.com/docs/sourcecontrol/quickstart
```
