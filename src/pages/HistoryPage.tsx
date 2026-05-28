import { Card } from '../components/ui/Card';

export function HistoryPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <p className="text-sm font-semibold text-emerald-800">履歴画面</p>
        <h2 className="mt-2 text-2xl font-bold">実施・スキップ履歴を振り返る画面</h2>
        <p className="mt-3 text-emerald-950/70">
          今後、localStorage に保存した records を読み込み、実施率と履歴一覧を表示します。
        </p>
      </Card>
    </div>
  );
}
