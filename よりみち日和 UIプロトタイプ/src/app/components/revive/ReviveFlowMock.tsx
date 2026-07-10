import { useState } from "react";
import { PhoneFrame } from "../PhoneFrame";
import { SuggestScreen } from "../SuggestScreen";
import { HistoryScreen, HistoryItem } from "../HistoryScreen";
import { SettingsScreen } from "../SettingsScreen";
import { useDesignTheme } from "../../theme";
import { REVIVE_SUGGESTIONS, REVIVE_HISTORY, ReviveSuggestion } from "./reviveMockData";
import { SuggestionDetailModal, ReviveConfirmModal, UnavailableModal } from "./ReviveModals";

/* ─────────────────────────────────────────────────────
   Issue #46 スキップ復活フローの通しモック
   履歴タブのスキップ行タップ → 提案詳細モーダル →
   確認ミニモーダル → 提案タブへ切替・実施中カード表示。
   状態（タブ・実施中・モーダル）はこのコンポーネントが持つ。
───────────────────────────────────────────────────── */

type ModalState =
  | { kind: "detail"; suggestion: ReviveSuggestion }
  | { kind: "confirm"; suggestion: ReviveSuggestion }
  | { kind: "unavailable" }
  | null;

export function ReviveFlowMock() {
  const { colors: C, shape: SH, font: F } = useDesignTheme();
  const [tab, setTab] = useState(1); // 初期は履歴タブ
  const [activeSuggestionId, setActiveSuggestionId] = useState<string | null>(null);
  const [modal, setModal] = useState<ModalState>(null);

  const handleSkippedClick = (item: HistoryItem) => {
    const record = REVIVE_HISTORY.find((r) => r.id === item.id);
    const suggestion = record ? REVIVE_SUGGESTIONS[record.suggestionId] : undefined;
    // 提案データに該当 ID がなければ復活不可（Issue #46）
    setModal(suggestion ? { kind: "detail", suggestion } : { kind: "unavailable" });
  };

  const handleConfirm = (suggestion: ReviveSuggestion) => {
    setActiveSuggestionId(suggestion.id);
    setModal(null);
    setTab(0); // 提案タブへ自動切替 → 実施中カード表示
  };

  const handleReset = () => {
    setTab(1);
    setActiveSuggestionId(null);
    setModal(null);
  };

  const activeSuggestion = activeSuggestionId ? REVIVE_SUGGESTIONS[activeSuggestionId] : undefined;

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: "12px" }}>
      <PhoneFrame label="Issue #46 スキップ復活フロー">
        {tab === 0 ? (
          <SuggestScreen activeTab={tab} onTabChange={setTab} activeSuggestion={activeSuggestion} />
        ) : tab === 1 ? (
          <HistoryScreen activeTab={tab} onTabChange={setTab} items={REVIVE_HISTORY} onSkippedItemClick={handleSkippedClick} />
        ) : (
          <SettingsScreen activeTab={tab} onTabChange={setTab} />
        )}

        {modal?.kind === "detail" && (
          <SuggestionDetailModal
            suggestion={modal.suggestion}
            onTry={() => setModal({ kind: "confirm", suggestion: modal.suggestion })}
            onClose={() => setModal(null)}
          />
        )}
        {modal?.kind === "confirm" && (
          <ReviveConfirmModal
            suggestion={modal.suggestion}
            hasActiveSuggestion={activeSuggestionId !== null}
            onConfirm={() => handleConfirm(modal.suggestion)}
            onCancel={() => setModal(null)}
          />
        )}
        {modal?.kind === "unavailable" && <UnavailableModal onClose={() => setModal(null)} />}
      </PhoneFrame>

      <button
        onClick={handleReset}
        style={{
          padding: "7px 18px",
          borderRadius: SH.buttonRadius,
          border: `1px solid ${C.outline}`,
          background: "#FFFFFF",
          fontSize: "12px",
          fontWeight: 700,
          color: C.muted,
          cursor: "pointer",
          fontFamily: F,
        }}
      >
        モックを最初からやり直す
      </button>
    </div>
  );
}
