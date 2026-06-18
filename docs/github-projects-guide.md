# GitHub Projects 運用方針

## 目的

GitHub Projects はタスク管理ではなく、プロジェクト全体の進捗を把握するために利用する。

- Issue = 作業内容
- Pull Request = 実装結果
- Project = 現在の進捗状況

## 基本方針

Project には細かいタスクを載せすぎない。

推奨粒度：

- 提案機能
- 履歴機能
- 設定機能
- テスト
- 発表準備

## ステータス

以下の4列を利用する。

- Backlog
- Doing
- Review
- Done

## 管理項目

最低限、以下を管理する。

|項目|説明|
|---|---|
|Status|現在の状態|
|Assignee|担当者|
|Start Date|着手日|
|End Date|完了日|

## 開始日・終了日を記録する理由

開始日と終了日を残しておくことで、後から振り返りができる。

例：

- どの機能に時間がかかったか
- 見積もりが正しかったか
- どこで詰まったか

## 学生開発向けの考え方

本プロジェクトは小規模開発であるため、Story Point や Velocity などの高度な指標は管理しない。

まずは以下を徹底する。

1. Issue を作る
2. ブランチを切る
3. Pull Request を出す
4. レビューする
5. Project を更新する

## 参考

ZOZO TECH BLOG
GitHub Projects を用いた開発生産性の可視化
