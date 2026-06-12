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
  danger: "#BA1A1A",
};

const FONT = "'Noto Sans JP', sans-serif";

type TimeOption = "5分" | "15分" | "30分" | "60分";
type BudgetOption = "0円" | "500円以内" | "1000円以内" | "指定なし";
type DistanceOption = "その場でできる" | "徒歩5分以内" | "徒歩15分以内" | "少し遠くてもよい";

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
  { id: "shop", label: "買い物", emoji: "🛍️" },
];

function SectionTitle({ children }: { children: string }) {
  return (
    <p style={{ fontSize: "14px", fontWeight: 700, color: C.muted, margin: "0 0 10px", fontFamily: FONT }}>
      {children}
    </p>
  );
}

function FilterChipButton({
  label,
  active,
  onClick,
  emoji,
}: {
  label: string;
  active: boolean;
  onClick: () => void;
  emoji?: string;
}) {
  return (
    <button
      onClick={onClick}
      style={{
        display: "flex",
        alignItems: "center",
        gap: "5px",
        padding: "8px 14px",
        borderRadius: "18px",
        background: active ? C.primaryContainer : C.surface,
        border: `1.5px solid ${active ? C.primary : C.outline}`,
        fontSize: "13px",
        fontWeight: active ? 700 : 500,
        color: active ? C.primaryDark : C.muted,
        cursor: "pointer",
        fontFamily: FONT,
        transition: "all 0.12s ease",
      }}
    >
      {active && (
        <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
          <path d="M2 6L4.5 8.5L10 3" stroke={C.primary} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      )}
      {emoji && <span style={{ fontSize: "14px" }}>{emoji}</span>}
      {label}
    </button>
  );
}

