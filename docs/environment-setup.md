# 環境構築手順：よりみち日和

作成日：2026-05-28  
対象：初めて Web アプリ開発をする人  
対象リポジトリ：`AltHiroaki/yorimitiBiyori`

---

## 1. このファイルの目的

このファイルは、**よりみち日和を自分の PC で動かせる状態にするまでの手順**をまとめたものです。

初心者がつまずきやすい点は、単に「何を入れるか」ではなく、**なぜそれを入れる必要があるのか**が分からないことです。  
そのため、この手順ではコマンドだけでなく、各ツールの役割も説明します。

---

## 2. よりみち日和の初期実装方針

よりみち日和は、初期実装版（MVP）では以下の方針で作ります。

- ログイン機能は入れない
- Google Calendar API は最初から入れない
- Firebase / Firestore は最初から入れない
- 行動データは `activities.json` で管理する
- 実施履歴はブラウザの `localStorage` に保存する
- 画面は React + TypeScript + Vite で作る
- デザインは Tailwind CSS を使う
- ページ切り替えは React Router を使う
- 公開は Vercel を使う

最初から Google ログインや Calendar 連携を入れると、認証・API 設定・権限管理などが増えて実装難度が上がります。  
そのため、まずは **「条件を選ぶ → 行動を提案する → 記録する」** という中心機能を完成させます。

---

## 3. 先に入れるもの一覧

| 入れるもの | 何のために使うか | なぜ必要か |
|---|---|---|
| VS Code | コードを書くエディタ | ファイルを見やすく編集でき、拡張機能も使えるため |
| Git | 変更履歴を管理する道具 | 誰がどこを変更したか分かり、失敗しても戻しやすいため |
| GitHub | コードを置く場所 | チームで共有でき、Vercel と連携して公開しやすいため |
| Node.js | JavaScript を PC 上で動かす実行環境 | React / Vite / Tailwind などの開発ツールを動かすため |
| npm | パッケージ管理ツール | React などの外部ライブラリをインストールするため |
| Vite | 開発サーバー・ビルドツール | React アプリを高速に起動・開発するため |
| React | 画面を部品単位で作るライブラリ | ボタン、カード、履歴一覧などをコンポーネントとして管理しやすいため |
| TypeScript | JavaScript に型を追加した言語 | データの形のミスを早い段階で見つけやすいため |
| Tailwind CSS | CSS を効率よく書く道具 | クラス名を組み合わせて、短時間で UI を整えやすいため |
| React Router | ページ切り替えを管理する道具 | ホーム、提案、履歴、設定などの画面を分けるため |
| Vercel | Web アプリを公開するサービス | GitHub と連携して簡単に公開・更新できるため |

---

## 4. 用語の簡単な説明

### ターミナル

PC に文字で命令を出す画面です。  
例：`npm run dev` と入力すると、開発用サーバーを起動できます。

Windows では主に **PowerShell**、macOS では **ターミナル** を使います。

### コマンド

ターミナルに入力する命令です。

例：

```bash
node -v
```

これは「Node.js のバージョンを表示してください」という命令です。

### パッケージ

開発で使う便利な部品のことです。  
React、Vite、Tailwind CSS、React Router などもパッケージとしてインストールします。

### `package.json`

このプロジェクトで使うパッケージや、実行できるコマンドを管理するファイルです。  
Web アプリ開発では非常に重要なファイルです。

---

## 5. インストール手順

## 5.1 VS Code を入れる

### 何をするか

VS Code をインストールします。

公式サイト：

```text
https://code.visualstudio.com/
```

### なぜ入れるのか

コードを書くためのエディタです。  
メモ帳でもコードは書けますが、VS Code には以下の利点があります。

- ファイル構成が見やすい
- TypeScript のエラーを表示してくれる
- コード補完が使える
- ターミナルを内蔵している
- Git の変更状況が見える

### 入れておくと便利な拡張機能

| 拡張機能 | 目的 |
|---|---|
| Japanese Language Pack for Visual Studio Code | VS Code を日本語化する |
| Prettier - Code formatter | コードの見た目を自動で整える |
| ESLint | JavaScript / TypeScript のミスを見つける |
| Tailwind CSS IntelliSense | Tailwind CSS のクラス名を補完する |

