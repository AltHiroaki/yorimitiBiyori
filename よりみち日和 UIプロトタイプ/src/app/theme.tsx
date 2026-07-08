import { createContext, useContext, ReactNode } from "react";

/* ─────────────────────────────────────────────────────
   デザイン案比較用テーマ定義（Issue #53）
   機能・文言は変えず、見た目のトークンだけを差し替える。
   material3 が現行デザインの値（デフォルト）。
───────────────────────────────────────────────────── */

export interface DesignTheme {
  id: string;
  nameJa: string;
  nameEn: string;
  description: string;
  font: string; // 画面内テキストの fontFamily
  colors: {
    bg: string;               // 画面のベース色（PhoneFrame・ステータスバー）
    screenBackground: string; // 画面の background（単色 or グラデーション）
    surface: string;
    surfaceVariant: string;
    primary: string;
    primaryContainer: string;
    primaryDark: string;
    primaryDone: string;      // 「やった！」押下後のボタン色
    text: string;
    muted: string;
    tagText: string;
    outline: string;
    danger: string;
    skipBg: string;
    skipText: string;
    navBg: string;
  };
  shape: {
    cardRadius: string;   // 通常カード（条件カード・履歴アイテムなど）
    panelRadius: string;  // 大きめパネル（設定リスト・履歴サマリー）
    heroRadius: string;   // 提案のメインカード
    chipRadius: string;   // タグ
    pillRadius: string;   // 条件ピル・バッジ
    buttonRadius: string; // アクションボタン
  };
  effects: {
    cardBorder: string;
    cardShadow: string;
    heroShadow: string;
    chipShadow: string;
    primaryBtnShadow: string;
    secondaryBtnBorder: string;
    secondaryBtnShadow: string;
    navBorderTop: string;
    navShadow: string;
    pillActiveShadow: string;
    surfaceBlur?: string; // グラスモーフィズム用 backdropFilter
  };
}

/* 共通のブランドカラー（現行 Material 3 パレット） */
const BASE_COLORS = {
  bg: "#F8FBF3",
  screenBackground: "#F8FBF3",
  surface: "#FFFFFF",
  surfaceVariant: "#EEF5E8",
  primary: "#3F6F44",
  primaryContainer: "#C2E8C0",
  primaryDark: "#0B2A10",
  primaryDone: "#2a5230",
  text: "#1A1C18",
  muted: "#5D6358",
  tagText: "#596E57",
  outline: "#DFE6D9",
  danger: "#BA1A1A",
  skipBg: "#F2E8A2",
  skipText: "#7B6F00",
  navBg: "#FFFFFF",
};

const BASE_SHAPE = {
  cardRadius: "20px",
  panelRadius: "24px",
  heroRadius: "28px",
  chipRadius: "14px",
  pillRadius: "10px",
  buttonRadius: "24px",
};

const NO_EFFECTS = {
  cardBorder: "1px solid #DFE6D9",
  cardShadow: "none",
  heroShadow: "none",
  chipShadow: "none",
  primaryBtnShadow: "none",
  secondaryBtnBorder: "1.5px solid #DFE6D9",
  secondaryBtnShadow: "none",
  navBorderTop: "1px solid #DFE6D9",
  navShadow: "none",
  pillActiveShadow: "none",
};

/* ── 1. Material Design 3（現行） ── */
const material3: DesignTheme = {
  id: "material3",
  nameJa: "マテリアルデザイン 3",
  nameEn: "Material Design 3 / Material You",
  description:
    "Google 公式のデザインシステム。トーナルカラーと大きめの角丸、控えめな境界線で構成。Flutter 標準（useMaterial3）と親和性が最も高く、実装コストが最小。現行デザインはこれをベースにしている。フォントは標準的な Noto Sans JP。",
  font: "'Noto Sans JP', sans-serif",
  colors: { ...BASE_COLORS },
  shape: { ...BASE_SHAPE },
  effects: { ...NO_EFFECTS },
};

