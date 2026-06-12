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
      <div style={{ marginBottom: "16px" }}>
        <div style={{ fontSize: "15px", fontWeight: 700, color: C.text, marginBottom: "10px" }}>今ある時間</div>
        <div style={{ display: "flex", gap: "10px" }}>
          {[{ label: "15分", active: true }, { label: "30分", active: false }, { label: "60分", active: false }].map((t) => (
            <div key={t.label} style={{ height: "40px", padding: "0 20px", borderRadius: "20px", background: t.active ? C.primaryContainer : C.surface, border: `1px solid ${t.active ? C.primary : C.outline}`, fontSize: "14px", fontWeight: 700, color: t.active ? "#0B2A10" : C.muted, display: "flex", alignItems: "center" }}>{t.label}</div>
          ))}
        </div>
      </div>
      <div style={{ background: C.surface, borderRadius: "28px", border: `1px solid ${C.outline}`, padding: "20px", height: "260px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "14px" }}>
          <div style={{ width: "40px", height: "40px", borderRadius: "20px", background: C.primaryContainer }} />
          <div>
            <div style={{ fontSize: "14px", fontWeight: 700, color: C.primary }}>今日のよりみち</div>
            <div style={{ fontSize: "12px", color: C.muted, marginTop: "2px" }}>15分でできる</div>
          </div>
        </div>
        <div style={{ fontSize: "24px", fontWeight: 800, color: C.text, marginBottom: "10px", lineHeight: 1.3 }}>近くを15分だけ<br />散歩する</div>
        <div style={{ fontSize: "14px", color: C.muted, lineHeight: 1.6 }}>スマホをしまって、いつも通らない道を少しだけ歩いてみる。</div>
      </div>
    </div>
  );
}

export function WelcomeModalScreen() {
  return (
    <div style={{ height: "100%", position: "relative", background: C.bg }}>
      {/* Blurred background */}
      <div style={{ position: "absolute", inset: 0, overflow: "hidden", pointerEvents: "none" }}>
        <StaticSuggestBg />
      </div>

      {/* Dim overlay */}
      <div style={{ position: "absolute", inset: 0, background: "rgba(10,18,10,0.56)" }} />

      {/* Modal card */}
      <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", padding: "28px" }}>
        <div
          style={{
            background: C.surface,
            borderRadius: "32px",
            padding: "36px 28px 28px",
            width: "100%",
            textAlign: "center",
            boxShadow: "0 8px 32px rgba(0,0,0,0.18)",
          }}
        >
          {/* Icon */}
          <div
            style={{
              width: "72px",
              height: "72px",
              borderRadius: "36px",
              background: C.primaryContainer,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              margin: "0 auto 20px",
            }}
          >
            <svg width="36" height="36" viewBox="0 0 36 36" fill="none">
              <path d="M18 6C14 6 10 8 8 12C6 16 7 22 10 26C13 30 16 32 18 32C20 32 23 30 26 26C29 22 30 16 28 12C26 8 22 6 18 6Z" fill={C.primary} opacity="0.2" />
              <path d="M18 8C18 8 12 14 12 20C12 23.31 14.69 26 18 26C21.31 26 24 23.31 24 20C24 14 18 8 18 8Z" fill={C.primary} />
              <path d="M18 20C16.89 20 16 19.1 16 18C16 16 18 13 18 13C18 13 20 16 20 18C20 19.1 19.1 20 18 20Z" fill="#C2E8C0" />
            </svg>
          </div>

          <h2
            style={{
              fontSize: "22px",
              fontWeight: 800,
              color: C.text,
              margin: "0 0 12px",
              lineHeight: 1.3,
              fontFamily: "'Noto Sans JP', sans-serif",
            }}
          >
            よりみち日和へようこそ
          </h2>
          <p
            style={{
              fontSize: "14px",
              color: C.muted,
              margin: "0 0 28px",
              lineHeight: 1.7,
              fontFamily: "'Noto Sans JP', sans-serif",
            }}
          >
            空いた時間にできる、小さなよりみちを提案します。まずは気になるカテゴリを選んでみましょう。
          </p>

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
            はじめる
          </button>
        </div>
      </div>
    </div>
  );
}