---

## 5.2 Git を入れる

### 何をするか

Git をインストールします。

公式サイト：

```text
https://git-scm.com/
```

### なぜ入れるのか

Git は、コードの変更履歴を管理するための道具です。

Git がない場合、失敗したときに「どこまで戻せばいいのか」が分かりにくくなります。  
Git を使うと、以下のことができます。

- 変更前の状態に戻せる
- 変更内容をチームメンバーと共有できる
- GitHub にコードをアップロードできる
- Vercel と連携して自動公開できる

### インストール後の確認

ターミナルで以下を実行します。

```bash
git --version
```

次のようにバージョンが表示されれば成功です。

```text
git version 2.xx.x
```

---

## 5.3 Node.js を入れる

### 何をするか

Node.js の **LTS 版** をインストールします。

公式サイト：

```text
https://nodejs.org/
```

### なぜ入れるのか

ブラウザの中では JavaScript が動きますが、React アプリを開発するには、PC 上でも JavaScript を動かす必要があります。  
そのために Node.js を入れます。

Node.js を入れると、同時に `npm` も使えるようになります。  
`npm` は、React や Tailwind CSS などのパッケージを入れるために使います。

### なぜ LTS 版を選ぶのか

LTS は Long Term Support の略で、長期間サポートされる安定版です。  
初心者や授業開発では、最新版よりも LTS 版を使う方がトラブルが少なくなります。

### インストール後の確認

ターミナルで以下を実行します。

```bash
node -v
npm -v
```

次のように表示されれば成功です。

```text
v24.x.x
11.x.x
```

表示される数字は環境によって違っても問題ありません。  
ただし、Vite は一定以上の Node.js バージョンを必要とするため、古い Node.js を使っている場合は更新してください。

---

## 6. GitHub からプロジェクトを取得する

## 6.1 作業用フォルダを作る

自分が分かりやすい場所に、作業用フォルダを作ります。

例：デスクトップに `app-dev` というフォルダを作る場合

```bash
cd Desktop
mkdir app-dev
cd app-dev
```

### なぜ作業用フォルダを作るのか

プロジェクトのファイルを分かりやすく整理するためです。  
ダウンロードフォルダやデスクトップに直接作ると、後でどれが開発用ファイルか分かりにくくなります。

---

## 6.2 リポジトリを clone する

以下を実行します。

```bash
git clone https://github.com/AltHiroaki/yorimitiBiyori.git
cd yorimitiBiyori
```

### なぜ clone するのか

`clone` は、GitHub 上にあるリポジトリを自分の PC にコピーする操作です。  
これで、自分の PC 上でコードを書いたり動かしたりできます。

---

## 7. React + TypeScript + Vite のプロジェクトを作る

このリポジトリにまだ `package.json` がない場合は、Vite で React + TypeScript の雛形を作ります。

```bash
npm create vite@latest . -- --template react-ts
```

途中で、現在のフォルダが空ではないという確認が出ることがあります。  
`README.md` など既存ファイルを残したい場合は、削除ではなく **Ignore files and continue** に相当する選択肢を選びます。

### なぜ Vite を使うのか

Vite は、React アプリを開発するための土台を短時間で作れる道具です。  
主な役割は以下です。

- 開発用サーバーを起動する
- ファイル変更をすぐブラウザに反映する
- TypeScript をブラウザで動く JavaScript に変換する
- 公開用のファイルを作成する

---

## 8. 必要なパッケージをインストールする

Vite の雛形を作成したら、以下を実行します。

```bash
npm install
```

### なぜ `npm install` が必要か

`package.json` に書かれている必要なパッケージを、実際に PC にダウンロードするためです。  
`npm install` を実行すると、`node_modules` というフォルダが作られます。

`node_modules` はパッケージ本体が入る場所です。  
容量が大きいため、GitHub には通常アップロードしません。

---

## 9. 開発サーバーを起動する

以下を実行します。

```bash
npm run dev
```

成功すると、次のような表示が出ます。

```text
Local: http://localhost:5173/
```

ブラウザでその URL を開くと、アプリ画面が表示されます。

### なぜ開発サーバーを起動するのか

