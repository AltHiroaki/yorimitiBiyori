# VS Code で Git を操作する方法

このドキュメントは、`yorimitiBiyori` の開発で Git を使うときに、VS Code の画面からできる操作をまとめたものです。

Git はターミナルのコマンドで操作できますが、VS Code の Source Control 機能を使うと、変更内容の確認、stage、commit、push、pull、ブランチ切り替えなどを画面上で行えます。

---

## このドキュメントの目的

Git のコマンドを最初からすべて覚える必要はありません。

まずは VS Code の画面で操作しながら、裏側でどの Git コマンドに近いことが行われているのかを理解していくのがよいです。

このドキュメントでは、次の2つを対応させて説明します。

| やりたいこと | Git コマンド | VS Code での操作 |
|---|---|---|
| 変更状況を見る | `git status` | Source Control を見る |
| 変更内容を見る | `git diff` | 変更ファイルをクリックする |
| stage する | `git add` | `+` ボタンを押す |
| commit する | `git commit` | メッセージを書いて Commit を押す |
| GitHub に送る | `git push` | Sync Changes または Push を押す |
| GitHub から取る | `git pull` | Sync Changes または Pull を押す |
| ブランチを切り替える | `git checkout` / `git switch` | 左下のブランチ名をクリックする |
| 変更を破棄する | `git restore` | Discard Changes を選ぶ |

---

## 前提

VS Code で Git を使うには、PC に Git がインストールされている必要があります。

確認コマンド:

```bash
git --version
```

Git のユーザー名とメールアドレスも設定しておきます。

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

VS Code は Git を内蔵しているわけではなく、PC に入っている Git を使って操作します。  
そのため、Git 本体のインストールは必要です。

---

## Source Control を開く

VS Code の左側にある、枝分かれしたようなアイコンが **Source Control** です。

ショートカット:

```text
Windows / Linux: Ctrl + Shift + G
macOS: Control + Shift + G
```

ファイルを編集すると、Source Control のアイコンに数字が表示されます。  
この数字は、変更されたファイル数を表します。

---

## 変更状況を見る

対応する Git コマンド:

```bash
git status
```

VS Code では、Source Control を開くだけで変更されたファイルが一覧表示されます。

表示例:

```text
Changes
├─ README.md
├─ docs/vscode-Git使い方メモ.md
└─ lib/src/pages/home_page.dart
```

ファイル名の横には、変更の種類を表す記号が付くことがあります。

| 表示 | 意味 |
|---|---|
| `M` | Modified。既存ファイルを変更した |
| `U` | Untracked。Git がまだ管理していない新規ファイル |
| `D` | Deleted。ファイルを削除した |

---

## 変更内容を見る

対応する Git コマンド:

```bash
git diff
```

VS Code では、Source Control に表示されているファイルをクリックすると、変更前と変更後の差分を確認できます。

この確認はとても重要です。

commit する前に必ず差分を見て、次の点を確認します。

- 意図したファイルだけを変更しているか
- 不要な変更が混ざっていないか
- 消してはいけない行を消していないか
- デバッグ用の `console.log` などが残っていないか

Git 操作で一番大事なのは、commit する前に差分を見ることです。

---

## stage する

対応する Git コマンド:

```bash
git add ファイル名
```

すべて stage する場合:

```bash
git add .
```

VS Code では、Source Control の `Changes` にあるファイルの横の `+` ボタンを押すと stage できます。

すべての変更をまとめて stage したい場合は、`Changes` 見出しの横にある `+` を押します。

stage されると、ファイルは `Staged Changes` に移動します。

```text
Staged Changes
└─ README.md

Changes
└─ lib/src/pages/home_page.dart
```

この状態では、`README.md` だけが次の commit に含まれます。  
`HomePage.tsx` はまだ commit に含まれません。

---

## stage を取り消す

対応する Git コマンド:

```bash
git restore --staged ファイル名
```

VS Code では、`Staged Changes` にあるファイルの横の `-` ボタンを押すと、stage を取り消せます。

stage を取り消しても、ファイルの変更内容は消えません。  
単に「次の commit に含める予定」から外すだけです。

---

## commit する

対応する Git コマンド:

```bash
git commit -m "メッセージ"
```

VS Code では、Source Control 上部の入力欄に commit message を書き、`Commit` ボタンを押します。

例:

```text
Add VS Code Git guide
```

commit message は、何を変更したかが分かる短い文章にします。

良い例:

```text
Add history page layout
Fix activity filtering logic
Update environment setup guide
```

避けたい例:

```text
修正
更新
いろいろ変更
test
```

commit は「保存ポイント」のようなものです。  
意味のある単位で commit しておくと、後で変更履歴を追いやすくなります。

---

## GitHub に push する

対応する Git コマンド:

```bash
git push
```

VS Code では、Source Control の `Sync Changes` または `Push` を押します。

注意点:

commit しただけでは、GitHub にはまだ反映されません。  
commit は自分の PC 内の Git 履歴に保存する操作です。  
push して初めて GitHub 上のリポジトリに反映されます。

---

## GitHub から pull する

対応する Git コマンド:

```bash
git pull
```

VS Code では、Source Control の `Sync Changes` または `Pull` を押します。

チーム開発では、自分が作業する前に pull して、GitHub 上の最新状態を取り込むのが安全です。

おすすめの流れ:

```text
作業を始める
↓
Pull / Sync Changes
↓
コードを書く
↓
差分を見る
↓
Stage
↓
Commit
↓
Push / Sync Changes
```

---

## Sync Changes とは

VS Code の `Sync Changes` は、基本的に pull と push をまとめて行う操作です。

