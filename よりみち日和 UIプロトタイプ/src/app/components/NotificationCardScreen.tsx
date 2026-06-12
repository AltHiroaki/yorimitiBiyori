const C = {
  bg: "#E8EDDF",
  surface: "#FFFFFF",
  primary: "#3F6F44",
  primaryContainer: "#C2E8C0",
  text: "#1A1C18",
  muted: "#5D6358",
  outline: "#DFE6D9",
};

export function NotificationCardScreen() {
  return (
    <div
      style={{
        height: "100%",
        background: "linear-gradient(160deg, #E0EBD8 0%, #C8DFC4 100%)",
        display: "flex",
        flexDirection: "column",
        fontFamily: "'Noto Sans JP', sans-serif",
        overflowY: "auto",
      }}
    >
      {/* Lock screen clock area */}
      <div style={{ textAlign: "center", padding: "48px 0 32px" }}>
        <div style={{ fontSize: "64px", fontWeight: 200, color: "#1A1C18", lineHeight: 1, letterSpacing: "-2px" }}>17:30</div>
        <div style={{ fontSize: "15px", color: "#5D6358", marginTop: "6px" }}>2026年6月5日 金曜日</div>
      </div>

      {/* Notification banner */}
      <div style={{ padding: "0 16px", display: "flex", flexDirection: "column", gap: "10px" }}>
        {/* Main notification card */}
        <div
          style={{
            background: "rgba(255,255,255,0.92)",
            borderRadius: "20px",
            padding: "14px 16px",
            boxShadow: "0 4px 20px rgba(34,51,34,0.12)",
            backdropFilter: "blur(12px)",
          }}
        >
          {/* App header */}
          <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "8px" }}>
            <div
              style={{
                width: "22px",
                height: "22px",
                borderRadius: "6px",
                background: C.primary,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                flexShrink: 0,
              }}
            >
              <svg width="13" height="13" viewBox="0 0 13 13" fill="none">
                <path d="M6.5 1C6.5 1 3 4.5 3 7C3 8.93 4.57 10.5 6.5 10.5C8.43 10.5 10 8.93 10 7C10 4.5 6.5 1 6.5 1Z" fill="#C2E8C0" />
                <path d="M6.5 6C5.95 6 5.5 6.45 5.5 7C5.5 7.55 5.95 8 6.5 8C7.05 8 7.5 7.55 7.5 7C7.5 6.45 7.05 6 6.5 6Z" fill="white" />
              </svg>
            </div>
            <span style={{ fontSize: "12px", fontWeight: 600, color: C.muted }}>よりみち日和</span>
            <span style={{ fontSize: "11px", color: C.muted, marginLeft: "auto" }}>今</span>
          </div>

          {/* Title + body */}
          <div style={{ paddingLeft: "30px" }}>
            <p style={{ fontSize: "15px", fontWeight: 700, color: C.text, margin: "0 0 3px" }}>
              15分だけ、少し歩いてみませんか？
            </p>
            <p style={{ fontSize: "13px", color: C.muted, margin: 0, lineHeight: 1.5 }}>
              近くを散歩して気分転換しましょう
            </p>
          </div>
        </div>

        {/* Second notification (faded, to show multiple) */}
        <div
          style={{
            background: "rgba(255,255,255,0.75)",
            borderRadius: "20px",
            padding: "12px 16px",
            boxShadow: "0 2px 10px rgba(34,51,34,0.08)",
            opacity: 0.8,
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "6px" }}>
            <div style={{ width: "22px", height: "22px", borderRadius: "6px", background: "#C2E8C0", flexShrink: 0 }} />
            <span style={{ fontSize: "12px", fontWeight: 600, color: C.muted }}>よりみち日和</span>
            <span style={{ fontSize: "11px", color: C.muted, marginLeft: "auto" }}>昨日</span>
          </div>
          <div style={{ paddingLeft: "30px" }}>
            <p style={{ fontSize: "14px", fontWeight: 600, color: C.text, margin: "0 0 2px" }}>30分の空き時間、ありませんか？</p>
            <p style={{ fontSize: "13px", color: C.muted, margin: 0 }}>新しい音楽を1曲聴いてみませんか</p>
          </div>
        </div>
      </div>

      {/* Bottom note */}
      <div style={{ marginTop: "auto", padding: "24px 16px 16px", textAlign: "center" }}>
        <div
          style={{
            background: "rgba(255,255,255,0.6)",
            borderRadius: "12px",
            padding: "10px 16px",
            fontSize: "12px",
            color: "#5D6358",
          }}
        >
          タップするとアプリで詳しい提案が見られます
        </div>
      </div>
    </div>
  );
}