React アプリは、HTML ファイルを直接ダブルクリックして開くのではなく、開発用サーバーを通して動かします。  
開発サーバーを使うと、コードを保存したときにブラウザがすぐ更新されます。

---

## 10. Tailwind CSS を入れる

## 10.1 インストール

```bash
npm install tailwindcss @tailwindcss/vite
```

### なぜ Tailwind CSS を入れるのか

Tailwind CSS は、画面デザインを効率よく作るための CSS フレームワークです。  
通常の CSS では、ボタンやカードごとにクラス名を考えて CSS を書く必要があります。

Tailwind CSS を使うと、例えば以下のようにクラスを直接指定できます。

```tsx
<button className="rounded-lg px-4 py-2 font-bold">
  提案してもらう
</button>
```

よりみち日和では、提案カード、履歴一覧、条件選択ボタンなど UI 部品が多いため、Tailwind CSS を使うとデザインを統一しやすくなります。

---

## 10.2 `vite.config.ts` を設定する

`vite.config.ts` を以下のようにします。

```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [react(), tailwindcss()],
});
```

### なぜ設定するのか

Vite に対して「Tailwind CSS を使います」と伝えるためです。  
インストールしただけでは、Vite は Tailwind CSS を自動では使えません。

---

## 10.3 CSS ファイルに Tailwind を読み込む

`src/index.css` に以下を追加します。

```css
@import "tailwindcss";
```

### なぜ読み込むのか

React の画面で Tailwind CSS のクラスを使えるようにするためです。  
この読み込みがないと、`className="text-xl"` などを書いても見た目に反映されません。

---

## 11. React Router を入れる

## 11.1 インストール

```bash
npm install react-router
```

### なぜ React Router を入れるのか

よりみち日和では、少なくとも以下の画面が必要になります。

- ホーム画面
- 提案画面
- 履歴画面
- 設定画面

React Router を使うと、URL に応じて表示する画面を切り替えられます。

例：

| URL | 表示する画面 |
|---|---|
| `/` | ホーム画面 |
| `/suggest` | 提案画面 |
| `/history` | 履歴画面 |
| `/settings` | 設定画面 |

---

## 11.2 `BrowserRouter` でアプリを囲む

`src/main.tsx` の例です。

```tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
);
```

### なぜ `BrowserRouter` で囲むのか

React Router が、現在の URL を見てどの画面を表示するか判断できるようにするためです。  
アプリ全体を `BrowserRouter` の内側に置くことで、どの画面でもルーティング機能を使えます。

---

## 12. よりみち日和用のフォルダ構成案

初期実装版では、以下のような構成にすると管理しやすいです。

```text
yorimitiBiyori/
├─ public/
├─ src/
│  ├─ assets/
│  ├─ components/
│  │  ├─ ActivityCard.tsx
│  │  ├─ ConditionForm.tsx
│  │  └─ Layout.tsx
│  ├─ data/
│  │  └─ activities.json
│  ├─ pages/
│  │  ├─ HomePage.tsx
│  │  ├─ SuggestPage.tsx
│  │  ├─ HistoryPage.tsx
│  │  └─ SettingsPage.tsx
│  ├─ types/
│  │  └─ activity.ts
│  ├─ utils/
│  │  ├─ recommendation.ts
│  │  └─ storage.ts
│  ├─ App.tsx
│  ├─ main.tsx
│  └─ index.css
├─ docs/
│  └─ environment-setup.md
├─ package.json
├─ vite.config.ts
└─ README.md
```

### 各フォルダの役割

| フォルダ | 役割 |
|---|---|
| `components` | ボタン、カード、フォームなど再利用する部品を置く |
| `data` | `activities.json` など、アプリが使う固定データを置く |
| `pages` | ホーム、提案、履歴、設定など画面単位のファイルを置く |
| `types` | TypeScript の型定義を置く |
| `utils` | 提案ロジックや localStorage 操作など、画面以外の処理を置く |
| `docs` | 環境構築や設計メモなど、説明用の資料を置く |

---

## 13. `activities.json` を使う理由

よりみち日和では、行動候補を最初はデータベースではなく `activities.json` で管理します。

### なぜ JSON にするのか

- サーバーを用意しなくてよい
- GitHub 上で直接編集しやすい
- 初心者でも中身を見て理解しやすい
- データ構造を TypeScript の型と対応させやすい
- 授業内で完成させる範囲として現実的

