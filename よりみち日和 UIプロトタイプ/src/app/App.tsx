import { useState, ReactNode } from "react";
import { PhoneFrame } from "./components/PhoneFrame";
import { SuggestScreen } from "./components/SuggestScreen";
import { HistoryScreen } from "./components/HistoryScreen";
import { SettingsScreen } from "./components/SettingsScreen";
import { SuggestSettingsScreen } from "./components/SuggestSettingsScreen";
import { WelcomeModalScreen } from "./components/WelcomeModalScreen";
import { CategoryScreen } from "./components/CategoryScreen";
import { NotificationPermissionScreen } from "./components/NotificationPermissionScreen";
import { NotificationCardScreen } from "./components/NotificationCardScreen";
import { CompletionModalScreen } from "./components/CompletionModalScreen";
import { EmptyHistoryScreen } from "./components/EmptyHistoryScreen";
import { THEMES, DesignThemeProvider } from "./theme";

const FONT = "'Noto Sans JP', 'Hiragino Sans', 'Yu Gothic', sans-serif";
const C = {
  bg: "#F2F4ED",
  text: "#1A1C18",
  muted: "#5D6358",
  primary: "#3F6F44",
  outline: "#DFE6D9",
  tagBg: "#EEF5E8",
  sectionBg: "rgba(255,255,255,0.5)",
};

/* ─── Layout helpers ─────────────────────────────── */

