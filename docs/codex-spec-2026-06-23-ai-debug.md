# Codex 仕様書 2026-06-23 — HSKK練習部屋 AI不具合の原因特定＋修正

発注：黎蓮（lilian）／対象リポジトリ：`luca-chinese-chat`（このリポジトリ）

---

## 背景

`hskk.html`（秘密の発音練習部屋）で、閣主の実機Chromeにて
**「Chrome内蔵AI（Gemini Nano / LanguageModel）を有効にしたら、録音しても聞き取り・フィードバックが出なくなった」**
という症状が報告された。

ChatGPTによる切り分けの要点（こちらも同意）：
- AIが録音を壊したというより、その手前の **Web Speech API（`SpeechRecognition`）の `onresult` が返っていない** 可能性が高い。
- 現状コードは `onerror` を画面に出すだけで **console に残していない** ため、原因（`no-speech` / `audio-capture` / `not-allowed` / `network`）が見えない。
- `LanguageModel.create` が出力言語未指定で「An output language should be specified」警告を出している（録音不能の直接原因ではないが直すべき）。

**現状：まだ「直す」段階ではなく「原因を特定する」段階。** 勘で直さないこと。

---

## やってほしいこと

### A. 診断ログの追加（必須）
`hskk.html` の `startRecording()` 内の `SpeechRecognition` に、以下のハンドラの console ログを追加する。既存の挙動（画面表示・`_hasOutcome` 管理・マイク解放）は壊さないこと。

- `onstart` → `console.log('[HSKK] recognition start')`
- `onaudiostart` → `console.log('[HSKK] audio start')`
- `onspeechstart` → `console.log('[HSKK] speech start')`
- `onspeechend` → `console.log('[HSKK] speech end')`
- `onresult` → `console.log('[HSKK] result', event.results)`（既存処理は維持）
- `onerror` → `console.warn('[HSKK] recognition error:', event.error, event)`（既存の画面表示は維持）
- `onend` → `console.log('[HSKK] recognition end', { stoppedByUser, hasOutcome })`

目的：閣主が実機Consoleを見て「マイクが聞いていない／話しているが結果が返らない／停止が早すぎる」のどれかを切り分けられるようにする。

### B. AI出力言語警告の修正（必須）
`nanoFeedback()` の `LanguageModel.create({...})` に、入出力言語の指定を追加する。
ただし **Chromeの実装差で `expectedInputs`/`expectedOutputs` が通らない環境がある**ため、付きで失敗したら従来形式（`systemPrompt` のみ）に**フォールバック**する二段構えにすること。

```js
// 例（フォールバック付き）
let session;
try {
  session = await LM.create({
    systemPrompt: '...既存の陸プロンプト...',
    expectedInputs: [{ type: 'text', languages: ['ja','zh'] }],
    expectedOutputs:[{ type: 'text', languages: ['ja'] }]
  });
} catch (e) {
  session = await LM.create({ systemPrompt: '...既存の陸プロンプト...' });
}
```

### C. コード精査による原因の所見（必須・コード変更は最小）
`hskk.html` 全体を読み、「AI有効化と録音認識が競合し得る箇所」がないか確認し、**所見を agmsg で報告**する。
- 明確なバグ（例：認識が意図せず `abort/stop` される、`showResult` 内で例外が握り潰され表示が止まる等）が見つかれば、**最小修正**を入れてよい。
- 見つからなければ無理に直さず「ログで実機確認が必要」と報告する。**推測で大改造しないこと。**

### D.（任意・余裕があれば提案のみ）
「停止ボタンが早すぎて結果前に終わる」環境向けに、無音自動終了UXの案があれば**提案だけ**（実装は今回しない）。

---

## 受け入れ条件

1. `hskk.html` に A のログが入り、既存の録音・マイク解放・画面表示の挙動が回帰していない。
2. B のフォールバック付き言語指定が入り、対応環境で警告が消え、非対応環境でも AI補助が従来通り動く。
3. C の所見が agmsg で報告されている（バグがあれば最小修正、なければ「実機ログ待ち」）。
4. 既存の世界観・UI・コード再利用を崩していない。モバイル完結・Nano非依存・マイク解放維持の原則を守る。

---

## 完了後

- 変更は **コミットしてよい**（メッセージは日本語で簡潔に）。**プッシュは黎蓮の確認後**にするので、コミットまでで一旦止めて agmsg で報告すること。
- 報告先：`send.sh code01 codex01 lilian "<報告>"`