### 例

```json
[
  {
    "id": "walk_unknown_path",
    "title": "知らない道を1本歩いてみる",
    "description": "いつも通らない道を1本だけ選び、周囲を観察しながら歩く。",
    "category": "散歩",
    "min_minutes": 20,
    "max_minutes": 30,
    "intensity": "ゆるめ",
    "location_type": "どこでも",
    "budget_yen": 0,
    "indoor": false,
    "solo": true,
    "required_items": [],
    "weight": 1
  }
]
```

---

## 14. `localStorage` を使う理由

初期実装版では、実施履歴を `localStorage` に保存します。

### なぜ localStorage なのか

`localStorage` は、ブラウザの中にデータを保存する仕組みです。  
サーバーやログイン機能がなくても、履歴を保存できます。

### メリット

- Firebase などの外部サービスが不要
- ログインなしで使える
- 実装が簡単
- MVP の範囲に合っている

### 注意点

- 同じブラウザ内でしか履歴を見られない
- 別の端末には引き継がれない
- ブラウザのデータを削除すると履歴も消える

この制限はありますが、初期実装版では「まず動くものを作る」ことを優先します。

---

## 15. ビルド確認をする

公開前に、以下を実行します。

```bash
npm run build
```

成功すると、`dist` フォルダが作られます。

### なぜビルド確認が必要か

`npm run dev` では動いていても、公開用に変換するとエラーが出ることがあります。  
Vercel に公開する前に、ローカルで `npm run build` を通しておくと安全です。

---

## 16. GitHub に変更をアップロードする

作業が終わったら、以下の順で GitHub に反映します。

```bash
git status
```

変更されたファイルを確認します。

```bash
git add .
```

変更を保存対象にします。

```bash
git commit -m "Initialize Vite React app"
```

変更内容に名前を付けて記録します。

```bash
git push origin main
```

GitHub にアップロードします。

### なぜこの手順が必要か

GitHub に反映するには、次の 3 段階が必要です。

| 手順 | 役割 |
|---|---|
| `git add .` | どの変更を記録するか選ぶ |
| `git commit` | 変更を履歴として保存する |
| `git push` | GitHub にアップロードする |

---

## 17. Vercel で公開する

## 17.1 GitHub と Vercel を連携する

Vercel にログインし、GitHub の `yorimitiBiyori` リポジトリを選んで Import します。

公式サイト：

```text
https://vercel.com/
```

### 基本設定

Vite プロジェクトの場合、通常は以下の設定になります。

| 項目 | 設定 |
|---|---|
| Framework Preset | Vite |
| Build Command | `npm run build` |
| Output Directory | `dist` |
| Install Command | `npm install` |

### なぜ Vercel を使うのか

Vercel は GitHub と連携でき、`main` ブランチに push すると自動で再公開できます。  
また、Pull Request ごとにプレビュー URL を作れるため、チーム開発で確認しやすくなります。

---

## 17.2 React Router を使う場合の注意

React Router を使った SPA では、Vercel 上で `/history` などに直接アクセスすると 404 になることがあります。

その場合は、プロジェクト直下に `vercel.json` を作成します。

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### なぜ必要か

React Router の画面切り替えは、ブラウザ側で行われます。  
しかし、Vercel に直接 `/history` を見に行くと、サーバー側は `/history` というファイルを探してしまいます。

`vercel.json` の rewrite 設定により、どの URL にアクセスしても一度 `index.html` を返し、その後 React Router が正しい画面を表示できます。

---

## 18. 初期実装では入れないもの

以下は便利ですが、最初から入れると難度が上がるため、初期実装版では入れません。

| 入れないもの | 理由 |
|---|---|
| Firebase Authentication | ログイン設計が必要になるため |
| Firestore | データベース設計と権限設定が必要になるため |
| Google Calendar API | Google Cloud 設定、OAuth、スコープ管理が必要になるため |
| Google Maps API / Places API | API キー管理と課金設定が必要になるため |
| Geolocation API | 位置情報の許可とプライバシー説明が必要になるため |

まずは、ログインなしで使える MVP を完成させます。  
その後、余裕があれば発展機能として追加します。

