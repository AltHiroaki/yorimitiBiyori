import type { Activity } from '../../types/activity';
import { Card } from '../../components/ui/Card';

type ActivityCardProps = {
  activity: Activity;
};

export function ActivityCard({ activity }: ActivityCardProps) {
  return (
    <Card>
      <p className="text-sm font-semibold text-emerald-800">{activity.category}</p>
      <h3 className="mt-2 text-xl font-bold">{activity.title}</h3>
      <p className="mt-2 text-emerald-950/70">{activity.description}</p>
      <dl className="mt-4 grid gap-2 text-sm sm:grid-cols-2">
        <div>
          <dt className="font-semibold">所要時間</dt>
          <dd>{activity.min_minutes}〜{activity.max_minutes}分</dd>
        </div>
        <div>
          <dt className="font-semibold">強度</dt>
          <dd>{activity.intensity}</dd>
        </div>
        <div>
          <dt className="font-semibold">場所</dt>
          <dd>{activity.location_type}</dd>
        </div>
        <div>
          <dt className="font-semibold">予算</dt>
          <dd>{activity.budget_yen}円</dd>
        </div>
      </dl>
    </Card>
  );
}
