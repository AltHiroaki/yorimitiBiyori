import { HistoryItem } from "../HistoryScreen";

/* ─────────────────────────────────────────────────────
   Issue #46 スキップ復活フロー用モックデータ

   Flutter 本体では SuggestionRecord が title などを
   非正規化して保持し、復活時に suggestionId で
   suggestions.json から現行データを引く。ここでは
   履歴行の表示は REVIVE_HISTORY 側、モーダルの詳細は
   REVIVE_SUGGESTIONS（提案マスタ）から引く構造で再現する。
───────────────────────────────────────────────────── */

export interface ReviveSuggestion {
  id: string;
  title: string;
  titleLine2?: string;
  body: string;
  tags: string[];
  time: string;
}

export type ReviveHistoryItem = HistoryItem & { suggestionId: string };

/* 提案マスタ（suggestions.json 相当） */
export const REVIVE_SUGGESTIONS: Record<string, ReviveSuggestion> = {
  "sug-music-01": {
    id: "sug-music-01",
    title: "普段聴かない音楽を",
    titleLine2: "1曲だけ聴く",
    body: "いつものプレイリストから離れて、知らないジャンルの1曲を聴いてみる。短い時間で気分が切り替わります。",
    tags: ["音楽", "気分転換"],
    time: "5分",
  },
  "sug-cafe-01": {
    id: "sug-cafe-01",
    title: "近くのカフェで",
    titleLine2: "ゆっくりする",
    body: "いつもと少し違う場所で、好きな飲み物を楽しむ。仕事の合間のリセットタイムに。",
    tags: ["カフェ", "気分転換"],
    time: "30分",
  },
  "sug-stretch-01": {
    id: "sug-stretch-01",
    title: "その場で軽く",
    titleLine2: "ストレッチする",
    body: "肩と首をゆっくり回して、体のこわばりをほぐす。座ったままでもできる小さなよりみちです。",
    tags: ["運動", "休憩"],
    time: "5分",
  },
};

/* 履歴（SuggestionRecord 相当）。
   done 行はタップ不可のまま。skipped 3件のうち
   id:6 は提案マスタに存在しない ID（提案データの
   更新で削除済み）→ 復活不可ケースの確認用。 */
export const REVIVE_HISTORY: ReviveHistoryItem[] = [
  { id: 1, title: "近くを15分だけ散歩する", date: "6月5日", tag: "気分転換", duration: "15分", done: true, suggestionId: "sug-walk-01" },
  { id: 2, title: "普段聴かない音楽を1曲聴く", date: "6月4日", tag: "音楽", duration: "5分", done: false, suggestionId: "sug-music-01" },
  { id: 3, title: "気になるテーマを少し調べる", date: "6月3日", tag: "学習", duration: "30分", done: true, suggestionId: "sug-research-01" },
  { id: 4, title: "近くのカフェでゆっくりする", date: "6月2日", tag: "カフェ", duration: "30分", done: false, suggestionId: "sug-cafe-01" },
  { id: 5, title: "短い記事を1本読む", date: "6月1日", tag: "読書", duration: "15分", done: true, suggestionId: "sug-read-01" },
  { id: 6, title: "窓の外を眺めて休憩する", date: "5月30日", tag: "休憩", duration: "5分", done: false, suggestionId: "sug-removed-99" },
];
