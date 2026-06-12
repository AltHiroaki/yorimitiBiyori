const C = {
  primary: "#3F6F44",
  primaryContainer: "#C2E8C0",
  text: "#1A1C18",
  muted: "#5D6358",
  surface: "#FFFFFF",
  outline: "#DFE6D9",
};

interface NavigationBarProps {
  activeTab: number;
  onTabChange?: (tab: number) => void;
}

function SuggestIcon({ active }: { active: boolean }) {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <path
        d="M12 3C7.03 3 3 7.03 3 12C3 14.39 3.92 16.56 5.44 18.19L4 20H12C16.97 20 21 15.97 21 12C21 7.03 16.97 3 12 3Z"
        fill={active ? C.primary : "none"}
        stroke={active ? C.primary : C.muted}
        strokeWidth="1.8"
      />
      <circle cx="9" cy="12" r="1.2" fill={active ? "#fff" : C.muted} />
      <circle cx="12" cy="12" r="1.2" fill={active ? "#fff" : C.muted} />
      <circle cx="15" cy="12" r="1.2" fill={active ? "#fff" : C.muted} />
    </svg>
  );
}

function HistoryIcon({ active }: { active: boolean }) {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="9" stroke={active ? C.primary : C.muted} strokeWidth="1.8" fill={active ? C.primaryContainer : "none"} />
      <path d="M12 7V12L15 14" stroke={active ? C.primary : C.muted} strokeWidth="1.8" strokeLinecap="round" />
    </svg>
  );
}

function SettingsIcon({ active }: { active: boolean }) {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
      <path
        d="M12 15C13.6569 15 15 13.6569 15 12C15 10.3431 13.6569 9 12 9C10.3431 9 9 10.3431 9 12C9 13.6569 10.3431 15 12 15Z"
        stroke={active ? C.primary : C.muted}
        strokeWidth="1.8"
        fill={active ? C.primaryContainer : "none"}
      />
      <path
        d="M19.14 12.94C19.18 12.64 19.2 12.33 19.2 12C19.2 11.68 19.18 11.36 19.13 11.06L21.16 9.48C21.34 9.34 21.39 9.07 21.28 8.87L19.36 5.55C19.24 5.33 18.99 5.26 18.77 5.33L16.38 6.29C15.88 5.91 15.35 5.59 14.76 5.35L14.4 2.81C14.36 2.57 14.16 2.4 13.92 2.4H10.08C9.84 2.4 9.65 2.57 9.61 2.81L9.25 5.35C8.66 5.59 8.12 5.92 7.63 6.29L5.24 5.33C5.01 5.25 4.76 5.33 4.64 5.55L2.72 8.87C2.6 9.08 2.66 9.34 2.86 9.48L4.89 11.06C4.84 11.36 4.8 11.69 4.8 12C4.8 12.31 4.82 12.64 4.87 12.94L2.84 14.52C2.66 14.66 2.61 14.93 2.72 15.13L4.64 18.45C4.76 18.67 5.01 18.74 5.23 18.67L7.62 17.71C8.12 18.09 8.65 18.41 9.24 18.65L9.6 21.19C9.65 21.43 9.84 21.6 10.08 21.6H13.92C14.16 21.6 14.36 21.43 14.39 21.19L14.75 18.65C15.34 18.41 15.88 18.08 16.37 17.71L18.76 18.67C18.99 18.75 19.24 18.67 19.36 18.45L21.28 15.13C21.4 14.91 21.34 14.66 21.15 14.52L19.14 12.94Z"
        stroke={active ? C.primary : C.muted}
        strokeWidth="1.5"
        fill={active ? C.primaryContainer : "none"}
      />
    </svg>
  );
}

export function NavigationBar({ activeTab, onTabChange }: NavigationBarProps) {
  const tabs = [
    { label: "提案", icon: SuggestIcon },
    { label: "履歴", icon: HistoryIcon },
    { label: "設定", icon: SettingsIcon },
  ];

  return (
    <div
      style={{
        height: "80px",
        background: C.surface,
        borderTop: `1px solid ${C.outline}`,
        display: "flex",
        alignItems: "center",
        flexShrink: 0,
        paddingBottom: "8px",
      }}
    >
      {tabs.map((tab, i) => {
        const active = activeTab === i;
        const Icon = tab.icon;
        return (
          <button
            key={tab.label}
            onClick={() => onTabChange?.(i)}
            style={{
              flex: 1,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: "4px",
              background: "none",
              border: "none",
              cursor: "pointer",
              padding: "8px 0",
            }}
          >
            <div
              style={{
                width: "64px",
                height: "32px",
                borderRadius: "16px",
                background: active ? C.primaryContainer : "transparent",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <Icon active={active} />
            </div>
            <span
              style={{
                fontSize: "12px",
                fontWeight: active ? 700 : 500,
                color: active ? C.primary : C.muted,
                fontFamily: "'Noto Sans JP', sans-serif",
              }}
            >
              {tab.label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
