import { useState } from "react";

const C = {
  bg: "#F8FBF3",
  surface: "#FFFFFF",
  surfaceVariant: "#EEF5E8",
  primary: "#3F6F44",
  primaryContainer: "#C2E8C0",
  primaryDark: "#0B2A10",
  text: "#1A1C18",
  muted: "#5D6358",
  outline: "#DFE6D9",
};

const CATEGORIES = [
  { id: "walk", label: "散歩", emoji: "🚶" },
  { id: "music", label: "音楽", emoji: "🎵" },
  { id: "read", label: "読書", emoji: "📖" },
  { id: "learn", label: "学習", emoji: "💡" },
  { id: "cafe", label: "カフェ", emoji: "☕" },
  { id: "photo", label: "写真", emoji: "📷" },
  { id: "tidy", label: "整理", emoji: "🗂️" },
  { id: "rest", label: "休憩", emoji: "🌿" },
  { id: "exercise", label: "運動", emoji: "🏃" },
];

export function CategoryScreen() {
  const [selected, setSelected] = useState<Set<string>>(new Set(["walk", "music", "read", "learn"]));

  const toggle = (id: string) => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        height: "100%",
        background: C.bg,
        overflowY: "auto",
        fontFamily: "'Noto Sans JP', sans-serif",
      }}
    >
      <div style={{ flex: 1, padding: "28px 24px 20px" }}>
        {/* Header */}
        <div style={{ marginBottom: "28px" }}>
          {/* Progress indicator */}
          <div style={{ display: "flex", gap: "6px", marginBottom: "24px" }}>
            {[0, 1, 2].map((i) => (
              <div
                key={i}
                style={{
                  height: "4px",
                  flex: 1,
                  borderRadius: "2px",
                  background: i === 0 ? C.primary : C.outline,
                }}
              />
            ))}
          </div>

          <h1
            style={{
              fontSize: "22px",
              fontWeight: 800,
              color: C.text,
              margin: "0 0 10px",
              lineHeight: 1.35,
            }}
          >
            興味のあるよりみちを
            <br />
            選んでください
          </h1>
          <p style={{ fontSize: "13px", color: C.muted, margin: 0, lineHeight: 1.6 }}>
            あなたに合った提案を出すために、気になるカテゴリを選んでください。
          </p>
        </div>

        {/* Chips grid */}
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: "10px",
            marginBottom: "24px",
          }}
        >
          {CATEGORIES.map((cat) => {
            const active = selected.has(cat.id);
            return (
              <button
                key={cat.id}
                onClick={() => toggle(cat.id)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "6px",
                  padding: "10px 18px",
                  borderRadius: "20px",
                  background: active ? C.primaryContainer : C.surface,
                  border: `1.5px solid ${active ? C.primary : C.outline}`,
                  fontSize: "14px",
                  fontWeight: active ? 700 : 500,
                  color: active ? C.primaryDark : C.muted,
                  cursor: "pointer",
                  fontFamily: "'Noto Sans JP', sans-serif",
                  transition: "all 0.15s ease",
                }}
              >
                {active && (
                  <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                    <path d="M2.5 7L5.5 10L11.5 4" stroke={C.primary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                )}
                <span style={{ fontSize: "15px" }}>{cat.emoji}</span>
                {cat.label}
              </button>
            );
          })}
        </div>

        {/* Selection count */}
        <p style={{ fontSize: "13px", color: C.muted, textAlign: "center" }}>
          {selected.size}つ選択中
        </p>
      </div>

      {/* Bottom button */}
      <div
        style={{
          padding: "16px 24px 32px",
          borderTop: `1px solid ${C.outline}`,
          background: C.surface,
        }}
      >
        <button
          style={{
            width: "100%",
            height: "52px",
            borderRadius: "26px",
            background: selected.size > 0 ? C.primary : "#C4CCBD",
            border: "none",
            fontSize: "16px",
            fontWeight: 700,
            color: "#FFFFFF",
            cursor: selected.size > 0 ? "pointer" : "default",
            fontFamily: "'Noto Sans JP', sans-serif",
          }}
        >
          次へ
        </button>
      </div>
    </div>
  );
}
