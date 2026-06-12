import { NavigationBar } from "./NavigationBar";

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

interface EmptyHistoryScreenProps {
  activeTab?: number;
  onTabChange?: (tab: number) => void;
}

export function EmptyHistoryScreen({ activeTab = 1, onTabChange }: EmptyHistoryScreenProps) {
  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", background: C.bg, overflowY: "auto", fontFamily: "'Noto Sans JP', sans-serif" }}>
      <div style={{ flex: 1, padding: "24px 24px 16px" }}>
        {/* Title */}
        <div style={{ marginBottom: "20px" }}>
          <h1 style={{ fontSize: "28px", fontWeight: 800, color: C.text, margin: 0, lineHeight: 1.2 }}>履歴</h1>
          <p style={{ fontSize: "14px", color: C.muted, margin: "6px 0 0", lineHeight: 1.5 }}>
            実施したよりみちと、スキップした提案を確認します。
          </p>
        </div>

        {/* Summary card (zeros) */}
        <div
          style={{
            background: C.surface,
            borderRadius: "24px",
            border: `1px solid ${C.outline}`,
            padding: "20px",
            marginBottom: "32px",
            display: "flex",
            alignItems: "center",
          }}
        >
          {[{ v: "0", label: "実施", color: C.primary }, { v: "0", label: "スキップ", color: "#7B6F00" }, { v: "0", label: "分", color: C.text }].map((item, i) => (
            <div key={item.label} style={{ flex: 1, textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center" }}>
              {i > 0 && <div style={{ position: "absolute", width: "1px", height: "48px", background: C.outline }} />}
              <p style={{ fontSize: "32px", fontWeight: 800, color: item.color, margin: 0 }}>{item.v}</p>
              <p style={{ fontSize: "12px", color: C.muted, margin: "4px 0 0" }}>{item.label}</p>
            </div>
          ))}
        </div>

        {/* Empty state */}
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", padding: "40px 24px", textAlign: "center" }}>
          {/* Illustration */}
          <div
            style={{
              width: "96px",
              height: "96px",
              borderRadius: "48px",
              background: C.primaryContainer,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              marginBottom: "24px",
            }}
          >
            <svg width="52" height="52" viewBox="0 0 52 52" fill="none">
              {/* Path / road icon */}
              <path d="M26 8C26 8 14 18 14 30C14 36.63 19.37 42 26 42C32.63 42 38 36.63 38 30C38 18 26 8 26 8Z" fill={C.primary} opacity="0.2" />
              <path d="M26 12C26 12 18 20 18 28C18 32.42 21.58 36 26 36C30.42 36 34 32.42 34 28C34 20 26 12 26 12Z" fill={C.primary} opacity="0.5" />
              <path d="M26 16C26 16 22 22 22 27C22 29.76 24.24 32 27 32C29.76 32 32 29.76 32 27C32 22 28 16 26 16Z" fill={C.primary} />
              {/* Footprints */}
              <circle cx="20" cy="40" r="3" fill={C.primary} opacity="0.3" />
              <circle cx="32" cy="44" r="3" fill={C.primary} opacity="0.3" />
              <circle cx="14" cy="46" r="2" fill={C.primary} opacity="0.2" />
            </svg>
          </div>

          <h2
            style={{
              fontSize: "18px",
              fontWeight: 800,
              color: C.text,
              margin: "0 0 10px",
            }}
          >
            まだ履歴はありません
          </h2>
          <p
            style={{
              fontSize: "14px",
              color: C.muted,
              margin: "0 0 28px",
              lineHeight: 1.7,
              maxWidth: "240px",
            }}
          >
            よりみちを実行すると、ここに記録されます。
          </p>

          {/* CTA to suggestion tab */}
          <button
            onClick={() => onTabChange?.(0)}
            style={{
              padding: "12px 28px",
              borderRadius: "24px",
              background: C.surfaceVariant,
              border: `1.5px solid ${C.outline}`,
              fontSize: "14px",
              fontWeight: 700,
              color: C.primary,
              cursor: "pointer",
            }}
          >
            提案を見てみる
          </button>
        </div>
      </div>

      <NavigationBar activeTab={activeTab} onTabChange={onTabChange} />
    </div>
  );
}
