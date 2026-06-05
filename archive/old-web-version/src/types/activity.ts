export type ActivityIntensity = 'ゆるめ' | '普通' | 'アクティブ';

export type ActivityLocationType = '学内' | '駅周辺' | '自宅' | 'どこでも';

export type Activity = {
  id: string;
  title: string;
  description: string;
  category: string;
  min_minutes: number;
  max_minutes: number;
  intensity: ActivityIntensity;
  location_type: ActivityLocationType;
  budget_yen: number;
  indoor: boolean;
  solo: boolean;
  required_items: string[];
  weight: number;
};
