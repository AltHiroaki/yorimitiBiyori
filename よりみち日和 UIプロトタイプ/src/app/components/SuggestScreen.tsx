import { useState } from "react";
import { NavigationBar } from "./NavigationBar";

const C = {
  bg: "#F8FBF3",
  surface: "#FFFFFF",
  surfaceVariant: "#EEF5E8",
  primary: "#3F6F44",
  primaryContainer: "#C2E8C0",
  primaryDark: "#0B2A10",
  text: "#1A1C18",
  muted: "#5D6358",
  tagText: "#596E57",
  outline: "#DFE6D9",
};

// Default stored conditions (would come from local storage in real app)
const DEFAULT_CONDITIONS = {
  time: "15分",
  budget: "500円以内",
  distance: "徒歩圏内",
  categories: ["散歩", "カフェ", "読書"],
};

type SuggestContent = {
  title: string;
  titleLine2?: string;
  body: string;
  tags: string[];
  time: string;
};

const SUGGESTIONS: Record<string, SuggestContent[]> = {
  "15": [
    {
      title: "近くを15分だけ",
      titleLine2: "散歩する",
      body: "スマホをしまって、いつも通らない道を少しだけ歩いてみる。気分転換に向いた軽いよりみちです。",
      tags: ["気分転換", "散歩"],
      time: "15分",
    },
    {
      title: "好きな音楽を",
      titleLine2: "1曲だけ聴く",
      body: "ちょっと手を止めて、お気に入りの1曲をじっくり聴いてみる。短い休憩にぴったりです。",
      tags: ["音楽", "休憩"],
      time: "15分",
    },
  ],
  "30": [
    {
      title: "気になるテーマを",
      titleLine2: "少し調べる",
      body: "ずっと気になっていたことを、30分だけ集中して調べてみる。小さな好奇心が学びのきっかけに。",
      tags: ["学習", "休憩"],
      time: "30分",
    },
    {
      title: "近くのカフェで",
      titleLine2: "ゆっくりする",
      body: "いつもと少し違う場所で、好きな飲み物を楽しむ。仕事の合間のリセットタイムに。",
      tags: ["カフェ", "気分転換"],
      time: "30分",
    },
  ],
  "60": [
    {
      title: "近くのカフェで",
      titleLine2: "本を1冊読む",
      body: "いつもと少し違う場所で、ゆっくり読書する時間を作ってみる。気持ちをリセットするのにもぴったり。",
      tags: ["読書", "カフェ"],
      time: "60分",
    },
  ],
};

function ConditionPill({ label }: { label: string }) {
  return (
    <span
      style={{
        padding: "3px 10px",
        background: C.primaryContainer,
        borderRadius: "10px",
        fontSize: "12px",
        fontWeight: 600,
        color: C.primaryDark,
        fontFamily: "'Noto Sans JP', sans-serif",
        whiteSpace: "nowrap",
      }}
    >
      {label}
    </span>
  );
}

export interface SuggestScreenProps {
  activeTab?: number;
  onTabChange?: (tab: number) => void;
  fromNotification?: number; // pre-selected time in minutes from notification
}

