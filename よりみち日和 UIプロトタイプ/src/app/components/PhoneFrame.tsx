import { ReactNode } from "react";
import { useDesignTheme } from "../theme";

interface PhoneFrameProps {
  label: string;
  children: ReactNode;
  statusBg?: string;
}

export function PhoneFrame({ label, children, statusBg }: PhoneFrameProps) {
  const { colors } = useDesignTheme();
  const statusBackground = statusBg ?? colors.bg;
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: "12px" }}>
      <div
        style={{
          width: "375px",
          height: "812px",
          background: colors.bg,
          borderRadius: "48px",
          border: "1px solid #E2E7DB",
          overflow: "hidden",
          display: "flex",
          flexDirection: "column",
          boxShadow: "0 24px 48px rgba(34,51,34,0.12)",
          fontFamily: "'Noto Sans JP', 'Hiragino Sans', 'Yu Gothic', sans-serif",
          position: "relative",
        }}
      >
        {/* Status Bar */}
        <div
          style={{
            height: "44px",
            background: statusBackground,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            padding: "0 24px",
            flexShrink: 0,
            zIndex: 1,
          }}
        >
          <span style={{ fontSize: "15px", fontWeight: 700, color: "#1A1C18" }}>9:41</span>
          <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
            <svg width="17" height="12" viewBox="0 0 17 12" fill="none">
              <rect x="0" y="7" width="3" height="5" rx="1" fill="#1A1C18" />
              <rect x="4.5" y="4.5" width="3" height="7.5" rx="1" fill="#1A1C18" />
              <rect x="9" y="2" width="3" height="10" rx="1" fill="#1A1C18" />
              <rect x="13.5" y="0" width="3" height="12" rx="1" fill="#1A1C18" opacity="0.3" />
            </svg>
            <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
              <path d="M8 9.5C8.83 9.5 9.5 10.17 9.5 11S8.83 12.5 8 12.5 6.5 11.83 6.5 11 7.17 9.5 8 9.5Z" fill="#1A1C18" />
              <path d="M8 6C9.93 6 11.68 6.78 12.95 8.05L14.36 6.64C12.72 5 10.47 4 8 4S3.28 5 1.64 6.64L3.05 8.05C4.32 6.78 6.07 6 8 6Z" fill="#1A1C18" opacity="0.5" />
            </svg>
            <div style={{ display: "flex", alignItems: "center" }}>
              <div style={{ width: "25px", height: "12px", border: "1.5px solid #1A1C18", borderRadius: "3px", display: "flex", alignItems: "center", padding: "1.5px" }}>
                <div style={{ width: "17px", height: "7px", background: "#1A1C18", borderRadius: "1px" }} />
              </div>
              <div style={{ width: "2px", height: "5px", background: "#1A1C18", borderRadius: "0 1px 1px 0", marginLeft: "1px" }} />
            </div>
          </div>
        </div>

        {/* Content area — position: relative so modals can use position: absolute */}
        <div style={{ flex: 1, position: "relative", overflow: "hidden" }}>
          {children}
        </div>
      </div>

      <span style={{ fontSize: "13px", fontWeight: 700, color: "#5D6358", fontFamily: "'Noto Sans JP', sans-serif" }}>
        {label}
      </span>
    </div>
  );
}
