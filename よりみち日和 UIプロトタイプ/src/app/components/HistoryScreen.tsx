import { NavigationBar } from "./NavigationBar";
import { useDesignTheme } from "../theme";

interface HistoryItem {
  id: number;
  title: string;
  date: string;
  tag: string;
  duration: string;
  done: boolean;
}

const historyItems: HistoryItem[] = [
  { id: 1, title: "近くを15分だけ散歩する", date: "6月5日", tag: "気分転換", duration: "15分", done: true },
  { id: 2, title: "普段聴かない音楽を1曲聴く", date: "6月4日", tag: "音楽", duration: "5分", done: false },
  { id: 3, title: "気になるテーマを少し調べる", date: "6月3日", tag: "学習", duration: "30分", done: true },
  { id: 4, title: "短い記事を1本読む", date: "6月2日", tag: "読書", duration: "15分", done: true },
];

interface HistoryScreenProps {
  activeTab?: number;
  onTabChange?: (tab: number) => void;
}

export function HistoryScreen({ activeTab = 1, onTabChange }: HistoryScreenProps) {
  const { colors: C, shape: SH, effects: E, font: F } = useDesignTheme();
  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", background: C.screenBackground, overflowY: "auto" }}>
      <div style={{ flex: 1, padding: "24px 24px 16px" }}>
        {/* Title */}
        <div style={{ marginBottom: "20px" }}>
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
            履歴
          </h1>
          <p
            style={{
              fontSize: "14px",
              color: C.muted,
              margin: "6px 0 0",
              lineHeight: 1.5,
              fontFamily: F,
            }}
          >
            実施したよりみちと、スキップした提案を確認します。
          </p>
        </div>

        {/* Summary card */}
        <div
          style={{
            background: C.surface,
            borderRadius: SH.panelRadius,
            border: E.cardBorder,
            boxShadow: E.cardShadow,
            backdropFilter: E.surfaceBlur,
            padding: "20px",
            marginBottom: "24px",
            display: "flex",
            alignItems: "center",
          }}
        >
          {/* 実施 */}
          <div style={{ flex: 1, textAlign: "center" }}>
            <p
              style={{
                fontSize: "32px",
                fontWeight: 800,
                color: C.primary,
                margin: 0,
                fontFamily: F,
              }}
            >
              8
            </p>
            <p
              style={{
                fontSize: "12px",
                color: C.muted,
                margin: "4px 0 0",
                fontFamily: F,
              }}
            >
              実施
            </p>
          </div>

          <div style={{ width: "1px", height: "48px", background: C.outline }} />

          {/* スキップ */}
          <div style={{ flex: 1, textAlign: "center" }}>
            <p
              style={{
                fontSize: "32px",
                fontWeight: 800,
                color: C.skipText,
                margin: 0,
                fontFamily: F,
              }}
            >
              3
            </p>
            <p
              style={{
                fontSize: "12px",
                color: C.muted,
                margin: "4px 0 0",
                fontFamily: F,
              }}
            >
              スキップ
            </p>
          </div>

          <div style={{ width: "1px", height: "48px", background: C.outline }} />

          {/* 合計時間 */}
          <div style={{ flex: 1, textAlign: "center" }}>
            <p
              style={{
                fontSize: "32px",
                fontWeight: 800,
                color: C.text,
                margin: 0,
                fontFamily: F,
              }}
            >
              120
            </p>
            <p
              style={{
                fontSize: "12px",
                color: C.muted,
                margin: "4px 0 0",
                fontFamily: F,
              }}
            >
              分
            </p>
          </div>
        </div>

        {/* History list */}
        <p
          style={{
            fontSize: "17px",
            fontWeight: 700,
            color: C.text,
            margin: "0 0 12px",
            fontFamily: F,
          }}
        >
          最近の履歴
        </p>

        <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
          {historyItems.map((item) => (
            <div
              key={item.id}
              style={{
                background: C.surface,
                borderRadius: SH.cardRadius,
                border: E.cardBorder,
                boxShadow: E.cardShadow,
                backdropFilter: E.surfaceBlur,
                padding: "16px",
                display: "flex",
                alignItems: "center",
                gap: "14px",
              }}
            >
              {/* Status icon */}
              <div
                style={{
                  width: "40px",
                  height: "40px",
                  borderRadius: "20px",
                  background: item.done ? C.primaryContainer : C.skipBg,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  flexShrink: 0,
                }}
              >
                {item.done ? (
                  <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                    <path d="M3.5 9L7.5 13L14.5 5" stroke={C.primary} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                ) : (
                  <span
                    style={{
                      fontSize: "18px",
                      fontWeight: 800,
                      color: C.skipText,
                      lineHeight: 1,
                    }}
                  >
                    −
                  </span>
                )}
              </div>

              {/* Content */}
              <div style={{ flex: 1, minWidth: 0 }}>
                <p
                  style={{
                    fontSize: "15px",
                    fontWeight: 700,
                    color: C.text,
                    margin: 0,
                    fontFamily: F,
                    overflow: "hidden",
                    textOverflow: "ellipsis",
                    whiteSpace: "nowrap",
                  }}
                >
                  {item.title}
                </p>
                <p
                  style={{
                    fontSize: "13px",
                    color: C.muted,
                    margin: "4px 0 0",
                    fontFamily: F,
                  }}
                >
                  {item.date}　{item.tag}・{item.duration}
                </p>
              </div>

              {/* Badge */}
              <span
                style={{
                  fontSize: "12px",
                  fontWeight: 600,
                  color: item.done ? C.primary : C.skipText,
                  background: item.done ? C.primaryContainer : C.skipBg,
                  padding: "4px 10px",
                  borderRadius: SH.pillRadius,
                  flexShrink: 0,
                  fontFamily: F,
                }}
              >
                {item.done ? "実施" : "スキップ"}
              </span>
            </div>
          ))}
        </div>
      </div>

      <NavigationBar activeTab={activeTab} onTabChange={onTabChange} />
    </div>
  );
}