export function SuggestScreen({ activeTab = 0, onTabChange, fromNotification }: SuggestScreenProps) {
  const timeKey = fromNotification ? String(fromNotification) : "15";
  const suggestions = SUGGESTIONS[timeKey] || SUGGESTIONS["15"];
  const [suggestionIndex, setSuggestionIndex] = useState(0);
  const [done, setDone] = useState(false);

  const currentSuggestion = suggestions[suggestionIndex % suggestions.length];
  const conditions = fromNotification
    ? { ...DEFAULT_CONDITIONS, time: `${fromNotification}分` }
    : DEFAULT_CONDITIONS;

  const handleNext = () => {
    setSuggestionIndex((i) => i + 1);
    setDone(false);
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", background: C.bg, overflowY: "auto" }}>
      <div style={{ flex: 1, padding: "24px 20px 12px" }}>

        {/* App title */}
        <div style={{ marginBottom: "18px" }}>
          <h1 style={{ fontSize: "26px", fontWeight: 800, color: C.text, margin: 0, lineHeight: 1.2, fontFamily: "'Noto Sans JP', sans-serif" }}>
            よりみち日和
          </h1>
          <p style={{ fontSize: "13px", color: C.muted, margin: "5px 0 0", fontFamily: "'Noto Sans JP', sans-serif" }}>
            空いた時間に、小さなよりみちを。
          </p>
        </div>

        {/* ── 現在の提案条件カード ── */}
        <div
          style={{
            background: C.surface,
            borderRadius: "20px",
            border: `1px solid ${C.outline}`,
            padding: "14px 16px",
            marginBottom: "16px",
          }}
        >
          {/* Header row */}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "10px" }}>
            <span style={{ fontSize: "12px", fontWeight: 700, color: C.muted, fontFamily: "'Noto Sans JP', sans-serif" }}>
              現在の提案条件
            </span>
            <button
              style={{
                background: "none",
                border: "none",
                fontSize: "12px",
                fontWeight: 700,
                color: C.primary,
                cursor: "pointer",
                padding: "2px 0",
                fontFamily: "'Noto Sans JP', sans-serif",
                display: "flex",
                alignItems: "center",
                gap: "2px",
              }}
            >
              提案設定
              <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                <path d="M4.5 2.5L8 6L4.5 9.5" stroke={C.primary} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </button>
          </div>

          {/* Notification label */}
          {fromNotification && (
            <div
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: "5px",
                background: "#FFF3E0",
                border: "1px solid #FFB74D",
                borderRadius: "10px",
                padding: "3px 10px",
                marginBottom: "8px",
              }}
            >
              <svg width="11" height="11" viewBox="0 0 11 11" fill="none">
                <path d="M5.5 1C3.01 1 1 3.01 1 5.5C1 7.99 3.01 10 5.5 10C7.99 10 10 7.99 10 5.5C10 3.01 7.99 1 5.5 1Z" fill="#FB8C00" />
                <rect x="5" y="3" width="1" height="3" rx="0.5" fill="white" />
                <circle cx="5.5" cy="7.5" r="0.5" fill="white" />
              </svg>
              <span style={{ fontSize: "11px", fontWeight: 600, color: "#E65100", fontFamily: "'Noto Sans JP', sans-serif" }}>
                通知から選択: {fromNotification}分
              </span>
            </div>
          )}

          {/* Condition pills */}
          <div style={{ display: "flex", flexWrap: "wrap", gap: "6px", alignItems: "center" }}>
            <ConditionPill label={`⏱ ${conditions.time}`} />
            <ConditionPill label={`¥ ${conditions.budget}`} />
            <ConditionPill label={`📍 ${conditions.distance}`} />
            <span style={{ fontSize: "12px", color: C.muted, fontFamily: "'Noto Sans JP', sans-serif" }}>
              {conditions.categories.join("・")}
            </span>
          </div>
        </div>

        {/* ── 今日のよりみちカード ── */}
        <div
          style={{
            background: C.surface,
            borderRadius: "28px",
            border: `1px solid ${C.outline}`,
            padding: "20px",
            marginBottom: "14px",
          }}
        >
          {/* Card header */}
          <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "14px" }}>
            <div
              style={{
                width: "40px",
                height: "40px",
                borderRadius: "20px",
                background: C.primaryContainer,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                flexShrink: 0,
              }}
            >
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <path d="M10 2C10 2 5 7 5 11C5 13.76 7.24 16 10 16C12.76 16 15 13.76 15 11C15 7 10 2 10 2Z" fill={C.primary} />
                <path d="M10 9C9.45 9 9 9.45 9 10C9 10.55 9.45 11 10 11C10.55 11 11 10.55 11 10C11 9.45 10.55 9 10 9Z" fill="white" />
              </svg>
            </div>
            <div>
              <p style={{ fontSize: "13px", fontWeight: 700, color: C.primary, margin: 0, fontFamily: "'Noto Sans JP', sans-serif" }}>
                今日のよりみち
              </p>
              <p style={{ fontSize: "12px", color: C.muted, margin: "2px 0 0", fontFamily: "'Noto Sans JP', sans-serif" }}>
                {currentSuggestion.time}でできる
              </p>
            </div>
          </div>

          {/* Title */}
          <h2
            style={{
              fontSize: "22px",
              fontWeight: 800,
              color: C.text,
              margin: "0 0 10px",
              lineHeight: 1.35,
              fontFamily: "'Noto Sans JP', sans-serif",
            }}
          >
            {currentSuggestion.title}
            {currentSuggestion.titleLine2 && (
              <>
                <br />
                {currentSuggestion.titleLine2}
              </>
            )}
          </h2>

          <p style={{ fontSize: "13px", color: C.muted, margin: "0 0 14px", lineHeight: 1.65, fontFamily: "'Noto Sans JP', sans-serif" }}>
            {currentSuggestion.body}
          </p>

          {/* Tags */}
          <div style={{ display: "flex", gap: "8px", marginBottom: "18px", flexWrap: "wrap" }}>
            {currentSuggestion.tags.map((tag) => (
              <span
                key={tag}
                style={{
                  padding: "5px 14px",
                  background: C.surfaceVariant,
                  borderRadius: "14px",
                  fontSize: "12px",
                  fontWeight: 500,
                  color: C.tagText,
                  fontFamily: "'Noto Sans JP', sans-serif",
                }}
              >
                {tag}
              </span>
            ))}
            <span
              style={{
                padding: "5px 14px",
                background: C.surfaceVariant,
                borderRadius: "14px",
                fontSize: "12px",
                fontWeight: 500,
                color: C.tagText,
                fontFamily: "'Noto Sans JP', sans-serif",
              }}
            >
              {currentSuggestion.time}
            </span>
          </div>

          {/* Action buttons */}
          <div style={{ display: "flex", gap: "10px" }}>
            <button
              onClick={() => setDone(true)}
              style={{
                flex: 1,
                height: "48px",
                borderRadius: "24px",
                background: done ? "#2a5230" : C.primary,
                border: "none",
                fontSize: "15px",
                fontWeight: 700,
                color: "#FFFFFF",
                cursor: "pointer",
                fontFamily: "'Noto Sans JP', sans-serif",
              }}
            >
              {done ? "✓ やった！" : "やってみる"}
            </button>
            <button
              onClick={handleNext}
              style={{
                flex: 1,
                height: "48px",
                borderRadius: "24px",
                background: C.surface,
                border: `1.5px solid ${C.outline}`,
                fontSize: "15px",
                fontWeight: 700,
                color: C.primary,
                cursor: "pointer",
                fontFamily: "'Noto Sans JP', sans-serif",
              }}
            >
              別の提案
            </button>
          </div>
        </div>

        {/* Info card */}
        <div style={{ background: C.surfaceVariant, borderRadius: "16px", padding: "12px 14px" }}>
          <p style={{ fontSize: "12px", color: C.muted, margin: 0, lineHeight: 1.65, fontFamily: "'Noto Sans JP', sans-serif" }}>
            通知をタップすると選んだ時間の提案が表示されます。
            条件を変えたいときは「提案設定」から調整できます。
          </p>
        </div>
      </div>

      <NavigationBar activeTab={activeTab} onTabChange={onTabChange} />
    </div>
  );
}
