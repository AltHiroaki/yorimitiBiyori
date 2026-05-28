import { Card } from '../components/ui/Card';

export function SuggestPage() {
  return (
    <div className="grid gap-6">
      <Card>
        <p className="text-sm font-semibold text-emerald-800">提案画面</p>
        <h2 className="mt-2 text-2xl font-bold">条件に合う行動を表示する画面</h2>
        <p className="mt-3 text-emerald-950/70">
          今後、条件フォームの入力値をもとに、提案カード・やってみた・別の提案・スキップの処理を実装します。
        </p>
      </Card>
    </div>
  );
}
