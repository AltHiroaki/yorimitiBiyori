import type { ActivityRecord } from '../../types/record';

const STORAGE_KEY = 'yorimiti-biyori-records';

export function loadRecords(): ActivityRecord[] {
  const rawRecords = localStorage.getItem(STORAGE_KEY);

  if (!rawRecords) {
    return [];
  }

  try {
    return JSON.parse(rawRecords) as ActivityRecord[];
  } catch {
    return [];
  }
}

export function saveRecords(records: ActivityRecord[]): void {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
}

export function clearRecords(): void {
  localStorage.removeItem(STORAGE_KEY);
}
