# docs ディレクトリ

main に置くのは、よりみち日和の実装・ビルドに必要なドキュメントだけです。

```text
docs/
├─ README.md
├─ rules/
│  ├─ AGENTS.md    ← よりみち日和専用のプロジェクトルール
│  └─ SKILL.md     ← 汎用コーディング規則
├─ spec/
│  ├─ 企画書.md     ← 仕様の正本（コンセプト、データ設計、発展方針）
│  ├─ 仕様書.md     ← 実装の正本（画面・データ・ロジック・テスト）
│  └─ 仕様要約.md   ← 仕様のクイックリファレンス
└─ setup/
   └─ 環境構築手順.md
```

## 用途

| フォルダ | 内容 |
|---|---|
| `rules/` | AI agent と開発者が従う規則。CLAUDE.md からここへ誘導する |
| `spec/` | 何を作るかの定義。実装時はまず `仕様書.md` を見る |
| `setup/` | 開発環境を用意して起動するまでの手順 |

## main に置いていない資料

製品のビルドに使わない資料は [`archive-reference-materials`](https://github.com/AltHiroaki/yorimitiBiyori/tree/archive-reference-materials) ブランチへ退避しています。

| 退避先 | 内容 |
|---|---|
| `docs/planning/` | 実装計画、工程計画、各機能の検討記録 |
| `docs/tech/` | Flutter 技術解説、AI・バックエンド構成、iOS 導入方針、デザイン参考、製品概要と課題 |
| `docs/git/` | Git / GitHub の操作ガイド |
| `docs/rules/` の解説 2 件 | コーディング規則の考え方、ファイル分けを行う理由 |
| `docs/spec/要件定義.md` | 要件定義（仕様書に統合済み） |
| `docs/setup/GitHubEducation申請手順.md` | GitHub Education の申請手順 |
| `よりみち日和 UIプロトタイプ/` | Figma 書き出しの React プロトタイプ（参照専用） |
| `archive/old-web-version/` | 旧 Web 版 |

参照するときは以下で取り出せます。

```bash
git switch archive-reference-materials
```
