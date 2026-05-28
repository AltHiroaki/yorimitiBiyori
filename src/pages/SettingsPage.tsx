import { Card } from '../components/ui/Card';

export function SettingsPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <p className="text-sm font-semibold text-emerald-800">設定画面</p>
        <h2 className="mt-2 text-2xl font-bold">アプリ説明・履歴削除・バージョン情報</h2>
        <p className="mt-3 text-emerald-950/70">
          MVP ではログイン設定を置かず、localStorage の履歴削除とアプリ説明を中心に実装します。
        </p>
      </Card>
    </div>
  );
}
