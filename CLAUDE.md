# CLAUDE.md

このリポジトリで AI agent（Claude Code など）が作業するときは、必ず以下の 2 ファイルの規則に従ってください。

1. [docs/rules/AGENTS.md](./docs/rules/AGENTS.md) — よりみち日和専用のプロジェクトルール（MVP 範囲、画面構成、データ設計、禁止事項）
2. [docs/rules/SKILL.md](./docs/rules/SKILL.md) — 汎用コーディング規則（可読性、命名、型安全、エラー処理）

## 仕様の正本

仕様の正本は以下の 2 つです。リポジトリ内のドキュメントと食い違う場合は、こちらを優先します。

- 企画書（`docs/spec/企画書.md` および提出版 PDF）— コンセプト、データ設計、発展方針
- UI プロトタイプ — 画面構成、UI 文言、操作フロー（Figma から書き出した React プロトタイプ。**参照専用**であり、Flutter 実装に React コードを持ち込まないこと）。main には置かず、[`archive-reference-materials`](https://github.com/AltHiroaki/yorimitiBiyori/tree/archive-reference-materials) ブランチの `よりみち日和 UIプロトタイプ/` に退避してある

実装に使うドキュメント：

- [docs/spec/仕様書.md](./docs/spec/仕様書.md) — 詳細仕様（画面・データ・ロジック・テスト）。実装時はまずここ
- [docs/spec/仕様要約.md](./docs/spec/仕様要約.md) — 仕様のクイックリファレンス
- [docs/planning/実装計画.md](./docs/planning/実装計画.md) — マイルストーンとタスク・完了条件
- [docs/planning/これからやること.md](./docs/planning/これからやること.md) — 直近の作業順

## 基本コマンド

```bash
flutter pub get      # 依存取得
flutter run          # 起動（Android Emulator / 実機）
flutter analyze      # 静的解析
flutter test         # テスト
```

コード変更後は `flutter analyze` と `flutter test` を必ず実行してください。
