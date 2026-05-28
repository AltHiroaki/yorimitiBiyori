import type { ActivityIntensity, ActivityLocationType } from './activity';

export type BudgetCondition = 0 | 500 | '指定なし';

export type Condition = {
  free_minutes: 15 | 30 | 45 | 60;
  intensity: ActivityIntensity;
  location_type: ActivityLocationType;
  budget_yen: BudgetCondition;
};
