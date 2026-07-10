import { ReactNode } from "react";
import { useDesignTheme } from "../../theme";
import { ReviveSuggestion } from "./reviveMockData";

/* ─────────────────────────────────────────────────────
   Issue #46 スキップ復活フロー用モーダル 3 種
   PhoneFrame のコンテンツ領域（position: relative）に
   absolute で重ねる。NavigationBar（zIndex: 1）ごと
   スクリムで覆い、実機のダイアログ相当の見た目にする。
───────────────────────────────────────────────────── */

function ModalOverlay({ onClose, children }: { onClose: () => void; children: ReactNode }) {
  return (
    <div
      onClick={onClose}
      style={{
        position: "absolute",
        inset: 0,
        background: "rgba(26,28,24,0.4)",
        zIndex: 10,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "24px",
      }}
    >
      <div onClick={(e) => e.stopPropagation()} style={{ width: "100%" }}>
        {children}
      </div>
    </div>
  );
}

function ModalCard({ children }: { children: ReactNode }) {
  const { colors: C, shape: SH, effects: E } = useDesignTheme();
  return (
    <div
      style={{
        background: C.surface,
        borderRadius: SH.heroRadius,
        border: E.cardBorder,
        boxShadow: E.heroShadow,
        padding: "20px",
      }}
    >
      {children}
    </div>
  );
}

/* ── 提案詳細モーダル（やってみるボタンのみ） ── */

interface SuggestionDetailModalProps {
  suggestion: ReviveSuggestion;
  onTry: () => void;
  onClose: () => void;
}

export function SuggestionDetailModal({ suggestion, onTry, onClose }: SuggestionDetailModalProps) {
  const { colors: C, shape: SH, effects: E, font: F } = useDesignTheme();
  return (
    <ModalOverlay onClose={onClose}>
      <ModalCard>
        {/* Header */}
        <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "14px" }}>
          <div
            style={{
              width: "40px",
              height: "40px",
              borderRadius: "20px",
              background: C.primaryContainer,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              flexShrink: 0,
            }}
          >
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <path d="M10 2C10 2 5 7 5 11C5 13.76 7.24 16 10 16C12.76 16 15 13.76 15 11C15 7 10 2 10 2Z" fill={C.primary} />
              <path d="M10 9C9.45 9 9 9.45 9 10C9 10.55 9.45 11 10 11C10.55 11 11 10.55 11 10C11 9.45 10.55 9 10 9Z" fill="white" />
            </svg>
          </div>
          <div style={{ flex: 1 }}>
            <p style={{ fontSize: "13px", fontWeight: 700, color: C.primary, margin: 0, fontFamily: F }}>
              スキップした提案
            </p>
            <p style={{ fontSize: "12px", color: C.muted, margin: "2px 0 0", fontFamily: F }}>
              {suggestion.time}でできる
            </p>
          </div>
          <button
            onClick={onClose}
            aria-label="閉じる"
            style={{
              background: "none",
              border: "none",
              fontSize: "18px",
              fontWeight: 700,
              color: C.muted,
              cursor: "pointer",
              padding: "4px",
              lineHeight: 1,
              fontFamily: F,
            }}
          >
            ✕
          </button>
        </div>

        {/* Title */}
        <h2
          style={{
            fontSize: "22px",
            fontWeight: 800,
            color: C.text,
            margin: "0 0 10px",
            lineHeight: 1.35,
            fontFamily: F,
          }}
        >
          {suggestion.title}
          {suggestion.titleLine2 && (
            <>
              <br />
              {suggestion.titleLine2}
            </>
          )}
        </h2>

        <p style={{ fontSize: "13px", color: C.muted, margin: "0 0 14px", lineHeight: 1.65, fontFamily: F }}>
          {suggestion.body}
        </p>

        {/* Tags */}
        <div style={{ display: "flex", gap: "8px", marginBottom: "18px", flexWrap: "wrap" }}>
          {[...suggestion.tags, suggestion.time].map((tag) => (
            <span
              key={tag}
              style={{
                padding: "5px 14px",
                background: C.surfaceVariant,
                borderRadius: SH.chipRadius,
                boxShadow: E.chipShadow,
                fontSize: "12px",
                fontWeight: 500,
                color: C.tagText,
                fontFamily: F,
              }}
            >
              {tag}
            </span>
          ))}
        </div>

        {/* やってみるボタンのみ（「別の提案」なし） */}
        <button
          onClick={onTry}
          style={{
            width: "100%",
            height: "48px",
            borderRadius: SH.buttonRadius,
            background: C.primary,
            boxShadow: E.primaryBtnShadow,
            border: "none",
            fontSize: "15px",
            fontWeight: 700,
            color: "#FFFFFF",
            cursor: "pointer",
            fontFamily: F,
          }}
        >
          やってみる
        </button>
      </ModalCard>
    </ModalOverlay>
  );
}

