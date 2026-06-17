# TODO: Luca Chinese Chat

今後の開発用TODOです。詳細な調査メモは `docs/codex-review-2026-06-16.md` を参照してください。

## 完了済み

- [x] iOS Safari向けに `.phone` の `height:100vh` を `100dvh` ベースへ見直す。
- [x] `.dock` と通話ボタン群に `env(safe-area-inset-bottom)` を追加する。
- [x] viewportから `maximum-scale=1.0, user-scalable=no` を外す。
- [x] プレゼント送信時に `save()` を呼び、親密度がリロード後も保持されるようにする。
- [x] `restartAll()` を完全リセットにする（dayIdx・idx・love・awarded を初期化）。
- [x] 会話途中のリロード時に `idx` も保存・復元する。
- [x] 巨大Base64画像（9枚・計約1.5MB）を `assets/images/` へ外部化する。（index.html: 2148KB → 53KB）

---

## 優先度高（次の作業）

### 音声アセット設計
- [ ] 通常セリフは Web Speech API（SpeechSynthesis）継続。追加実装不要。
- [ ] 名場面セリフ（「别消失」「这早就不是练习了」「你没有消失」「おかえり」）をローカルTTSでMP3生成し `assets/audio/` に置く。
- [ ] MP3 再生と Web Speech API の切り替えロジックを実装する（セリフデータに `audioFile` フラグを持たせる）。

### Web Speech API 安定化
- [ ] `speechSynthesis.getVoices()` の初回空配列に備え、`voiceschanged` を待って中国語音声を再選択する初期化フローを追加する。
- [ ] 読み上げ開始・終了・キャンセル・エラーを一元管理し、ボタンや再生中UIが取り残されないようにする。
- [ ] 連続タップ時は `cancel()` してから新しい発話を開始し、多重再生を防ぐ。
- [ ] 非対応ブラウザでは読み上げボタンを無効化して代替メッセージを表示する。

---

## 優先度中

- [ ] `ストーリーデータ由来の `innerHTML` 連結を減らす。
- [ ] CSS/JS/会話データをファイル分割する。
- [ ] Dayごとの会話データをJSONまたはJSモジュールに分ける。（v2移行時に対応予定）
- [ ] `DAYS`、`CALL`、`GIFTS` の簡易スキーマチェックを追加する。
- [ ] プレゼント日次キーをUTCではなくローカル日付基準にする。
- [ ] 通話報酬を全期間1回にするか、日次/Day別にするか仕様を決める。
- [ ] 小画面向けに選択肢、ショートカット、入力欄のレイアウトを再設計する。
- [ ] 選択肢内の中国語と日本語訳をモバイルでは2行表示にする。
- [ ] 単語帳・プレゼントパネルに閉じやすい下部ボタンや背景タップを追加する。

---

## 優先度低

- [ ] `+` ボタンを `div` ではなく `button` にする。
- [ ] パネル開閉時のフォーカス管理を追加する。
- [ ] `aria-expanded`、`aria-controls` などのアクセシビリティ属性を追加する。
- [ ] 吹き出しタップで訳が開くことを初回チップで案内する。
- [ ] レベル計算を固定式ではなくレベルテーブル化する。
- [ ] Playwrightなどで主要画面の表示確認を自動化する。
- [ ] 将来的なAI自由入力に備えて入力欄の仕様を再設計する。

---

## v2移行（別途企画書参照）

企画書：`コンテキスト/26-06-17_luca-design-doc-v2.md`

- [ ] プロローグ実装（朗読ライブルームの一枚絵 → お礼DM → 練習台依頼 → 本編）
- [ ] 4幕構成・1年タイムライン・時間飛ばし演出
- [ ] 親密度カーブ再設計（100%＝告白＝完結）
- [ ] 日本語ゲート（主人公が日本語入力すると「我不懂日语」分岐）
- [ ] 写真機能（決め画像選択式・ユーザー投稿なし）
- [ ] スタンプ（陸の表情差分を送受信）
- [ ] クライマックス＝空港シーン

---

## 確認コマンド候補

```bash
git status --short
python3 - <<'PY'
from pathlib import Path
s=Path('index.html').read_text()
start=s.index('<script>')+len('<script>')
end=s.index('</script>')
Path('/tmp/luca-script.js').write_text(s[start:end])
PY
node --check /tmp/luca-script.js
```
