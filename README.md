# よりみち日和

> 空いた時間に、ちょっと新しい体験を。

よりみち日和は、空き時間・強度・場所・予算をもとに、今すぐできる小さな行動を提案する Web アプリケーションです。  
予定と予定の間に生まれる隙間時間を、SNS や動画視聴だけで終わらせず、日常に小さな変化を生むきっかけに変えることを目的としています。

---

## 企画の位置づけ

本アプリは、予定管理アプリと行動提案アプリの中間領域を対象とします。

一般的な予定管理アプリは、ユーザーが事前に予定やタスクを登録することを前提にしています。  
一方、よりみち日和は、ユーザーが細かく計画しなくても、今ある空き時間に合う行動をアプリ側が提示することを目指します。

想定する主な利用者は、授業・アルバイト・サークル活動の合間に 15〜60 分程度の空き時間が生じる大学生です。

---

## 初期実装版 MVP

授業内で確実に完成させるため、初期実装版では機能を絞ります。

### 初期実装で入れるもの

- 空き時間の手動入力
- 強度の選択
- 場所の選択
- 予算の選択
- 条件に合う行動提案
- 別の提案の再表示
- 実施記録
- スキップ記録
- 履歴表示
- 実施率の表示

### 初期実装で入れないもの

- Google ログイン
- Google Calendar API
- Firebase Authentication
- Firestore
- Google Maps API / Places API
- 位置情報取得

これらは発展機能として、MVP が完成した後に段階的に追加します。

---

## 技術構成

| 分類 | 使用技術 | 用途 |
|---|---|---|
| フロントエンド | React | UI をコンポーネント単位で構築する |
| 言語 | TypeScript | データ構造のミスを減らす |
| 開発環境 | Vite | 開発サーバーとビルドを担当する |
| スタイリング | Tailwind CSS | UI を効率よく整える |
| 画面遷移 | React Router | ホーム・提案・履歴・設定画面を切り替える |
| 行動データ | activities.json | 行動候補を管理する |
| 履歴保存 | localStorage | ログインなしで履歴を保存する |
| 公開 | Vercel | GitHub と連携して Web アプリを公開する |

---

## 画面構成

| 画面 | 役割 |
|---|---|
| ホーム画面 | 空き時間・強度・場所・予算を選択する |
| 提案画面 | 条件に合う行動を表示し、実施・再提案・スキップを選ぶ |
| 履歴画面 | 実施済み・スキップした行動を一覧表示する |
| 設定画面 | 履歴削除、アプリ説明、バージョン情報を表示する |

---

## ディレクトリ構成

```text
yorimitiBiyori/
├─ README.md
├─ docs/
│  ├─ environment-setup.md
│  ├─ implementation-plan.md
│  └─ specification-summary.md
├─ public/
├─ src/
│  ├─ app/
│  │  └─ router.tsx
│  ├─ assets/
│  ├─ components/
│  │  ├─ layout/
│  │  └─ ui/
│  ├─ data/
│  │  └─ activities.json
│  ├─ features/
│  │  ├─ activities/
│  │  ├─ recommendation/
│  │  └─ records/
│  ├─ pages/
│  │  ├─ HomePage.tsx
│  │  ├─ SuggestPage.tsx
│  │  ├─ HistoryPage.tsx
│  │  └─ SettingsPage.tsx
│  ├─ types/
│  ├─ utils/
│  ├─ App.tsx
│  ├─ main.tsx
│  └─ index.css
├─ index.html
├─ package.json
├─ tsconfig.json
├─ vite.config.ts
└─ vercel.json
```

---

## セットアップ

環境構築の詳しい手順は、以下を参照してください。

- [環境構築手順](./docs/environment-setup.md)

基本的な起動手順は以下です。

```bash
npm install
npm run dev
```

ビルド確認は以下です。

```bash
npm run build
```

---

## 実装順序

1. React + TypeScript + Vite の基本構成を作る
2. Tailwind CSS を導入する
3. React Router で画面を分ける
4. `activities.json` を作る
5. 行動データの型を定義する
6. 条件に合う行動を抽出する
7. ランダム提案を実装する
8. 実施・スキップ履歴を `localStorage` に保存する
9. 履歴画面を作る
10. Vercel で公開する

詳細は以下を参照してください。

- [実装計画](./docs/implementation-plan.md)
- [仕様要約](./docs/specification-summary.md)

---

## 発展機能

MVP 完成後、余裕があれば以下を追加します。

- Google ログイン
- Google Calendar 連携
- 予定間の空き時間自動検出
- Firestore によるユーザー別履歴保存
- ユーザー設定保存
- 位置情報や周辺スポット提案

---

## メンバー

アプリデザイン総合演習 2026  
グループ L 班

- 信寛昭
- 久保孝輔
- 山本竜聖

---

## 開発メモ

このリポジトリでは、まず MVP を完成させることを優先します。  
Google Calendar 連携や Firebase は魅力的ですが、初期段階では実装難度が高いため、中心機能である「条件入力 → 行動提案 → 履歴保存」を先に安定させます。
