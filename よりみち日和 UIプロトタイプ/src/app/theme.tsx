import { createContext, useContext, ReactNode } from "react";

/* ─────────────────────────────────────────────────────
   デザイン案比較用テーマ定義（Issue #53）
   機能・文言は変えず、見た目のトークンだけを差し替える。
   material3 が現行デザインの値（デフォルト）。

   各スタイルは「標準版」（THEMES）と「誇張版」
   （EXAGGERATED_THEMES）の 2 段階を用意する。誇張版は
   スタイルの特徴を強く出した見本で、採用時は標準版〜
   誇張版の間で調整する想定。
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
    surfaceBlur?: string; // グラスモーフィズム等の backdropFilter
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

/* ══════════════ 標準版 ══════════════ */

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

/* ── 7. ニューブルータリズム ── */
const neubrutalism: DesignTheme = {
  id: "neubrutalism",
  nameJa: "ニューブルータリズム",
  nameEn: "Neubrutalism / Neo-brutalism",
  description:
    "太い黒枠・ベタ塗りの色面・ぼかさずに「ずらした」固い影が特徴。Figma や Gumroad などの Web サービスで流行中。元気で親しみやすく視認性も高いが、優しい・穏やかな印象は出しにくい。フォントは骨太な Zen Kaku Gothic Antique。",
  font: "'Zen Kaku Gothic Antique', 'Noto Sans JP', sans-serif",
  colors: {
    ...BASE_COLORS,
    bg: "#FFFBEA",
    screenBackground: "#FFFBEA",
    surfaceVariant: "#FDEFB2",
    primary: "#1F7A33",
    primaryContainer: "#A8F0A0",
    primaryDone: "#14522A",
    text: "#111111",
    muted: "#3D3D3D",
    tagText: "#111111",
    outline: "#111111",
    skipBg: "#FFD644",
    skipText: "#5C4A00",
    navBg: "#FFFFFF",
  },
  shape: {
    cardRadius: "10px",
    panelRadius: "12px",
    heroRadius: "12px",
    chipRadius: "8px",
    pillRadius: "6px",
    buttonRadius: "8px",
  },
  effects: {
    cardBorder: "2px solid #111111",
    cardShadow: "4px 4px 0 #111111",
    heroShadow: "5px 5px 0 #111111",
    chipShadow: "none",
    primaryBtnShadow: "3px 3px 0 #111111",
    secondaryBtnBorder: "2px solid #111111",
    secondaryBtnShadow: "3px 3px 0 #111111",
    navBorderTop: "2px solid #111111",
    navShadow: "none",
    pillActiveShadow: "2px 2px 0 #111111",
  },
};

/* ── 8. オーロラ UI ── */
const aurora: DesignTheme = {
  id: "aurora",
  nameJa: "オーロラ UI",
  nameEn: "Aurora UI / Gradient Mesh",
  description:
    "オーロラのような多色グラデーションのぼかしを背景に敷き、その上に柔らかい半透明の面を重ねる。夢見心地で幻想的な今風スタイル。手書き風フォント（Klee One）でやさしさを添える。落ち着いた「休憩」の世界観に合う可能性がある。",
  font: "'Klee One', 'Noto Sans JP', sans-serif",
  colors: {
    ...BASE_COLORS,
    bg: "#F0EDFB",
    screenBackground:
      "radial-gradient(circle at 20% 12%, rgba(196,181,253,0.5) 0%, transparent 45%), radial-gradient(circle at 85% 25%, rgba(167,243,208,0.55) 0%, transparent 50%), radial-gradient(circle at 70% 82%, rgba(251,207,232,0.45) 0%, transparent 50%), linear-gradient(170deg, #F4F1FF 0%, #ECFDF3 100%)",
    surface: "rgba(255,255,255,0.72)",
    surfaceVariant: "rgba(255,255,255,0.5)",
    primary: "#45815B",
    primaryContainer: "#C9F3DC",
    outline: "rgba(255,255,255,0.9)",
    navBg: "rgba(255,255,255,0.72)",
  },
  shape: { ...BASE_SHAPE, heroRadius: "32px" },
  effects: {
    cardBorder: "1px solid rgba(255,255,255,0.9)",
    cardShadow: "0 8px 28px rgba(140,120,220,0.18)",
    heroShadow: "0 14px 36px rgba(140,120,220,0.22)",
    chipShadow: "none",
    primaryBtnShadow: "0 6px 18px rgba(69,129,91,0.35)",
    secondaryBtnBorder: "1px solid rgba(255,255,255,0.9)",
    secondaryBtnShadow: "0 6px 16px rgba(140,120,220,0.15)",
    navBorderTop: "1px solid rgba(255,255,255,0.8)",
    navShadow: "0 -6px 20px rgba(140,120,220,0.15)",
    pillActiveShadow: "none",
    surfaceBlur: "blur(10px)",
  },
};

