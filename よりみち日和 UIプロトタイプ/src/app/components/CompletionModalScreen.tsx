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
  tagText: "#596E57",
  outline: "#DFE6D9",
};

const CHOICES = [
  { id: "good", label: "よかった", emoji: "😊" },
  { id: "normal", label: "普通", emoji: "🙂" },
  { id: "bad", label: "合わなかった", emoji: "😐" },
];

function StaticSuggestBg() {
  return (
    <div style={{ padding: "24px", fontFamily: "'Noto Sans JP', sans-serif", opacity: 0.9 }}>
      <div style={{ marginBottom: "20px" }}>
        <div style={{ fontSize: "28px", fontWeight: 800, color: C.text }}>よりみち日和</div>
        <div style={{ fontSize: "14px", color: C.muted, marginTop: "6px" }}>空いた時間に、小さなよりみちを。</div>
      </div>
      <div style={{ background: C.surface, borderRadius: "28px", border: `1px solid ${C.outline}`, padding: "20px" }}>
        <div style={{ fontSize: "24px", fontWeight: 800, color: C.text, marginBottom: "10px", lineHeight: 1.3 }}>近くを15分だけ<br />散歩する</div>
        <div style={{ display: "flex", gap: "12px", marginTop: "20px" }}>
          <div style={{ flex: 1, height: "44px", borderRadius: "22px", background: "#2a5230", display: "flex", alignItems: "center", justifyContent: "center" }}>
            <span style={{ fontSize: "14px", fontWeight: 700, color: "#fff", fontFamily: "'Noto Sans JP', sans-serif" }}>✓ やった！</span>
          </div>
          <div style={{ flex: 1, height: "44px", borderRadius: "22px", border: `1.5px solid ${C.outline}` }} />
        </div>
      </div>
    </div>
  );
}

export function CompletionModalScreen() {
  const [selected, setSelected] = useState<string | null>("good");

  return (
    <div style={{ height: "100%", position: "relative", background: C.bg }}>
      {/* Background */}
      <div style={{ position: "absolute", inset: 0, overflow: "hidden", pointerEvents: "none" }}>
        <StaticSuggestBg />
      </div>

      {/* Dim overlay */}
      <div style={{ position: "absolute", inset: 0, background: "rgba(10,18,10,0.50)" }} />

      {/* Modal */}
      <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "flex-end", justifyContent: "center", padding: "0 0 0" }}>
        <div
          style={{
            background: C.surface,
            borderRadius: "32px 32px 0 0",
            padding: "28px 24px 40px",
            width: "100%",
            boxShadow: "0 -8px 32px rgba(0,0,0,0.16)",
          }}
        >
          {/* Drag handle */}
          <div style={{ width: "40px", height: "4px", borderRadius: "2px", background: C.outline, margin: "0 auto 24px" }} />

          {/* Header */}
          <div style={{ textAlign: "center", marginBottom: "24px" }}>
            <div
              style={{
                width: "56px",
                height: "56px",
                borderRadius: "28px",
                background: C.primaryContainer,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                margin: "0 auto 14px",
              }}
            >
              <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                <path d="M5 14L11 20L23 8" stroke={C.primary} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
            <h3
              style={{
                fontSize: "20px",
                fontWeight: 800,
                color: C.text,
                margin: "0 0 8px",
                fontFamily: "'Noto Sans JP', sans-serif",
              }}
            >
              おつかれさまです
            </h3>
            <p style={{ fontSize: "14px", color: C.muted, margin: 0, fontFamily: "'Noto Sans JP', sans-serif" }}>
              今回のよりみちはどうでしたか？
            </p>
          </div>

          {/* Choice chips */}
          <div style={{ display: "flex", gap: "10px", marginBottom: "24px", justifyContent: "center" }}>
            {CHOICES.map((c) => {
              const active = selected === c.id;
              return (
                <button
                  key={c.id}
                  onClick={() => setSelected(c.id)}
                  style={{
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    gap: "6px",
                    padding: "12px 14px",
                    borderRadius: "16px",
                    background: active ? C.primaryContainer : C.surfaceVariant,
                    border: `1.5px solid ${active ? C.primary : C.outline}`,
                    cursor: "pointer",
                    fontFamily: "'Noto Sans JP', sans-serif",
                    minWidth: "80px",
                    transition: "all 0.15s ease",
                  }}
                >
                  <span style={{ fontSize: "22px" }}>{c.emoji}</span>
                  <span
                    style={{
                      fontSize: "12px",
                      fontWeight: active ? 700 : 500,
                      color: active ? C.primaryDark : C.muted,
                    }}
                  >
                    {c.label}
                  </span>
                </button>
              );
            })}
          </div>

          {/* Save button */}
          <button
            style={{
              width: "100%",
              height: "52px",
              borderRadius: "26px",
              background: C.primary,
              border: "none",
              fontSize: "16px",
              fontWeight: 700,
              color: "#FFFFFF",
              cursor: "pointer",
              fontFamily: "'Noto Sans JP', sans-serif",
            }}
          >
            履歴に保存
          </button>
        </div>
      </div>
    </div>
  );
}
