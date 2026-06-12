const C = {
  bg: "#F8FBF3",
  surface: "#FFFFFF",
  surfaceVariant: "#EEF5E8",
  primary: "#3F6F44",
  primaryContainer: "#C2E8C0",
  text: "#1A1C18",
  muted: "#5D6358",
  outline: "#DFE6D9",
};

function StaticSuggestBg() {
  return (
    <div style={{ padding: "24px", fontFamily: "'Noto Sans JP', sans-serif" }}>
      <div style={{ marginBottom: "20px" }}>
        <div style={{ fontSize: "28px", fontWeight: 800, color: C.text }}>よりみち日和</div>
        <div style={{ fontSize: "14px", color: C.muted, marginTop: "6px" }}>空いた時間に、小さなよりみちを。</div>
      </div>
      <div style={{ background: C.surface, borderRadius: "28px", border: `1px solid ${C.outline}`, padding: "20px", marginBottom: "16px" }}>
        <div style={{ fontSize: "24px", fontWeight: 800, color: C.text, marginBottom: "10px", lineHeight: 1.3 }}>近くを15分だけ<br />散歩する</div>
        <div style={{ fontSize: "14px", color: C.muted, lineHeight: 1.6 }}>スマホをしまって、いつも通らない道を少しだけ歩いてみる。</div>
        <div style={{ display: "flex", gap: "8px", marginTop: "14px" }}>
          <div style={{ padding: "6px 14px", background: C.surfaceVariant, borderRadius: "14px", fontSize: "12px", color: "#596E57" }}>気分転換</div>
          <div style={{ padding: "6px 14px", background: C.surfaceVariant, borderRadius: "14px", fontSize: "12px", color: "#596E57" }}>15分</div>
        </div>
        <div style={{ display: "flex", gap: "12px", marginTop: "16px" }}>
          <div style={{ flex: 1, height: "44px", borderRadius: "22px", background: C.primary }} />
          <div style={{ flex: 1, height: "44px", borderRadius: "22px", border: `1.5px solid ${C.outline}` }} />
        </div>
      </div>
    </div>
  );
}

export function NotificationPermissionScreen() {
  return (
    <div style={{ height: "100%", position: "relative", background: C.bg }}>
      {/* Background */}
      <div style={{ position: "absolute", inset: 0, overflow: "hidden", pointerEvents: "none" }}>
        <StaticSuggestBg />
      </div>

      {/* Dim overlay */}
      <div style={{ position: "absolute", inset: 0, background: "rgba(10,18,10,0.52)" }} />

      {/* Dialog card (AlertDialog style) */}
      <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", padding: "28px" }}>
        <div
          style={{
            background: C.surface,
            borderRadius: "28px",
            padding: "28px 24px 24px",
            width: "100%",
            boxShadow: "0 8px 32px rgba(0,0,0,0.18)",
          }}
        >
          {/* Bell icon */}
          <div
            style={{
              width: "56px",
              height: "56px",
              borderRadius: "28px",
              background: C.surfaceVariant,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              marginBottom: "16px",
            }}
          >
            <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
              <path d="M14 3C10.13 3 7 6.13 7 10V17L5 19V20H23V19L21 17V10C21 6.13 17.87 3 14 3Z" fill={C.primary} />
              <path d="M12 21C12 22.1 12.9 23 14 23C15.1 23 16 22.1 16 21H12Z" fill={C.primary} />
              <circle cx="19" cy="5" r="4" fill="#E53935" />
            </svg>
          </div>

          <h3
            style={{
              fontSize: "18px",
              fontWeight: 800,
              color: C.text,
              margin: "0 0 10px",
              lineHeight: 1.35,
              fontFamily: "'Noto Sans JP', sans-serif",
            }}
          >
            よりみちのきっかけを
            <br />
            通知します
          </h3>
          <p
            style={{
              fontSize: "13px",
              color: C.muted,
              margin: "0 0 24px",
              lineHeight: 1.7,
              fontFamily: "'Noto Sans JP', sans-serif",
            }}
          >
            空き時間に、小さな行動の提案をお届けします。
            <br />
            通知はあとから設定で変更できます。
          </p>

          {/* Filled button */}
          <button
            style={{
              width: "100%",
              height: "48px",
              borderRadius: "24px",
              background: C.primary,
              border: "none",
              fontSize: "15px",
              fontWeight: 700,
              color: "#FFFFFF",
              cursor: "pointer",
              marginBottom: "10px",
              fontFamily: "'Noto Sans JP', sans-serif",
            }}
          >
            通知を許可する
          </button>

          {/* Text / Outlined button */}
          <button
            style={{
              width: "100%",
              height: "44px",
              borderRadius: "22px",
              background: "transparent",
              border: `1.5px solid ${C.outline}`,
              fontSize: "15px",
              fontWeight: 500,
              color: C.muted,
              cursor: "pointer",
              fontFamily: "'Noto Sans JP', sans-serif",
            }}
          >
            あとで
          </button>
        </div>
      </div>
    </div>
  );
}