/* ── 2. ニューモーフィズム（ユーザー試作の影値を移植） ── */
const neumorphism: DesignTheme = {
  id: "neumorphism",
  nameJa: "ニューモーフィズム",
  nameEn: "Neumorphism",
  description:
    "背景と同色の面に、左上の光と右下の影の 2 方向シャドウで凹凸を表現する。柔らかく触りたくなる質感が特徴。フォントも丸ゴシック（Zen Maru Gothic）で柔らかさを揃える。コントラストが低くなりやすく、アクセシビリティには注意が必要。",
  font: "'Zen Maru Gothic', 'Noto Sans JP', sans-serif",
  colors: {
    ...BASE_COLORS,
    surface: "#F8FBF3", // 背景と同色にすることでニューモーフィズムが成立する
    navBg: "#F8FBF3",
  },
  shape: { ...BASE_SHAPE, cardRadius: "24px", heroRadius: "32px" },
  effects: {
    cardBorder: "none",
    cardShadow:
      "5px 5px 14px rgba(140,170,134,0.42), -5px -5px 14px rgba(255,255,255,0.85)",
    heroShadow:
      "5px 5px 14px rgba(140,170,134,0.42), -5px -5px 14px rgba(255,255,255,0.85)",
    chipShadow:
      "inset 2px 2px 6px rgba(140,170,134,0.30), inset -2px -2px 6px rgba(255,255,255,0.80)",
    primaryBtnShadow: "0 3px 10px rgba(40,80,40,0.35), 0 1px 4px rgba(40,80,40,0.2)",
    secondaryBtnBorder: "none",
    secondaryBtnShadow:
      "3px 3px 9px rgba(140,170,134,0.38), -3px -3px 9px rgba(255,255,255,0.85)",
    navBorderTop: "none",
    navShadow: "0 -4px 12px rgba(140,170,134,0.2), 0 -1px 4px rgba(140,170,134,0.12)",
    pillActiveShadow:
      "inset 2px 2px 6px rgba(80,120,80,0.28), inset -2px -2px 6px rgba(215,250,215,0.82)",
  },
};

/* ── 3. グラスモーフィズム ── */
const glassmorphism: DesignTheme = {
  id: "glassmorphism",
  nameJa: "グラスモーフィズム",
  nameEn: "Glassmorphism",
  description:
    "すりガラスのような半透明レイヤーと背景ぼかしで奥行きを出す。iOS や Windows 11 で採用されている今風のスタイル。フォントはすっきりした Zen Kaku Gothic New。背景にグラデーションや写真があると映える。",
  font: "'Zen Kaku Gothic New', 'Noto Sans JP', sans-serif",
  colors: {
    ...BASE_COLORS,
    bg: "#DFF2E4",
    screenBackground:
      "linear-gradient(160deg, #D3EEDC 0%, #F3F9EC 42%, #CBE9D6 78%, #B9E2CD 100%)",
    surface: "rgba(255,255,255,0.55)",
    surfaceVariant: "rgba(255,255,255,0.45)",
    navBg: "rgba(255,255,255,0.55)",
  },
  shape: { ...BASE_SHAPE },
  effects: {
    cardBorder: "1px solid rgba(255,255,255,0.65)",
    cardShadow: "0 8px 24px rgba(60,100,70,0.14)",
    heroShadow: "0 12px 32px rgba(60,100,70,0.18)",
    chipShadow: "none",
    primaryBtnShadow: "0 4px 14px rgba(63,111,68,0.35)",
    secondaryBtnBorder: "1px solid rgba(255,255,255,0.75)",
    secondaryBtnShadow: "0 4px 12px rgba(60,100,70,0.12)",
    navBorderTop: "1px solid rgba(255,255,255,0.6)",
    navShadow: "0 -6px 18px rgba(60,100,70,0.10)",
    pillActiveShadow: "none",
    surfaceBlur: "blur(14px)",
  },
};

/* ── 4. フラットデザイン / ミニマル ── */
const flat: DesignTheme = {
  id: "flat",
  nameJa: "フラットデザイン / ミニマル",
  nameEn: "Flat Design 2.0",
  description:
    "影や質感の装飾を排し、余白・タイポグラフィ・はっきりした線と色面だけで情報を主役にする。フォントは硬質で機能的な IBM Plex Sans JP。読みやすく軽いが、単調に見えないよう配色にメリハリが要る。",
  font: "'IBM Plex Sans JP', 'Noto Sans JP', sans-serif",
  colors: {
    ...BASE_COLORS,
    bg: "#FCFDFA",
    screenBackground: "#FCFDFA",
    surfaceVariant: "#E9F2E2",
    outline: "#1A1C18",
    navBg: "#FCFDFA",
  },
  shape: {
    cardRadius: "8px",
    panelRadius: "8px",
    heroRadius: "10px",
    chipRadius: "4px",
    pillRadius: "4px",
    buttonRadius: "6px",
  },
  effects: {
    ...NO_EFFECTS,
    cardBorder: "1.5px solid #1A1C18",
    secondaryBtnBorder: "1.5px solid #1A1C18",
    navBorderTop: "1.5px solid #1A1C18",
  },
};

