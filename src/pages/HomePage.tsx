import { Link } from 'react-router';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';

export function HomePage() {
  return (
    <div className="grid gap-6">
      <Card>
        <p className="text-sm font-semibold text-emerald-800">MVP: 条件入力</p>
        <h2 className="mt-2 text-3xl font-bold tracking-tight">今ある空き時間に合う行動を探す</h2>
        <p className="mt-3 max-w-2xl text-emerald-950/70">
          空き時間・強度・場所・予算を選ぶと、activities.json の行動候補から今すぐできる行動を提案します。
        </p>
        <div className="mt-6">
          <Link to="/suggest">
            <Button>提案画面へ進む</Button>
          </Link>
        </div>
      </Card>
    </div>
  );
}