export const THEMES: DesignTheme[] = [
  material3,
  neumorphism,
  glassmorphism,
  flat,
  claymorphism,
  skeuomorphism,
  neubrutalism,
  aurora,
];

/* ══════════════ 誇張版 ══════════════
   各スタイルの特徴を強く出したバージョン。
   標準版との差分だけを上書きする。 */

const material3Ex: DesignTheme = {
  ...material3,
  colors: {
    ...material3.colors,
    bg: "#EDF6E6",
    screenBackground: "#EDF6E6",
    surface: "#FDFEF9",
    surfaceVariant: "#D8EDCF",
    primaryContainer: "#A9E8A6",
  },
  shape: {
    cardRadius: "28px",
    panelRadius: "32px",
    heroRadius: "36px",
    chipRadius: "20px",
    pillRadius: "16px",
    buttonRadius: "28px",
  },
  effects: {
    ...material3.effects,
    cardBorder: "none",
    cardShadow: "0 1px 3px rgba(40,60,40,0.15), 0 4px 12px rgba(40,60,40,0.10)",
    heroShadow: "0 2px 6px rgba(40,60,40,0.16), 0 8px 24px rgba(40,60,40,0.12)",
    primaryBtnShadow: "0 2px 8px rgba(63,111,68,0.4)",
    navBorderTop: "none",
    navShadow: "0 -1px 3px rgba(40,60,40,0.12), 0 -4px 12px rgba(40,60,40,0.08)",
  },
};

const neumorphismEx: DesignTheme = {
  ...neumorphism,
  shape: {
    cardRadius: "32px",
    panelRadius: "36px",
    heroRadius: "40px",
    chipRadius: "18px",
    pillRadius: "14px",
    buttonRadius: "28px",
  },
  effects: {
    ...neumorphism.effects,
    cardShadow:
      "9px 9px 24px rgba(130,165,125,0.55), -9px -9px 24px rgba(255,255,255,0.95)",
    heroShadow:
      "12px 12px 28px rgba(130,165,125,0.6), -12px -12px 28px rgba(255,255,255,0.98)",
    chipShadow:
      "inset 4px 4px 9px rgba(140,170,134,0.45), inset -4px -4px 9px rgba(255,255,255,0.9)",
    primaryBtnShadow:
      "6px 6px 14px rgba(40,80,40,0.4), -4px -4px 12px rgba(255,255,255,0.6)",
    secondaryBtnShadow:
      "6px 6px 14px rgba(130,165,125,0.5), -6px -6px 14px rgba(255,255,255,0.95)",
    navShadow: "0 -8px 20px rgba(130,165,125,0.35)",
    pillActiveShadow:
      "inset 4px 4px 9px rgba(80,120,80,0.4), inset -4px -4px 9px rgba(215,250,215,0.9)",
  },
};

