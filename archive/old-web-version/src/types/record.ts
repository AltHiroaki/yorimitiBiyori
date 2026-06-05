import type { ActivityIntensity, ActivityLocationType } from './activity';

export type RecordStatus = 'done' | 'skipped';

export type ActivityRecord = {
  id: string;
  activity_id: string;
  activity_title: string;
  status: RecordStatus;
  selected_minutes: number;
  selected_intensity: ActivityIntensity;
  selected_location: ActivityLocationType;
  created_at: string;
};
