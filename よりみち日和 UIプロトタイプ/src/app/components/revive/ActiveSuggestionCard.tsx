import { useDesignTheme } from "../../theme";
import { ReviveSuggestion } from "./reviveMockData";

/* ─────────────────────────────────────────────────────
   実施中カード（Issue #48 相当の見た目）
   「今日のよりみち」カードの変形。ボタンは
   完了 / スキップ の 2 つ。本モック（Issue #46）の
   フロー終点なので押下時の挙動は持たない。
───────────────────────────────────────────────────── */

export function ActiveSuggestionCard({ suggestion }: { suggestion: ReviveSuggestion }) {
  const { colors: C, shape: SH, effects: E, font: F } = useDesignTheme();
  return (
    <div
      style={{
        background: C.surface,
        borderRadius: SH.heroRadius,
        border: E.cardBorder,
        boxShadow: E.heroShadow,
        backdropFilter: E.surfaceBlur,
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
        <div style={{ flex: 1 }}>
          <p style={{ fontSize: "13px", fontWeight: 700, color: C.primary, margin: 0, fontFamily: F }}>
            実施中のよりみち
          </p>
          <p style={{ fontSize: "12px", color: C.muted, margin: "2px 0 0", fontFamily: F }}>
            {suggestion.time}でできる
          </p>
        </div>
        <span
          style={{
            fontSize: "12px",
            fontWeight: 600,
            color: C.primary,
            background: C.primaryContainer,
            padding: "4px 10px",
            borderRadius: SH.pillRadius,
            flexShrink: 0,
            fontFamily: F,
          }}
        >
          実施中
        </span>
      </div>

      {/* Title */}
      <h2
        style={{
          fontSize: "22px",
          fontWeight: 800,
          color: C.text,
          margin: "0 0 10px",
          lineHeight: 1.35,
          fontFamily: F,
        }}
      >
        {suggestion.title}
        {suggestion.titleLine2 && (
          <>
            <br />
            {suggestion.titleLine2}
          </>
        )}
      </h2>

      <p style={{ fontSize: "13px", color: C.muted, margin: "0 0 14px", lineHeight: 1.65, fontFamily: F }}>
        {suggestion.body}
      </p>

      {/* Tags */}
      <div style={{ display: "flex", gap: "8px", marginBottom: "18px", flexWrap: "wrap" }}>
        {[...suggestion.tags, suggestion.time].map((tag) => (
          <span
            key={tag}
            style={{
              padding: "5px 14px",
              background: C.surfaceVariant,
              borderRadius: SH.chipRadius,
              boxShadow: E.chipShadow,
              fontSize: "12px",
              fontWeight: 500,
              color: C.tagText,
              fontFamily: F,
            }}
          >
            {tag}
          </span>
        ))}
      </div>

      {/* 完了 / スキップ（Issue #48。本モックでは見た目のみ） */}
      <div style={{ display: "flex", gap: "10px" }}>
        <button
          style={{
            flex: 1,
            height: "48px",
            borderRadius: SH.buttonRadius,
            background: C.primary,
            boxShadow: E.primaryBtnShadow,
            border: "none",
            fontSize: "15px",
            fontWeight: 700,
            color: "#FFFFFF",
            cursor: "pointer",
            fontFamily: F,
          }}
        >
          完了
        </button>
        <button
          style={{
            flex: 1,
            height: "48px",
            borderRadius: SH.buttonRadius,
            background: C.surface,
            border: E.secondaryBtnBorder,
            boxShadow: E.secondaryBtnShadow,
            fontSize: "15px",
            fontWeight: 700,
            color: C.primary,
            cursor: "pointer",
            fontFamily: F,
          }}
        >
          スキップ
        </button>
      </div>
    </div>
  );
}
