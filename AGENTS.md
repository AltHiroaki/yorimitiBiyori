# AGENTS.md

このリポジトリで AI agent（Codex など）が作業するときは、必ず以下の 2 ファイルの規則に従ってください。

1. [docs/AGENTS.md](./docs/AGENTS.md) — よりみち日和専用のプロジェクトルール（MVP 範囲、画面構成、データ設計、禁止事項）
2. [docs/SKILL.md](./docs/SKILL.md) — 汎用コーディング規則（可読性、命名、型安全、エラー処理）

## 仕様の正本

仕様の正本は以下の 2 つです。リポジトリ内のドキュメントと食い違う場合は、こちらを優先します。

- 企画書（`docs/企画書.md` および提出版 PDF）— コンセプト、データ設計、発展方針
- `よりみち日和 UIプロトタイプ/` — 画面構成、UI 文言、操作フロー（Figma から書き出した React プロトタイプ。**参照専用**であり、Flutter 実装に React コードを持ち込まないこと）

実装者向けの要約は [docs/仕様要約.md](./docs/仕様要約.md) を参照してください。

## 基本コマンド

```bash
flutter pub get      # 依存取得
flutter run          # 起動（Android Emulator / 実機）
flutter analyze      # 静的解析
flutter test         # テスト
```

コード変更後は `flutter analyze` と `flutter test` を必ず実行してください。
