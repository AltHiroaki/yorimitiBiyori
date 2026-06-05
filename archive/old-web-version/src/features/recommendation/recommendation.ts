import type { Activity } from '../../types/activity';
import type { Condition } from '../../types/condition';

export function findMatchedActivities(activities: Activity[], condition: Condition): Activity[] {
  return activities.filter((activity) => {
    const matchesTime = activity.max_minutes <= condition.free_minutes;
    const matchesIntensity = activity.intensity === condition.intensity;
    const matchesLocation =
      activity.location_type === condition.location_type || activity.location_type === 'どこでも';
    const matchesBudget =
      condition.budget_yen === '指定なし' || activity.budget_yen <= condition.budget_yen;

    return matchesTime && matchesIntensity && matchesLocation && matchesBudget;
  });
}

export function pickRandomActivity(activities: Activity[]): Activity | null {
  if (activities.length === 0) {
    return null;
  }

  const index = Math.floor(Math.random() * activities.length);
  return activities[index];
}