つまり、次の2つをまとめて実行するイメージです。

```bash
git pull
git push
```

ただし、状況によっては競合が発生することがあります。

競合が起きた場合は、VS Code がどのファイルで競合しているかを表示します。  
その場合は、内容を確認してどちらの変更を残すか決める必要があります。

---

## ブランチを確認する

対応する Git コマンド:

```bash
git branch
```

VS Code では、画面左下に現在のブランチ名が表示されます。

例:

```text
main
```

`main` と表示されていれば、現在 `main` ブランチで作業しています。

---

## ブランチを切り替える

対応する Git コマンド:

```bash
git checkout ブランチ名
```

または、最近の Git では次のコマンドも使います。

```bash
git switch ブランチ名
```

VS Code では、左下のブランチ名をクリックすると、ブランチ一覧が表示されます。  
そこから切り替えたいブランチを選びます。

注意点:

未 commit の変更が残っている状態でブランチを切り替えると、変更が邪魔をして切り替えられないことがあります。  
その場合は、先に commit するか、変更を破棄するか、一時退避する必要があります。

---

## 新しいブランチを作る

対応する Git コマンド:

```bash
git checkout -b ブランチ名
```

または:

```bash
git switch -c ブランチ名
```

VS Code では、左下のブランチ名をクリックし、`Create new branch` を選びます。

ブランチ名の例:

```text
feature/history-page
feature/activity-filter
fix/build-error
```

ブランチ名は、何の作業か分かる名前にします。

---

## 変更を破棄する

対応する Git コマンド:

```bash
git restore ファイル名
```

VS Code では、Source Control の変更ファイルを右クリックし、`Discard Changes` を選びます。

ただし、この操作は注意が必要です。

`Discard Changes` を実行すると、そのファイルの未 commit の変更が消えます。  
基本的に元に戻せない前提で考えてください。

使う前に、必ず差分を確認します。

---

## 一部のファイルだけ commit する

VS Code では、commit に含めたいファイルだけを stage できます。

例えば、次の変更があるとします。

```text
Changes
├─ README.md
├─ docs/vscode-Git使い方メモ.md
└─ lib/src/pages/home_page.dart
```

このうち、ドキュメントだけ commit したい場合は、次の2つだけ stage します。

```text
Staged Changes
├─ README.md
└─ docs/vscode-Git使い方メモ.md

Changes
└─ lib/src/pages/home_page.dart
```

この状態で commit すると、`HomePage.tsx` の変更は commit に含まれません。

これにより、関係のない変更を混ぜずに commit できます。

---

## コマンドと VS Code 操作の対応表

| Git コマンド | VS Code 操作 |
|---|---|
| `git status` | Source Control で変更一覧を見る |
| `git diff` | 変更ファイルをクリックして差分を見る |
| `git add ファイル名` | ファイル横の `+` を押す |
| `git add .` | `Changes` 見出し横の `+` を押す |
| `git restore --staged ファイル名` | `Staged Changes` のファイル横の `-` を押す |
| `git commit -m "message"` | メッセージを書いて `Commit` を押す |
| `git push` | `Push` または `Sync Changes` を押す |
| `git pull` | `Pull` または `Sync Changes` を押す |
| `git branch` | 左下のブランチ名を見る |
| `git checkout ブランチ名` | 左下のブランチ名から切り替える |
| `git switch ブランチ名` | 左下のブランチ名から切り替える |
| `git checkout -b ブランチ名` | `Create new branch` を選ぶ |
| `git restore ファイル名` | `Discard Changes` を選ぶ |

---

## VS Code 操作だけで済ませてよいのか

基本的な作業は VS Code の操作で十分です。

特に、以下は VS Code で行うと分かりやすいです。

- 変更ファイルの確認
- 差分確認
- stage
- commit
- push / pull
- ブランチ切り替え
- 変更の破棄

ただし、Git の仕組みは理解しておいたほうがよいです。

VS Code は Git を分かりやすく操作するための画面です。  
Git の考え方そのものが不要になるわけではありません。

例えば、次の区別は理解しておく必要があります。

| 概念 | 意味 |
|---|---|
| stage | 次の commit に含める変更を選ぶ |
| commit | 自分の PC の Git 履歴に保存する |
| push | GitHub に送る |
| pull | GitHub から取る |
| branch | 作業の流れを分ける |

---

## よくあるミス

### commit したのに GitHub に反映されない

commit だけでは GitHub に反映されません。  
push または Sync Changes を実行してください。

### 関係ないファイルまで commit してしまう

commit 前に Source Control で差分を確認してください。  
必要なファイルだけ stage すれば、関係ない変更を commit に含めずに済みます。

### 変更を破棄して作業内容が消えた

`Discard Changes` は未 commit の変更を消します。  
使う前に必ず差分を確認してください。

### Pull したら競合した

同じファイルの同じ場所を複数人が変更すると競合が起きます。  
VS Code は競合箇所を表示してくれるので、内容を確認して残す変更を選びます。

---

## おすすめの運用

普段の作業では、次の流れを使います。

```text
1. VS Code でプロジェクトを開く
2. Source Control を確認する
3. 作業前に Pull / Sync Changes する
4. コードを変更する
5. Source Control で差分を見る
6. 必要なファイルだけ stage する
7. commit message を書く
8. Commit する
9. Push / Sync Changes する
```

この流れを守ると、変更内容を確認しながら安全に作業できます。

---

## 参考リンク

VS Code の公式ドキュメント:

```text
https://code.visualstudio.com/docs/sourcecontrol/overview
https://code.visualstudio.com/docs/sourcecontrol/quickstart
```
