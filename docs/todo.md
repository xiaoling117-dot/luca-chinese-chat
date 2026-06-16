# TODO: Luca Chinese Chat

今後の開発用TODOです。詳細な調査メモは `docs/codex-review-2026-06-16.md` を参照してください。

## 優先度高

- [ ] iOS Safari向けに `.phone` の `height:100vh` を `100dvh` ベースへ見直す。
- [ ] `.dock` と通話ボタン群に `env(safe-area-inset-bottom)` を追加する。
- [ ] viewportから `maximum-scale=1.0, user-scalable=no` を外す。
- [ ] プレゼント送信時に `save()` を呼び、親密度がリロード後も保持されるようにする。
- [ ] `restartAll()` を完全リセットにするか、読み返し機能として文言を変更する。
- [ ] 会話途中のリロード仕様を決め、必要なら `idx` も保存する。
- [ ] Web Speech APIのvoicesロード、再生終了、エラー時の状態管理を改善する。
- [ ] 巨大Base64画像を外部アセットへ分離する。
- [ ] ストーリーデータ由来の `innerHTML` 連結を減らす。

## 優先度中

- [ ] CSS/JS/会話データをファイル分割する。
- [ ] Dayごとの会話データをJSONまたはJSモジュールに分ける。
- [ ] `DAYS`、`CALL`、`GIFTS` の簡易スキーマチェックを追加する。
- [ ] プレゼント日次キーをUTCではなくローカル日付基準にする。
- [ ] 通話報酬を全期間1回にするか、日次/Day別にするか仕様を決める。
- [ ] 小画面向けに選択肢、ショートカット、入力欄のレイアウトを再設計する。
- [ ] 選択肢内の中国語と日本語訳をモバイルでは2行表示にする。
- [ ] 単語帳・プレゼントパネルに閉じやすい下部ボタンや背景タップを追加する。

## 優先度低

- [ ] `+` ボタンを `div` ではなく `button` にする。
- [ ] パネル開閉時のフォーカス管理を追加する。
- [ ] `aria-expanded`、`aria-controls` などのアクセシビリティ属性を追加する。
- [ ] 吹き出しタップで訳が開くことを初回チップで案内する。
- [ ] レベル計算を固定式ではなくレベルテーブル化する。
- [ ] Playwrightなどで主要画面の表示確認を自動化する。
- [ ] 将来的なAI自由入力に備えて入力欄の仕様を再設計する。

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
