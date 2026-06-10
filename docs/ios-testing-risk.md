# iOS 導入方針と確認環境に関する懸念

このドキュメントは、`よりみち日和` の MVP を Android のみに絞り、iOS を発展版で導入する場合の懸念と対応方針を整理するものです。

---

## 結論

チーム内に macOS 環境がない場合、iOS の開発・実機確認は Android より難しくなります。

iPhone 実機があっても、通常の Flutter / iOS 開発では、iOS アプリをビルドして実機に入れるために macOS、Xcode、署名環境が必要になります。

そのため、MVP では Android のみを実装・検証対象とし、iOS は MVP 完成後の発展版で導入します。

---

## 現在の前提

現在のチーム状況は以下です。

- macOS を持っているメンバーがいない
- iPhone 実機はある
- Windows PC では Android Emulator を使える
- Windows PC では iOS Simulator を使えない

このため、Android は MVP 開発中に比較的確認しやすい一方、iOS は発展版で導入するときに確認方法を別途用意する必要があります。

---

## できること・できないこと

| やりたいこと | macOS なし | 説明 |
|---|---:|---|
| Flutter のコードを書く | できる | Windows でも可能 |
| `flutter analyze` を実行する | できる | OS に依存しにくい |
| `flutter test` を実行する | できる | ロジック・Widget テストは可能 |
| Android Emulator で確認する | できる | Android Studio で可能 |
| Android 実機で確認する | できる | USB 接続や開発者向けオプションで可能 |
| iOS Simulator で確認する | できない | 発展版で iOS を導入するときに Xcode / macOS が必要 |
| iPhone 実機へ直接 `flutter run` する | 基本的にできない | 発展版で iOS ビルド・署名に macOS / Xcode が必要 |
| TestFlight で iPhone に配布する | 条件付きで可能 | 発展版で Apple Developer Program とクラウドビルド環境が必要 |

---

## なぜ懸念になるのか

`よりみち日和` の MVP では、Android の通知機能が重要です。

```text
通知
↓
15分 / 30分 / 60分 を選択
↓
提案画面を表示
```

通知は OS 依存が大きいため、Android で動いても iOS で同じように動くとは限りません。そのため、iOS 対応は MVP の完成条件から外し、発展版で個別に検証します。

特に確認すべき点は以下です。

- iOS で通知許可の表示が正しく出るか
- iOS でローカル通知が届くか
- iOS で通知アクションが表示されるか
- 通知アクションを押したときにアプリが開くか
- アプリ未起動時・バックグラウンド時の挙動が想定通りか

これらはコードレビューや Android 確認だけでは十分に判断できないため、発展版で iOS を導入するときの確認項目として扱います。

---

## MVP での基本方針

MVP では、Android のみを実装・検証対象にします。

```text
Windows PC
↓
Flutter 開発
↓
Android Emulator / Android 実機で確認
↓
通知機能も Android で完成させる
```

iOS は MVP 完成後の発展版で、以下のいずれかの方法を使って導入します。

- 大学・研究室・先生・友人などから Mac を一時的に借りる
- クラウド macOS 環境で iOS ビルドを作る
- Apple Developer Program と TestFlight を使って iPhone 実機に配布する

---

## 現実的な確認ルート

## 1. Android 版 MVP を作る

最も現実的な進め方です。

まず Android で以下を完成させます。

- 興味カテゴリ登録
- アプリ内で 15分 / 30分 / 60分 を選択
- 提案表示
- 実施 / スキップ
- 履歴保存
- ローカル通知
- 通知アクションから提案画面へ遷移

Android で中心機能を完成させてから、発展版として iOS 導入に進みます。

---

## 2. Mac を一時的に借りる

iOS 実機確認としては、この方法が最も分かりやすいです。

候補：

- 大学の Mac
- 研究室の Mac
- 先生の環境
- 友人の Mac
- 一時的な貸出端末

Mac が使える場合、Xcode と Flutter 環境を入れて iPhone 実機確認を行います。

---

## 3. クラウドビルドと TestFlight を使う

Mac が手元になくても、クラウド上の macOS 環境で iOS ビルドを作る方法があります。

候補：

- GitHub Actions の macOS runner
- Codemagic
- Bitrise

ただし、iPhone に配布するには基本的に以下が必要になります。

- Apple Developer Program
- App Store Connect
- Bundle ID
- 証明書
- Provisioning Profile
- TestFlight 設定

この方法は本格的ですが、授業内 MVP ではやや重いため、発展版で検討します。

---

## 先生やチームへの説明方針

先生やチームには、以下のように説明できるようにします。

```text
Flutter を採用する理由は、まず Android 版 MVP を作り、その後 iOS へ展開しやすくするためです。

ただし、チーム内に macOS 環境がないため、MVP では Android のみを対象にします。

iOS については、MVP 完成後の発展版で、Mac を一時的に借りる、またはクラウドビルドと TestFlight を使う方法で導入します。
```

このように説明することで、ネイティブアプリ化の方針は残しつつ、MVP の範囲と iOS 導入タイミングを明確にできます。

---

## 開発計画への反映

MVP の完成条件は、まず Android で定義します。

```text
Android で通知から提案まで動く
```

その後、iOS 導入を発展版の別タスクとして扱います。

```text
iOS 版を生成し、iPhone 実機で通知と通知アクションを確認する
```

つまり、iOS 対応を諦めるのではなく、MVP から切り離して発展版に分けます。

---

## まとめ

macOS がないことは、Flutter 採用を完全に否定する理由にはなりません。

ただし、iOS の開発・確認環境には明確なリスクがあります。

そのため、`よりみち日和` では以下の方針を採用します。

```text
MVP: Android のみ
発展版: iOS を導入
iOS 実機確認: Mac 借用またはクラウドビルドで対応
```

この懸念を事前に明記しておくことで、開発途中で「iOS が確認できない」問題に気づくのではなく、最初から MVP と発展版を分けて進められます。
