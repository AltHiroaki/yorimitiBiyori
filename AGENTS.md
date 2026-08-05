# AGENTS.md

このリポジトリで AI agent（Codex など）が作業するときは、必ず以下の 2 ファイルの規則に従ってください。

1. [docs/rules/AGENTS.md](./docs/rules/AGENTS.md) — よりみち日和専用のプロジェクトルール（MVP 範囲、画面構成、データ設計、禁止事項）
2. [docs/rules/SKILL.md](./docs/rules/SKILL.md) — 汎用コーディング規則（可読性、命名、型安全、エラー処理）

## 仕様の正本

仕様の正本は以下の 2 つです。リポジトリ内のドキュメントと食い違う場合は、こちらを優先します。

- 企画書（`docs/spec/企画書.md` および提出版 PDF）— コンセプト、データ設計、発展方針
- UI プロトタイプ — 画面構成、UI 文言、操作フロー（Figma から書き出した React プロトタイプ。**参照専用**であり、Flutter 実装に React コードを持ち込まないこと）。main には置かず、[`archive-reference-materials`](https://github.com/AltHiroaki/yorimitiBiyori/tree/archive-reference-materials) ブランチの `よりみち日和 UIプロトタイプ/` に退避してある

実装者向けの要約は [docs/spec/仕様要約.md](./docs/spec/仕様要約.md) を参照してください。

## 基本コマンド

```bash
flutter pub get      # 依存取得
flutter run          # 起動（Android Emulator / 実機）
flutter analyze      # 静的解析
flutter test         # テスト
```

コード変更後は `flutter analyze` と `flutter test` を必ず実行してください。

## Review guidelines

- すべてのレビューコメントは日本語で書いてください。
- 指摘は「問題点」「理由」「修正案」の順で、簡潔かつ理路整然と書いてください。
- 重大度が高い順に指摘してください。
- バグ、セキュリティ、保守性、テスト不足、仕様との不整合を優先して確認してください。
- 些細な好みや必須でない改善案は、必要に応じて「任意」と明記してください。
- 不確かな場合は断定せず、「可能性があります」「確認してください」のように表現してください。
- 初学者にも読めるように、専門用語を使う場合は短く補足してください。