const glassmorphismEx: DesignTheme = {
  ...glassmorphism,
  colors: {
    ...glassmorphism.colors,
    bg: "#CBE8D9",
    screenBackground:
      "linear-gradient(140deg, #B7E4C7 0%, #E0C3FC 35%, #A0E7E5 70%, #FFCFD2 100%)",
    surface: "rgba(255,255,255,0.35)",
    surfaceVariant: "rgba(255,255,255,0.28)",
    outline: "rgba(255,255,255,0.9)",
    navBg: "rgba(255,255,255,0.4)",
  },
  effects: {
    ...glassmorphism.effects,
    cardBorder: "1.5px solid rgba(255,255,255,0.85)",
    cardShadow: "0 12px 36px rgba(80,80,140,0.22)",
    heroShadow: "0 16px 44px rgba(80,80,140,0.28)",
    primaryBtnShadow: "0 6px 20px rgba(63,111,68,0.45)",
    surfaceBlur: "blur(22px) saturate(160%)",
    navShadow: "0 -8px 24px rgba(80,80,140,0.18)",
  },
};

const flatEx: DesignTheme = {
  ...flat,
  colors: {
    ...flat.colors,
    bg: "#FFFFFF",
    screenBackground: "#FFFFFF",
    primary: "#1B5E20",
    primaryContainer: "#7BE382",
    surfaceVariant: "#EAF7E0",
    text: "#101010",
    outline: "#101010",
    navBg: "#FFFFFF",
  },
  shape: {
    cardRadius: "0px",
    panelRadius: "0px",
    heroRadius: "0px",
    chipRadius: "0px",
    pillRadius: "0px",
    buttonRadius: "0px",
  },
  effects: {
    ...flat.effects,
    cardBorder: "2px solid #101010",
    secondaryBtnBorder: "2px solid #101010",
    navBorderTop: "2px solid #101010",
  },
};

const claymorphismEx: DesignTheme = {
  ...claymorphism,
  colors: {
    ...claymorphism.colors,
    bg: "#E7F6FF",
    screenBackground: "#E7F6FF",
    primary: "#59A96A",
    primaryContainer: "#FFD9E8",
    primaryDark: "#8A3D5C",
    surfaceVariant: "#FFF4C9",
    tagText: "#8A7325",
    navBg: "#FFFFFF",
  },
  shape: {
    cardRadius: "36px",
    panelRadius: "40px",
    heroRadius: "44px",
    chipRadius: "22px",
    pillRadius: "18px",
    buttonRadius: "32px",
  },
  effects: {
    ...claymorphism.effects,
    cardShadow:
      "0 18px 30px rgba(120,160,180,0.3), inset 8px 8px 16px rgba(255,255,255,0.95), inset -8px -8px 16px rgba(150,180,200,0.25)",
    heroShadow:
      "0 24px 40px rgba(120,160,180,0.35), inset 10px 10px 20px rgba(255,255,255,0.95), inset -10px -10px 20px rgba(150,180,200,0.28)",
    chipShadow:
      "inset 4px 4px 8px rgba(255,255,255,0.95), inset -4px -4px 8px rgba(190,170,110,0.3)",
    primaryBtnShadow:
      "0 12px 22px rgba(60,110,70,0.4), inset 4px 4px 8px rgba(255,255,255,0.45), inset -4px -4px 8px rgba(20,60,30,0.3)",
    secondaryBtnShadow:
      "0 12px 22px rgba(120,160,180,0.3), inset 4px 4px 8px rgba(255,255,255,0.95), inset -4px -4px 8px rgba(150,180,200,0.25)",
    navShadow: "0 -12px 26px rgba(120,160,180,0.22)",
  },
};

