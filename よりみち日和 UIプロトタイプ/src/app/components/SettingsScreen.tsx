import { useState } from "react";
import { NavigationBar } from "./NavigationBar";
import { useDesignTheme } from "../theme";

interface SettingsScreenProps {
  activeTab?: number;
  onTabChange?: (tab: number) => void;
}

function Divider() {
  const { colors: C } = useDesignTheme();
  return <div style={{ height: "1px", background: C.outline, margin: "0 4px" }} />;
}

interface RowProps {
  label: string;
  sub?: string;
  action?: string;
  danger?: boolean;
  right?: React.ReactNode;
}

function SettingsRow({ label, sub, action, danger: isDanger, right }: RowProps) {
  const { colors: C, font: F } = useDesignTheme();
  return (
    <div style={{ padding: "14px 20px", display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <p
          style={{
            fontSize: "15px",
            fontWeight: 700,
            color: isDanger ? C.danger : C.text,
            margin: 0,
            fontFamily: F,
          }}
        >
          {label}
        </p>
        {sub && (
          <p
            style={{
              fontSize: "12px",
              color: C.muted,
              margin: "3px 0 0",
              fontFamily: F,
            }}
          >
            {sub}
          </p>
        )}
      </div>
      {right ? (
        right
      ) : action ? (
        <button
          style={{
            background: "none",
            border: "none",
            fontSize: "13px",
            fontWeight: 500,
            color: isDanger ? C.danger : C.primary,
            cursor: "pointer",
            padding: "4px 8px",
            fontFamily: F,
            flexShrink: 0,
          }}
        >
          {action}
        </button>
      ) : null}
    </div>
  );
}

function Toggle({ on, onChange }: { on: boolean; onChange: (v: boolean) => void }) {
  const { colors: C } = useDesignTheme();
  return (
    <button
      onClick={() => onChange(!on)}
      style={{
        width: "52px",
        height: "30px",
        borderRadius: "15px",
        background: on ? C.primary : "#C4CCBD",
        border: "none",
        cursor: "pointer",
        position: "relative",
        transition: "background 0.2s ease",
        flexShrink: 0,
      }}
    >
      <div
        style={{
          position: "absolute",
          top: "3px",
          left: on ? "25px" : "3px",
          width: "24px",
          height: "24px",
          borderRadius: "12px",
          background: "#FFFFFF",
          boxShadow: "0 1px 3px rgba(0,0,0,0.2)",
          transition: "left 0.2s ease",
        }}
      />
    </button>
  );
}

export function SettingsScreen({ activeTab = 2, onTabChange }: SettingsScreenProps) {
  const { colors: C, shape: SH, effects: E, font: F } = useDesignTheme();
  const [notificationsOn, setNotificationsOn] = useState(true);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", background: C.screenBackground, overflowY: "auto" }}>
      <div style={{ flex: 1, padding: "24px 24px 16px" }}>
        {/* Title */}
        <div style={{ marginBottom: "24px" }}>
          <h1
            style={{
              fontSize: "28px",
              fontWeight: 800,
              color: C.text,
              margin: 0,
              lineHeight: 1.2,
              fontFamily: F,
            }}
          >
            設定
          </h1>
          <p
            style={{
              fontSize: "14px",
              color: C.muted,
              margin: "6px 0 0",
              fontFamily: F,
            }}
          >
            興味カテゴリ、通知時刻、アカウント、履歴を管理します。
          </p>
        </div>

        {/* 基本設定 */}
        <p
          style={{
            fontSize: "17px",
            fontWeight: 700,
            color: C.text,
            margin: "0 0 10px",
            fontFamily: F,
          }}
        >
          基本設定
        </p>

        <div
          style={{
            background: C.surface,
            borderRadius: SH.panelRadius,
            border: E.cardBorder,
            boxShadow: E.cardShadow,
            backdropFilter: E.surfaceBlur,
            overflow: "hidden",
            marginBottom: "20px",
          }}
        >
          {/* Google account row */}
          <div style={{ padding: "14px 20px", display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "12px", flex: 1, minWidth: 0 }}>
              {/* Google G logo */}
              <div style={{ width: "28px", height: "28px", borderRadius: "14px", background: "#F8F8F8", border: "1px solid #E8E8E8", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <svg width="16" height="16" viewBox="0 0 48 48">
                  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.31-8.16 2.31-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
                </svg>
              </div>
              <div>
                <p style={{ fontSize: "15px", fontWeight: 700, color: C.text, margin: 0, fontFamily: F }}>Googleアカウント</p>
                <p style={{ fontSize: "12px", color: C.muted, margin: "3px 0 0", fontFamily: F }}>未連携</p>
              </div>
            </div>
            <button style={{ background: "none", border: "none", fontSize: "13px", fontWeight: 500, color: C.primary, cursor: "pointer", padding: "4px 8px", fontFamily: F, flexShrink: 0 }}>連携</button>
          </div>
          <Divider />
          {/* 提案設定 row */}
          <div style={{ padding: "14px 20px", display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "12px", flex: 1 }}>
              <div style={{ width: "28px", height: "28px", borderRadius: "8px", background: C.surfaceVariant, border: `1px solid ${C.outline}`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M2 4H14M2 8H10M2 12H12" stroke={C.primary} strokeWidth="1.6" strokeLinecap="round" />
                </svg>
              </div>
              <div>
                <p style={{ fontSize: "15px", fontWeight: 700, color: C.text, margin: 0, fontFamily: F }}>提案設定</p>
                <p style={{ fontSize: "12px", color: C.muted, margin: "3px 0 0", fontFamily: F }}>時間・予算・移動距離を調整</p>
              </div>
            </div>
            <button style={{ background: "none", border: "none", fontSize: "13px", fontWeight: 500, color: C.primary, cursor: "pointer", padding: "4px 8px", fontFamily: F, flexShrink: 0 }}>変更</button>
          </div>
          <Divider />
          <SettingsRow label="興味カテゴリ" sub="散歩・音楽・読書・学習" action="編集" />
          <Divider />
          <SettingsRow label="通知時刻" sub="毎日 17:30" action="変更" />
          <Divider />
          <div style={{ padding: "14px 20px", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <div>
              <p
                style={{
                  fontSize: "15px",
                  fontWeight: 700,
                  color: C.text,
                  margin: 0,
                  fontFamily: F,
                }}
              >
                通知
              </p>
              <p
                style={{
                  fontSize: "12px",
                  color: C.muted,
                  margin: "3px 0 0",
                  fontFamily: F,
                }}
              >
                空き時間のきっかけを受け取る
              </p>
            </div>
            <Toggle on={notificationsOn} onChange={setNotificationsOn} />
          </div>
        </div>

        {/* データ */}
        <p
          style={{
            fontSize: "17px",
            fontWeight: 700,
            color: C.text,
            margin: "0 0 10px",
            fontFamily: F,
          }}
        >
          データ
        </p>

        <div
          style={{
            background: C.surface,
            borderRadius: SH.panelRadius,
            border: E.cardBorder,
            boxShadow: E.cardShadow,
            backdropFilter: E.surfaceBlur,
            overflow: "hidden",
            marginBottom: "16px",
          }}
        >
          {showDeleteConfirm ? (
            <div style={{ padding: "16px 20px" }}>
              <p
                style={{
                  fontSize: "14px",
                  color: C.text,
                  margin: "0 0 12px",
                  fontFamily: F,
                }}
              >
                本当に削除しますか？この操作は取り消せません。
              </p>
              <div style={{ display: "flex", gap: "10px" }}>
                <button
                  onClick={() => setShowDeleteConfirm(false)}
                  style={{
                    flex: 1,
                    height: "40px",
                    borderRadius: SH.buttonRadius,
                    background: C.surfaceVariant,
                    border: "none",
                    fontSize: "14px",
                    fontWeight: 700,
                    color: C.muted,
                    cursor: "pointer",
                    fontFamily: F,
                  }}
                >
                  キャンセル
                </button>
                <button
                  onClick={() => setShowDeleteConfirm(false)}
                  style={{
                    flex: 1,
                    height: "40px",
                    borderRadius: SH.buttonRadius,
                    background: C.danger,
                    border: "none",
                    fontSize: "14px",
                    fontWeight: 700,
                    color: "#FFFFFF",
                    cursor: "pointer",
                    fontFamily: F,
                  }}
                >
                  削除する
                </button>
              </div>
            </div>
          ) : (
            <>
              <div
                style={{ padding: "14px 20px", display: "flex", alignItems: "center", justifyContent: "space-between" }}
              >
                <div>
                  <p
                    style={{
                      fontSize: "15px",
                      fontWeight: 700,
                      color: C.danger,
                      margin: 0,
                      fontFamily: F,
                    }}
                  >
                    履歴削除
                  </p>
                  <p
                    style={{
                      fontSize: "12px",
                      color: C.muted,
                      margin: "3px 0 0",
                      fontFamily: F,
                    }}
                  >
                    端末内に保存した履歴を削除
                  </p>
                </div>
                <button
                  onClick={() => setShowDeleteConfirm(true)}
                  style={{
                    background: "none",
                    border: "none",
                    fontSize: "13px",
                    fontWeight: 500,
                    color: C.danger,
                    cursor: "pointer",
                    padding: "4px 8px",
                    fontFamily: F,
                  }}
                >
                  削除
                </button>
              </div>
              <Divider />
              <SettingsRow label="アプリについて" sub="よりみち日和 MVP" action="表示" />
            </>
          )}
        </div>

        {/* Footer note */}
        <div
          style={{
            background: C.surfaceVariant,
            borderRadius: SH.cardRadius,
            boxShadow: E.chipShadow,
            padding: "14px 16px",
          }}
        >
          <p
            style={{
              fontSize: "13px",
              color: C.muted,
              margin: 0,
              lineHeight: 1.6,
              fontFamily: F,
            }}
          >
            MVPではログインなしでも利用できます。Googleアカウント連携は、バックアップや将来のカレンダー連携に使います。
          </p>
        </div>
      </div>

      <NavigationBar activeTab={activeTab} onTabChange={onTabChange} />
    </div>
  );
}
