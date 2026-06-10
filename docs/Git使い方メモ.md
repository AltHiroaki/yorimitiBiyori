# Git使い方メモ

## 1. 最初の設定（初回だけ）

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
git config --global init.defaultBranch main
```

設定確認:

```bash
git config --global --list
```

## 2. 日常の基本フロー

1. 最新を取得する

```bash
git switch main
git fetch origin
git pull origin main
```

補足:

- `git fetch origin` は「取得だけ」を行う
- `git pull origin main` は「取得 + 取り込み」を行う
- 先にfetchしておくと、取り込み前に差分確認しやすい

2. 作業ブランチを切る

```bash
git switch -c feature/add-login-ui
```

3. 変更を確認する

```bash
git status
git diff
```

4. 変更をステージしてコミットする

```bash
git add .
git commit -m "ログインUIを追加"
```

5. リモートへpushする

```bash
git push -u origin feature/add-login-ui
```

6. GitHubでPull Requestを作成する

- ベース: `main`
- 比較: 作業ブランチ
- 変更内容と確認ポイントを簡潔に記載する

## 3. よく使うコマンド

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

## 4. コンフリクト対応（最短手順）

1. `git pull origin main` で競合が出たら対象ファイルを開く
2. `<<<<<<<`, `=======`, `>>>>>>>` を解消する
3. 解消したファイルをステージする
4. コミットしてpushする

```bash
git add <conflicted-file>
git commit -m "コンフリクト解消"
git push
```

## 5. 取り消し系コマンド（注意して使う）

直前コミットだけ取り消し（変更は残す）:

```bash
git reset --soft HEAD~1
```

ステージだけ外す:

```bash
git restore --staged <file>
```

作業ツリーの変更を戻す:

```bash
git restore <file>
```

## 6. このプロジェクトでのおすすめ運用

- `main` に直接コミットしない
- 1タスク1ブランチで作業する
- コミットメッセージは「何をしたか」を短く明確に書く
- Pull Requestの説明に「目的」「変更点」「確認方法」を書く

## 7. 例: 1機能追加の一連コマンド

```bash
git switch main
git fetch origin
git pull origin main
git switch -c feature/add-calendar-sync
# 実装
# 動作確認
git add .
git commit -m "カレンダー同期処理を追加"
git push -u origin feature/add-calendar-sync
```

以上。