/* ── 確認ミニモーダル ── */

interface ReviveConfirmModalProps {
  suggestion: ReviveSuggestion;
  hasActiveSuggestion: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

export function ReviveConfirmModal({ suggestion, hasActiveSuggestion, onConfirm, onCancel }: ReviveConfirmModalProps) {
  const { colors: C, shape: SH, effects: E, font: F } = useDesignTheme();
  const titleText = `${suggestion.title}${suggestion.titleLine2 ?? ""}`;
  return (
    <ModalOverlay onClose={onCancel}>
      <ModalCard>
        <p style={{ fontSize: "16px", fontWeight: 800, color: C.text, margin: "0 0 8px", fontFamily: F }}>
          この提案を実施しますか？
        </p>
        <p style={{ fontSize: "13px", color: C.muted, margin: "0 0 18px", lineHeight: 1.65, fontFamily: F }}>
          {hasActiveSuggestion && (
            <>
              実施中の提案と置き換わります。
              <br />
            </>
          )}
          「{titleText}」をもう一度実施します。
        </p>
        <div style={{ display: "flex", gap: "10px" }}>
          <button
            onClick={onConfirm}
            style={{
              flex: 1,
              height: "44px",
              borderRadius: SH.buttonRadius,
              background: C.primary,
              boxShadow: E.primaryBtnShadow,
              border: "none",
              fontSize: "14px",
              fontWeight: 700,
              color: "#FFFFFF",
              cursor: "pointer",
              fontFamily: F,
            }}
          >
            実施する
          </button>
          <button
            onClick={onCancel}
            style={{
              flex: 1,
              height: "44px",
              borderRadius: SH.buttonRadius,
              background: C.surface,
              border: E.secondaryBtnBorder,
              boxShadow: E.secondaryBtnShadow,
              fontSize: "14px",
              fontWeight: 700,
              color: C.primary,
              cursor: "pointer",
              fontFamily: F,
            }}
          >
            キャンセル
          </button>
        </div>
      </ModalCard>
    </ModalOverlay>
  );
}

/* ── 復活不可モーダル（提案データに該当 ID なし） ── */

export function UnavailableModal({ onClose }: { onClose: () => void }) {
  const { colors: C, shape: SH, effects: E, font: F } = useDesignTheme();
  return (
    <ModalOverlay onClose={onClose}>
      <ModalCard>
        <p style={{ fontSize: "16px", fontWeight: 800, color: C.text, margin: "0 0 8px", fontFamily: F }}>
          この提案は現在利用できません
        </p>
        <p style={{ fontSize: "13px", color: C.muted, margin: "0 0 18px", lineHeight: 1.65, fontFamily: F }}>
          提案データの更新により、この提案は削除されました。
        </p>
        <button
          onClick={onClose}
          style={{
            width: "100%",
            height: "44px",
            borderRadius: SH.buttonRadius,
            background: C.surface,
            border: E.secondaryBtnBorder,
            boxShadow: E.secondaryBtnShadow,
            fontSize: "14px",
            fontWeight: 700,
            color: C.primary,
            cursor: "pointer",
            fontFamily: F,
          }}
        >
          閉じる
        </button>
      </ModalCard>
    </ModalOverlay>
  );
}