const skeuomorphismEx: DesignTheme = {
  ...skeuomorphism,
  colors: {
    ...skeuomorphism.colors,
    bg: "#EFE6CC",
    /* 罫線入りのノート用紙風テクスチャ */
    screenBackground:
      "repeating-linear-gradient(0deg, rgba(160,140,95,0.10) 0px, rgba(160,140,95,0.10) 1px, transparent 1px, transparent 26px), linear-gradient(180deg, #F5EEDA 0%, #EBE1C4 100%)",
    surface: "linear-gradient(180deg, #FFFEF6 0%, #F1E9D2 100%)",
    navBg: "linear-gradient(180deg, #F6EFDC 0%, #E5D9B8 100%)",
  },
  effects: {
    ...skeuomorphism.effects,
    /* 手帳の縫い目（ステッチ）風の破線ボーダー */
    cardBorder: "2px dashed #B8A374",
    cardShadow:
      "0 3px 7px rgba(90,75,40,0.35), inset 0 1px 0 rgba(255,255,255,0.9), inset 0 -2px 3px rgba(140,115,60,0.2)",
    heroShadow:
      "0 5px 12px rgba(90,75,40,0.4), inset 0 2px 0 rgba(255,255,255,0.9), inset 0 -3px 5px rgba(140,115,60,0.25)",
    chipShadow: "inset 0 2px 3px rgba(90,75,40,0.3)",
    primaryBtnShadow:
      "0 4px 8px rgba(60,50,20,0.5), inset 0 2px 0 rgba(255,255,255,0.5), inset 0 -3px 5px rgba(20,40,15,0.45)",
    secondaryBtnBorder: "2px dashed #B8A374",
    secondaryBtnShadow:
      "0 3px 6px rgba(90,75,40,0.3), inset 0 1px 0 rgba(255,255,255,0.9)",
    navBorderTop: "2px solid #B8A374",
    navShadow: "0 -3px 8px rgba(90,75,40,0.25)",
    pillActiveShadow: "inset 0 3px 5px rgba(60,80,40,0.4)",
  },
};

const neubrutalismEx: DesignTheme = {
  ...neubrutalism,
  font: "'Mochiy Pop One', 'Zen Kaku Gothic Antique', sans-serif",
  colors: {
    ...neubrutalism.colors,
    bg: "#FFE94A",
    screenBackground: "#FFE94A",
    surfaceVariant: "#FFB3E2",
    primaryContainer: "#7CF29C",
    skipBg: "#7DD8FF",
    skipText: "#0A3C5C",
  },
  shape: {
    cardRadius: "4px",
    panelRadius: "4px",
    heroRadius: "4px",
    chipRadius: "2px",
    pillRadius: "2px",
    buttonRadius: "4px",
  },
  effects: {
    ...neubrutalism.effects,
    cardBorder: "3px solid #111111",
    cardShadow: "8px 8px 0 #111111",
    heroShadow: "10px 10px 0 #111111",
    primaryBtnShadow: "5px 5px 0 #111111",
    secondaryBtnBorder: "3px solid #111111",
    secondaryBtnShadow: "5px 5px 0 #111111",
    navBorderTop: "3px solid #111111",
    pillActiveShadow: "3px 3px 0 #111111",
  },
};

const auroraEx: DesignTheme = {
  ...aurora,
  colors: {
    ...aurora.colors,
    bg: "#E8DFFA",
    screenBackground:
      "radial-gradient(circle at 15% 10%, rgba(167,139,250,0.75) 0%, transparent 42%), radial-gradient(circle at 88% 20%, rgba(94,234,212,0.7) 0%, transparent 45%), radial-gradient(circle at 75% 85%, rgba(249,168,212,0.7) 0%, transparent 48%), radial-gradient(circle at 15% 80%, rgba(147,197,253,0.65) 0%, transparent 45%), linear-gradient(170deg, #EDE9FE 0%, #D1FAE5 100%)",
    surface: "rgba(255,255,255,0.55)",
    surfaceVariant: "rgba(255,255,255,0.38)",
    navBg: "rgba(255,255,255,0.55)",
  },
  effects: {
    ...aurora.effects,
    cardBorder: "1.5px solid rgba(255,255,255,0.95)",
    cardShadow: "0 12px 40px rgba(150,110,255,0.3)",
    heroShadow: "0 18px 50px rgba(150,110,255,0.38)",
    primaryBtnShadow: "0 0 22px rgba(90,170,120,0.6), 0 6px 18px rgba(69,129,91,0.35)",
    surfaceBlur: "blur(18px)",
    navShadow: "0 -10px 30px rgba(150,110,255,0.25)",
  },
};

export const EXAGGERATED_THEMES: DesignTheme[] = [
  material3Ex,
  neumorphismEx,
  glassmorphismEx,
  flatEx,
  claymorphismEx,
  skeuomorphismEx,
  neubrutalismEx,
  auroraEx,
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