function ChoiceRow({
  label,
  active,
  onClick,
}: {
  label: string;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      style={{
        width: "100%",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "12px 16px",
        background: active ? C.surfaceVariant : "transparent",
        border: "none",
        borderRadius: "14px",
        cursor: "pointer",
        marginBottom: "4px",
        fontFamily: FONT,
      }}
    >
      <span style={{ fontSize: "14px", fontWeight: active ? 700 : 400, color: active ? C.text : C.muted }}>
        {label}
      </span>
      <div
        style={{
          width: "20px",
          height: "20px",
          borderRadius: "10px",
          border: `2px solid ${active ? C.primary : C.outline}`,
          background: active ? C.primary : "transparent",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        {active && (
          <svg width="10" height="10" viewBox="0 0 10 10" fill="none">
            <path d="M2 5L4 7L8 3" stroke="white" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        )}
      </div>
    </button>
  );
}

export function SuggestSettingsScreen() {
  const [time, setTime] = useState<TimeOption>("15分");
  const [budget, setBudget] = useState<BudgetOption>("500円以内");
  const [distance, setDistance] = useState<DistanceOption>("徒歩15分以内");
  const [categories, setCategories] = useState(new Set(["walk", "cafe", "read"]));
  const [saved, setSaved] = useState(false);

  const toggleCategory = (id: string) => {
    setCategories((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const handleReset = () => {
    setTime("15分");
    setBudget("500円以内");
    setDistance("徒歩15分以内");
    setCategories(new Set(["walk", "cafe", "read"]));
    setSaved(false);
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", background: C.bg, fontFamily: FONT }}>
      {/* Sub-screen top bar (Flutter: AppBar style) */}
      <div
        style={{
          height: "56px",
          background: C.surface,
          borderBottom: `1px solid ${C.outline}`,
          display: "flex",
          alignItems: "center",
          padding: "0 8px 0 4px",
          flexShrink: 0,
          gap: "4px",
        }}
      >
        <button
          style={{
            width: "44px",
            height: "44px",
            borderRadius: "22px",
            background: "transparent",
            border: "none",
            cursor: "pointer",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M13 4L7 10L13 16" stroke={C.text} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        </button>
        <div style={{ flex: 1 }}>
          <p style={{ fontSize: "17px", fontWeight: 700, color: C.text, margin: 0 }}>提案設定</p>
        </div>
      </div>

      {/* Scrollable content */}
      <div style={{ flex: 1, overflowY: "auto", padding: "20px 20px 12px" }}>
        <p style={{ fontSize: "13px", color: C.muted, margin: "0 0 24px", lineHeight: 1.6 }}>
          よりみちの条件を調整できます。
        </p>

        {/* ── 1. 使える時間 ── */}
        <div
          style={{
            background: C.surface,
            borderRadius: "20px",
            border: `1px solid ${C.outline}`,
            padding: "16px",
            marginBottom: "14px",
          }}
        >
          <SectionTitle>使える時間</SectionTitle>
          <div style={{ display: "flex", flexWrap: "wrap", gap: "8px" }}>
            {(["5分", "15分", "30分", "60分"] as TimeOption[]).map((t) => (
              <FilterChipButton key={t} label={t} active={time === t} onClick={() => setTime(t)} />
            ))}
          </div>
        </div>

        {/* ── 2. 予算 (SegmentedButton style) ── */}
        <div
          style={{
            background: C.surface,
            borderRadius: "20px",
            border: `1px solid ${C.outline}`,
            padding: "16px",
            marginBottom: "14px",
          }}
        >
          <SectionTitle>予算</SectionTitle>
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "1fr 1fr",
              gap: "8px",
            }}
          >
            {(["0円", "500円以内", "1000円以内", "指定なし"] as BudgetOption[]).map((b) => {
              const active = budget === b;
              return (
                <button
                  key={b}
                  onClick={() => setBudget(b)}
                  style={{
                    padding: "10px 12px",
                    borderRadius: "14px",
                    background: active ? C.primaryContainer : C.surfaceVariant,
                    border: `1.5px solid ${active ? C.primary : "transparent"}`,
                    fontSize: "13px",
                    fontWeight: active ? 700 : 500,
                    color: active ? C.primaryDark : C.muted,
                    cursor: "pointer",
                    fontFamily: FONT,
                    textAlign: "center",
                  }}
                >
                  {active && "✓ "}{b}
                </button>
              );
            })}
          </div>
        </div>

        {/* ── 3. 移動距離 (ListTile radio style) ── */}
        <div
          style={{
            background: C.surface,
            borderRadius: "20px",
            border: `1px solid ${C.outline}`,
            padding: "16px",
            marginBottom: "14px",
          }}
        >
          <SectionTitle>移動距離</SectionTitle>
          {(["その場でできる", "徒歩5分以内", "徒歩15分以内", "少し遠くてもよい"] as DistanceOption[]).map((d) => (
            <ChoiceRow key={d} label={d} active={distance === d} onClick={() => setDistance(d)} />
          ))}
        </div>

        {/* ── 4. 興味カテゴリ (FilterChip, multi-select) ── */}
        <div
          style={{
            background: C.surface,
            borderRadius: "20px",
            border: `1px solid ${C.outline}`,
            padding: "16px",
            marginBottom: "20px",
          }}
        >
          <SectionTitle>興味カテゴリ（複数選択可）</SectionTitle>
          <div style={{ display: "flex", flexWrap: "wrap", gap: "8px" }}>
            {CATEGORIES.map((cat) => (
              <FilterChipButton
                key={cat.id}
                label={cat.label}
                emoji={cat.emoji}
                active={categories.has(cat.id)}
                onClick={() => toggleCategory(cat.id)}
              />
            ))}
          </div>
          <p style={{ fontSize: "12px", color: C.muted, margin: "10px 0 0" }}>
            {categories.size}つ選択中
          </p>
        </div>
      </div>

      {/* ── Bottom actions ── */}
      <div
        style={{
          padding: "12px 20px 28px",
          background: C.surface,
          borderTop: `1px solid ${C.outline}`,
          display: "flex",
          flexDirection: "column",
          gap: "10px",
          flexShrink: 0,
        }}
      >
        <button
          onClick={() => setSaved(true)}
          style={{
            width: "100%",
            height: "52px",
            borderRadius: "26px",
            background: saved ? "#2a5230" : C.primary,
            border: "none",
            fontSize: "16px",
            fontWeight: 700,
            color: "#FFFFFF",
            cursor: "pointer",
            fontFamily: FONT,
          }}
        >
          {saved ? "✓ 保存しました" : "この条件で保存"}
        </button>
        <button
          onClick={handleReset}
          style={{
            width: "100%",
            height: "40px",
            borderRadius: "20px",
            background: "transparent",
            border: "none",
            fontSize: "14px",
            fontWeight: 500,
            color: C.muted,
            cursor: "pointer",
            fontFamily: FONT,
          }}
        >
          初期設定に戻す
        </button>
      </div>
    </div>
  );
}