---

## 19. よくあるエラーと対処

## 19.1 `npm` が見つからない

### 症状

```text
npm: command not found
```

または

```text
'npm' is not recognized as an internal or external command
```

### 原因

Node.js が入っていない、またはインストール後にターミナルを開き直していない可能性があります。

### 対処

1. Node.js LTS 版をインストールする
2. ターミナルを閉じる
3. もう一度ターミナルを開く
4. 以下を実行する

```bash
node -v
npm -v
```

---

## 19.2 `npm install` でエラーになる

### 対処

まず、プロジェクトの直下にいるか確認します。

```bash
pwd
```

Windows の場合は以下でも構いません。

```bash
cd
```

`package.json` がある場所で `npm install` を実行してください。

---

## 19.3 `npm run dev` が動かない

### 対処

`package.json` の中に `dev` があるか確認します。

```json
{
  "scripts": {
    "dev": "vite"
  }
}
```

`dev` がない場合は、Vite のプロジェクト作成ができていない可能性があります。

---

## 19.4 ブラウザに何も表示されない

### 対処

ターミナルに表示された URL を確認してください。

```text
http://localhost:5173/
```

`5173` ではなく、別の番号になることもあります。  
必ずターミナルに表示された URL を開いてください。

---

## 19.5 Tailwind CSS が反映されない

### 確認すること

1. `tailwindcss` と `@tailwindcss/vite` をインストールしたか
2. `vite.config.ts` に `tailwindcss()` を追加したか
3. `src/index.css` に `@import "tailwindcss";` を書いたか
4. `src/main.tsx` で `./index.css` を読み込んでいるか

---

## 20. 作業開始時の基本コマンドまとめ

毎回作業を始めるときは、以下の流れで始めます。

```bash
cd Desktop/app-dev/yorimitiBiyori
npm install
npm run dev
```

`npm install` は毎回必須ではありません。  
ただし、他のメンバーが新しいパッケージを追加した後は必要です。

---

## 21. 作業終了時の基本コマンドまとめ

作業が終わったら、以下の流れで GitHub に反映します。

```bash
git status
git add .
git commit -m "作業内容を短く書く"
git push origin main
```

コミットメッセージの例：

```text
Add activity suggestion page
Add localStorage history feature
Fix Tailwind layout
Add activities json data
```

---

## 22. 初心者向けの進め方

最初から全部を理解しようとしなくて構いません。  
以下の順に進めると、詰まりにくくなります。

1. `npm run dev` で画面を表示する
2. `App.tsx` の文字を変えて、ブラウザに反映されることを確認する
3. Tailwind CSS でボタンの見た目を変える
4. `activities.json` を作る
5. 条件に合う行動を 1 件表示する
6. 「別の提案」ボタンを作る
7. 「やってみた」ボタンで localStorage に保存する
8. 履歴画面を作る
9. `npm run build` を通す
10. Vercel に公開する

---

## 23. 参考リンク

公式ドキュメントを優先して確認してください。

| 項目 | URL |
|---|---|
| VS Code | https://code.visualstudio.com/ |
| Git | https://git-scm.com/ |
| Node.js | https://nodejs.org/ |
| Vite | https://vite.dev/guide/ |
| Tailwind CSS + Vite | https://tailwindcss.com/docs/installation/using-vite |
| React Router | https://reactrouter.com/start/declarative/installation |
| Vercel + Vite | https://vercel.com/docs/frameworks/frontend/vite |

---

## 24. まとめ

環境構築で入れるものは多く見えますが、役割で分けると整理できます。

| 役割 | 使うもの |
|---|---|
| コードを書く | VS Code |
| 変更履歴を管理する | Git |
| コードを共有する | GitHub |
| 開発ツールを動かす | Node.js / npm |
| React アプリの土台を作る | Vite |
| 画面を作る | React / TypeScript |
| 見た目を整える | Tailwind CSS |
| 画面を切り替える | React Router |
| 履歴を保存する | localStorage |
| 行動候補を管理する | activities.json |
| 公開する | Vercel |

まずは、**ローカルで画面が表示される状態**を最優先にしてください。  
その後、提案ロジック、履歴保存、画面分割、公開の順に進めると安定して開発できます。