/* ── 5. クレイモーフィズム ── */
const claymorphism: DesignTheme = {
  id: "claymorphism",
  nameJa: "クレイモーフィズム",
  nameEn: "Claymorphism",
  description:
    "粘土のようにぷっくりした立体感。太い角丸に、外側の落ち影と内側のハイライト・シェードを重ねる。フォントも丸文字（M PLUS Rounded 1c）で統一。パステル配色と相性が良く、かわいい・癒し系の世界観に合う。",
  font: "'M PLUS Rounded 1c', 'Noto Sans JP', sans-serif",
  colors: {
    ...BASE_COLORS,
    bg: "#EAF6E7",
    screenBackground: "#EAF6E7",
    primary: "#4C8A54",
    primaryContainer: "#CBEFC6",
    surfaceVariant: "#E3F3DD",
    navBg: "#FFFFFF",
  },
  shape: {
    cardRadius: "28px",
    panelRadius: "32px",
    heroRadius: "36px",
    chipRadius: "18px",
    pillRadius: "14px",
    buttonRadius: "26px",
  },
  effects: {
    cardBorder: "none",
    cardShadow:
      "0 12px 24px rgba(110,160,110,0.22), inset 6px 6px 12px rgba(255,255,255,0.9), inset -6px -6px 12px rgba(120,170,120,0.16)",
    heroShadow:
      "0 16px 32px rgba(110,160,110,0.26), inset 8px 8px 16px rgba(255,255,255,0.9), inset -8px -8px 16px rgba(120,170,120,0.18)",
    chipShadow:
      "inset 3px 3px 6px rgba(255,255,255,0.9), inset -3px -3px 6px rgba(120,170,120,0.16)",
    primaryBtnShadow:
      "0 8px 16px rgba(60,110,70,0.35), inset 3px 3px 6px rgba(255,255,255,0.35), inset -3px -3px 6px rgba(20,60,30,0.25)",
    secondaryBtnBorder: "none",
    secondaryBtnShadow:
      "0 8px 16px rgba(110,160,110,0.22), inset 3px 3px 6px rgba(255,255,255,0.9), inset -3px -3px 6px rgba(120,170,120,0.16)",
    navBorderTop: "none",
    navShadow: "0 -8px 20px rgba(110,160,110,0.16)",
    pillActiveShadow:
      "inset 3px 3px 6px rgba(120,170,120,0.25), inset -3px -3px 6px rgba(255,255,255,0.9)",
  },
};

/* ── 6. スキューモーフィズム ── */
const skeuomorphism: DesignTheme = {
  id: "skeuomorphism",
  nameJa: "スキューモーフィズム",
  nameEn: "Skeuomorphism",
  description:
    "紙や革など実物の質感を模す古典的スタイル。グラデーションと立体的なボタン、明朝体（Shippori Mincho）で「手帳・スタンプ帳」のような演出ができる。作り込みの工数は最も大きい（参考枠）。",
  font: "'Shippori Mincho', 'Noto Serif JP', serif",
  colors: {
    ...BASE_COLORS,
    bg: "#F1EBDB",
    screenBackground:
      "linear-gradient(180deg, #F5F0E2 0%, #EFE8D4 60%, #EAE2CA 100%)",
    surface: "linear-gradient(180deg, #FFFEF8 0%, #F6F0DF 100%)",
    surfaceVariant: "#EDE5CE",
    primary: "#4A6B3F",
    primaryContainer: "#D8E4C2",
    primaryDark: "#2C4023",
    text: "#33301F",
    muted: "#6E6650",
    tagText: "#5C6647",
    outline: "#C9BFA5",
    navBg: "linear-gradient(180deg, #FBF7EA 0%, #EFE8D4 100%)",
  },
  shape: {
    cardRadius: "12px",
    panelRadius: "14px",
    heroRadius: "14px",
    chipRadius: "8px",
    pillRadius: "6px",
    buttonRadius: "10px",
  },
  effects: {
    cardBorder: "1px solid #C9BFA5",
    cardShadow: "0 2px 5px rgba(90,75,40,0.28), inset 0 1px 0 rgba(255,255,255,0.8)",
    heroShadow: "0 3px 8px rgba(90,75,40,0.32), inset 0 1px 0 rgba(255,255,255,0.8)",
    chipShadow: "inset 0 1px 2px rgba(90,75,40,0.22)",
    primaryBtnShadow:
      "0 3px 6px rgba(60,50,20,0.4), inset 0 1px 0 rgba(255,255,255,0.4), inset 0 -2px 3px rgba(20,40,15,0.35)",
    secondaryBtnBorder: "1px solid #C9BFA5",
    secondaryBtnShadow:
      "0 2px 4px rgba(90,75,40,0.25), inset 0 1px 0 rgba(255,255,255,0.85)",
    navBorderTop: "1px solid #C9BFA5",
    navShadow: "0 -2px 6px rgba(90,75,40,0.18)",
    pillActiveShadow: "inset 0 2px 4px rgba(60,80,40,0.3)",
  },
};

export const THEMES: DesignTheme[] = [
  material3,
  neumorphism,
  glassmorphism,
  flat,
  claymorphism,
  skeuomorphism,
];

export const DEFAULT_THEME = material3;

/* ── Context ──
   Provider の外では現行（material3）が返るため、
   テーマ未対応のセクション・画面の見た目は変わらない。 */
const ThemeContext = createContext<DesignTheme>(DEFAULT_THEME);

export function DesignThemeProvider({ theme, children }: { theme: DesignTheme; children: ReactNode }) {
  return <ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>;
}

export function useDesignTheme(): DesignTheme {
  return useContext(ThemeContext);
}