function SectionHeader({ index, title, sub }: { index: string; title: string; sub: string }) {
  return (
    <div style={{ marginBottom: "24px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "4px" }}>
        <span
          style={{
            fontSize: "11px",
            fontWeight: 700,
            color: C.primary,
            background: "#C2E8C0",
            borderRadius: "6px",
            padding: "2px 8px",
            fontFamily: FONT,
            letterSpacing: "0.04em",
          }}
        >
          {index}
        </span>
        <h2 style={{ fontSize: "17px", fontWeight: 800, color: C.text, margin: 0, fontFamily: FONT }}>
          {title}
        </h2>
      </div>
      <p style={{ fontSize: "12px", color: C.muted, margin: "0 0 0 0", fontFamily: FONT }}>{sub}</p>
    </div>
  );
}

function Section({ children }: { children: ReactNode }) {
  return (
    <section
      style={{
        background: C.sectionBg,
        borderRadius: "24px",
        border: `1px solid ${C.outline}`,
        padding: "28px 28px 32px",
        marginBottom: "24px",
      }}
    >
      {children}
    </section>
  );
}

function PhoneRow({ children }: { children: ReactNode }) {
  return (
    <div style={{ display: "flex", gap: "24px", flexWrap: "nowrap", overflowX: "auto", paddingBottom: "4px" }}>
      {children}
    </div>
  );
}

/* ─── Interactive phone that shares tab state ─────── */

function InteractivePhone({ label, initialTab }: { label: string; initialTab: number }) {
  const [tab, setTab] = useState(initialTab);
  const screens = [
    <SuggestScreen key="suggest" activeTab={tab} onTabChange={setTab} />,
    <HistoryScreen key="history" activeTab={tab} onTabChange={setTab} />,
    <SettingsScreen key="settings" activeTab={tab} onTabChange={setTab} />,
  ];
  return <PhoneFrame label={label}>{screens[tab]}</PhoneFrame>;
}

/* ─── デザイン案比較セクション (Issue #53) ────────── */

function DesignCompareSection() {
  const [themeId, setThemeId] = useState(THEMES[0].id);
  const selected = THEMES.find((t) => t.id === themeId) ?? THEMES[0];

  return (
    <Section>
      <SectionHeader
        index="★ — デザイン案比較"
        title="6つのデザインスタイルで見比べる（Issue #53）"
        sub="機能・画面フロー・文言は同一のまま、見た目のトークンだけを切り替え。チップでスタイルを選ぶと下の3画面に反映されます。"
      />

      {/* スタイル切替チップ */}
      <div style={{ display: "flex", flexWrap: "wrap", gap: "8px", marginBottom: "14px" }}>
        {THEMES.map((t) => {
          const active = t.id === themeId;
          return (
            <button
              key={t.id}
              onClick={() => setThemeId(t.id)}
              style={{
                display: "flex",
                flexDirection: "column",
                alignItems: "flex-start",
                gap: "1px",
                padding: "8px 14px",
                borderRadius: "14px",
                border: active ? `1.5px solid ${C.primary}` : `1px solid ${C.outline}`,
                background: active ? "#C2E8C0" : "#FFFFFF",
                cursor: "pointer",
                fontFamily: FONT,
              }}
            >
              <span style={{ fontSize: "13px", fontWeight: 700, color: active ? "#0B2A10" : C.text }}>
                {t.nameJa}
              </span>
              <span style={{ fontSize: "10px", color: C.muted }}>{t.nameEn}</span>
            </button>
          );
        })}
      </div>

      {/* 選択中スタイルの説明 */}
      <div
        style={{
          background: C.tagBg,
          borderRadius: "14px",
          padding: "12px 16px",
          marginBottom: "20px",
          maxWidth: "820px",
        }}
      >
        <p style={{ fontSize: "13px", fontWeight: 700, color: C.primary, margin: "0 0 4px", fontFamily: FONT }}>
          {selected.nameJa}（{selected.nameEn}）
        </p>
        <p style={{ fontSize: "12px", color: C.muted, margin: 0, lineHeight: 1.7, fontFamily: FONT }}>
          {selected.description}
        </p>
      </div>

      {/* 選択スタイルで主要3画面を操作 */}
      <DesignThemeProvider theme={selected}>
        <PhoneRow>
          <InteractivePhone label={`提案 — ${selected.nameJa}`} initialTab={0} />
          <InteractivePhone label={`履歴 — ${selected.nameJa}`} initialTab={1} />
          <InteractivePhone label={`設定 — ${selected.nameJa}`} initialTab={2} />
        </PhoneRow>
      </DesignThemeProvider>

      {/* 全案の横並び比較（提案画面） */}
      <p style={{ fontSize: "14px", fontWeight: 700, color: C.text, margin: "28px 0 12px", fontFamily: FONT }}>
        全6案ならべて比較（提案画面）
      </p>
      <PhoneRow>
        {THEMES.map((t) => (
          <DesignThemeProvider key={t.id} theme={t}>
            <PhoneFrame label={`${t.nameJa} / ${t.nameEn}`}>
              <SuggestScreen />
            </PhoneFrame>
          </DesignThemeProvider>
        ))}
      </PhoneRow>
    </Section>
  );
}

/* ─── Main App ───────────────────────────────────── */

export default function App() {
  return (
    <div style={{ minHeight: "100vh", background: C.bg, padding: "36px 40px 72px", fontFamily: FONT }}>

      {/* Page header */}
      <div style={{ marginBottom: "36px", display: "flex", alignItems: "flex-start", justifyContent: "space-between", flexWrap: "wrap", gap: "16px" }}>
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "8px" }}>
            <div style={{ width: "38px", height: "38px", borderRadius: "10px", background: C.primary, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <svg width="22" height="22" viewBox="0 0 22 22" fill="none">
                <path d="M11 2C11 2 5 8 5 13C5 16.31 7.69 19 11 19C14.31 19 17 16.31 17 13C17 8 11 2 11 2Z" fill="#C2E8C0" />
                <path d="M11 9C11 9 8.5 12 8.5 14C8.5 15.38 9.62 16.5 11 16.5C12.38 16.5 13.5 15.38 13.5 14C13.5 12 11 9 11 9Z" fill="white" />
              </svg>
            </div>
            <div>
              <h1 style={{ fontSize: "22px", fontWeight: 800, color: C.text, margin: 0 }}>よりみち日和</h1>
              <p style={{ fontSize: "12px", color: C.muted, margin: "1px 0 0" }}>Material 3風 UIプロトタイプ</p>
            </div>
          </div>
          <p style={{ fontSize: "13px", color: C.muted, margin: 0, lineHeight: 1.6, maxWidth: "600px" }}>
            提案画面はすぐ提案を受け取れる軽い設計。詳細条件は「提案設定」画面に分離。通知からの時間選択にも対応。
          </p>
        </div>
      </div>

      {/* ═══════════════════════════════════════════ */}
      {/* SECTION ★: デザイン案比較 (Issue #53)       */}
      {/* ═══════════════════════════════════════════ */}
      <DesignCompareSection />

      {/* ═══════════════════════════════════════════ */}
      {/* SECTION A: メインの3画面                   */}
      {/* ═══════════════════════════════════════════ */}
      <Section>
        <SectionHeader
          index="A — 既存の3画面"
          title="提案 / 履歴 / 設定"
          sub="提案画面に「現在の提案条件」カードを追加。設定画面に「提案設定」ListTileを追加。タブをクリックで切り替え可。"
        />
        <PhoneRow>
          <InteractivePhone label="01 提案（更新）" initialTab={0} />
          <InteractivePhone label="02 履歴" initialTab={1} />
          <InteractivePhone label="03 設定（更新）" initialTab={2} />
        </PhoneRow>
      </Section>

      {/* ═══════════════════════════════════════════ */}
      {/* SECTION B: 提案設定 + 通知連携             */}
      {/* ═══════════════════════════════════════════ */}
      <Section>
        <SectionHeader
          index="B — 提案設定 & 通知連携"
          title="提案設定 / 通知から30分選択後の提案画面"
          sub="「提案設定」は提案画面の条件設定ボタンまたは設定画面から遷移。通知で選んだ時間は一時条件として反映。"
        />
        <PhoneRow>
          <PhoneFrame label="04 提案設定（新規）">
            <SuggestSettingsScreen />
          </PhoneFrame>
          <PhoneFrame label="01' 提案（通知から30分選択後）">
            <SuggestScreen fromNotification={30} />
          </PhoneFrame>
        </PhoneRow>
      </Section>

      {/* ═══════════════════════════════════════════ */}
      {/* SECTION C: オンボーディング                */}
      {/* ═══════════════════════════════════════════ */}
      <Section>
        <SectionHeader
          index="C — オンボーディング"
          title="初回起動 / カテゴリ選択 / 通知許可"
          sub="初回のみ表示されるフロー。カテゴリ選択はFilterChip。通知許可はAlertDialog風。"
        />
        <PhoneRow>
          <PhoneFrame label="05 初回起動モーダル">
            <WelcomeModalScreen />
          </PhoneFrame>
          <PhoneFrame label="06 興味カテゴリ選択">
            <CategoryScreen />
          </PhoneFrame>
          <PhoneFrame label="07 通知許可モーダル">
            <NotificationPermissionScreen />
          </PhoneFrame>
        </PhoneRow>
      </Section>

      {/* ═══════════════════════════════════════════ */}
      {/* SECTION D: 補助UI                          */}
      {/* ═══════════════════════════════════════════ */}
      <Section>
        <SectionHeader
          index="D — 補助UI"
          title="通知カード例 / 提案完了モーダル / 履歴空状態"
          sub="通知バナーのデザイン例、完了後のChoiceChipフィードバック、履歴未記録時の空状態画面。"
        />
        <PhoneRow>
          <PhoneFrame label="08 通知カード例" statusBg="#D4E6CE">
            <NotificationCardScreen />
          </PhoneFrame>
          <PhoneFrame label="09 提案完了モーダル">
            <CompletionModalScreen />
          </PhoneFrame>
          <PhoneFrame label="10 履歴空状態">
            <EmptyHistoryScreen />
          </PhoneFrame>
        </PhoneRow>
      </Section>

      {/* Flutter Widget 対応表 */}
      <div
        style={{
          background: C.sectionBg,
          border: `1px solid ${C.outline}`,
          borderRadius: "20px",
          padding: "20px 24px",
        }}
      >
        <p style={{ fontSize: "13px", fontWeight: 700, color: C.primary, margin: "0 0 12px", fontFamily: FONT }}>
          Flutter Widget 対応表
        </p>
        <div style={{ display: "flex", flexWrap: "wrap", gap: "7px" }}>
          {[
            ["提案画面", "Scaffold + Column"],
            ["提案条件カード", "Card + Wrap"],
            ["提案設定遷移", "TextButton / Navigator.push"],
            ["提案設定画面", "Scaffold + AppBar"],
            ["時間選択", "FilterChip"],
            ["予算選択", "SegmentedButton / ChoiceChip"],
            ["移動距離", "RadioListTile"],
            ["カテゴリ選択", "FilterChip (multiple)"],
            ["保存ボタン", "FilledButton"],
            ["通知連携", "SharedPreferences + local_notifications"],
            ["NavigationBar", "NavigationBar + IndexedStack"],
            ["完了モーダル", "ModalBottomSheet"],
            ["通知許可", "AlertDialog"],
            ["設定画面", "ListView + Card + ListTile / SwitchListTile"],
          ].map(([screen, widget]) => (
            <div
              key={screen}
              style={{
                padding: "5px 12px",
                background: C.tagBg,
                borderRadius: "10px",
                display: "flex",
                gap: "6px",
                alignItems: "center",
              }}
            >
              <span style={{ fontSize: "11px", fontWeight: 700, color: C.primary, fontFamily: FONT }}>{screen}</span>
              <span style={{ fontSize: "11px", color: C.muted, fontFamily: FONT }}>→ {widget}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
