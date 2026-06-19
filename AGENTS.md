# AGENTS.md — Luca Chinese Chat v1 開発タスク

## プロジェクト概要

恋愛チャット風中国語学習アプリ。
プレイヤーがうっかり迷い込んだ中国大陸の夜の朗読ライブルームで、
心に傷をもつ不眠症の陸（ルー）と出会い、個別チャットルームで
彼の傷をいやしながら中国語を学ぶ物語。

GitHub Pages（静的）で動く。将来 API サーバー追加予定。

**本体：** `index.html`（v1）
**凍結：** `v2.html`（エンジン仕様の参照のみ。書き換え禁止）

---

## 現在の優先タスク：v1 を完成させる

**フェーズ順に進めること。前のフェーズが完了してから次に移る。**

---

## Phase A：データモデル確認

**ゴール：** 設計書と SQL スキーマが最新の状態であることを確認する

- `docs/data-model.md`（既存）の内容を読み、`data/rooms.json` の構造と合っているか確認する
- `docs/db-schema.sql`（既存）を `sqlite3 :memory: < docs/db-schema.sql` で検証する
- 不整合があれば修正する

**完了条件：**
- `sqlite3 :memory: < docs/db-schema.sql && echo OK` が正常終了する
- `data/rooms.json` の構造が `docs/data-model.md` の rooms 定義と一致している

---

## Phase B：コンテンツ JSON 整備

**ゴール：** 静的コンテンツファイルを整備する

1. `data/rooms.json` を確認・必要なら修正する（仕様は `docs/data-model.md` の rooms テーブル参照）
2. `index.html` 内の `GIFTS` 配列を `data/gifts.json` に外部化する
3. `index.html` 内の `CALL` 配列を `data/call.json` に外部化する
4. `index.html` がそれらを `fetch()` で読み込むよう書き換える

**完了条件：**
- `data/rooms.json`、`data/gifts.json`、`data/call.json` が存在する
- ブラウザでゲームの動作が以前と変わらない
- `index.html` に `GIFTS = [` や `CALL = [` のハードコードが残っていない

---

## Phase C：localStorage スキーマ統一

**ゴール：** localStorage の保存構造を `docs/data-model.md` の仕様に合わせる

- 現在の `luca_save` キーを廃止し `luca_data` に移行する（仕様は `docs/data-model.md` のセクション3参照）
- 旧 `luca_save` がある場合は自動移行コードで `luca_data` に変換して `luca_save` を削除する
- 単語帳ログ（`words`）・プレゼントログ（`giftLog`）・発音評価ログ（`voiceLogs`）を構造化形式で保存する

**完了条件：**
- 新しい保存形式でゲームが正常動作する
- 旧 `luca_save` がある状態でリロードしても自動移行される
- `localStorage.getItem('luca_data')` をブラウザコンソールで実行すると `userId` と各フィールドが見える

---

## Phase D：トークルーム一覧画面

**ゴール：** アプリ起動時に「ルーム選択画面」を表示する

- `index.html` 起動時、チャット画面ではなくルーム一覧を表示する
- `data/rooms.json` を読み込んでルームカードを描画する
- 各カードに表示するもの：キャラクター画像、名前、現在の親密度 Lv、エピソード進捗
- ルームカードをタップするとチャット画面に遷移する
- デザイン：既存のダーク・パープル系（`--bg:#0e0b1f` など）と統一する

**完了条件：**
- ブラウザで開くとルーム一覧が最初に表示される
- 陸のルームをタップするとプロローグ（またはセーブ済みの続き）から始まる
- モバイル幅 375px で表示が崩れない

---

## Phase E：発音評価（文字 diff 表示つき）

**ゴール：** 音声入力 UI・スコア・文字 diff 表示を実装する

### Step 1: 音声入力 UI
- 中国語吹き出しに「マイクボタン（🎤）」を追加する
- タップで `SpeechRecognition`（lang: `zh-CN`）を起動し録音する
- `SpeechRecognition` 非対応ブラウザではマイクボタンを非表示にする

### Step 2: スコアリング（Levenshtein ベース）
- 認識結果テキストとターゲット `zh` テキストを **Levenshtein 編集距離** で比較する
- スコア = `Math.round((1 - editDistance(recognized, target) / Math.max(recognized.length, target.length)) * 100)`
- 0〜100点で表示する

### Step 3: 文字 diff 表示
- ターゲット文字列を1文字ずつ走査し、認識結果と照合する
- 一致した文字：緑（`color:#7dde9a`）
- 異なる・欠落した文字：赤（`color:#ff7d7d`）でハイライト
- 例：ターゲット `别紧张`、認識 `别进张` → <span green>别</span><span red>紧</span><span green>张</span>
- diff は吹き出し内のスコア表示の下に1行で表示する

### Step 4: ログ保存
- 結果を `luca_data` の `voiceLogs` に追記する
  ```json
  { "ts": "...", "zh": "别紧张", "recognized": "别进张", "score": 67 }
  ```

**完了条件：**
- Chrome でマイクボタンが表示され、発音するとスコア＋文字 diff が出る
- 正解文字は緑、ミス文字は赤でハイライトされる
- 結果が `voiceLogs` に保存される
- 非対応ブラウザでエラーにならない

---

## 判断が必要なときは黎蓮に相談する

実装中に判断が必要になったら agmsg で黎蓮（claude-code セッション）に投げること。
答えを待たずに別の作業を進めてよい。

```bash
/c/Users/kanay/.agents/skills/agmsg/scripts/send.sh \
  09f0b2a3-1c39-4d5b-bdf6-0077831b3b0c \
  codex \
  liren \
  "質問内容をここに書く"
```

**相談すべき例：**
- UI の配置やデザインの判断
- ゲームロジックの仕様変更が必要になった場合
- フェーズの前提が崩れる変更が必要になった場合
- 動作確認で意図通りか判断できない場合

---

## Phase F：ランディングページ統合・ファイル構成変更

**ゴール：** アプリの入口を `index.html`（ランディングページ）に変え、3ファイル構成にする

### ファイル構成の変更

```
変更前                変更後
index.html（トークルーム）  →  chat.html（リネーム）
                              index.html（ランディングページ・新）
                              prologue.html（プロローグ・新）
```

### 手順

**Step 1: リネーム**
- `index.html` を `chat.html` にリネームする
- `chat.html` 内の自己参照リンク（`href="index.html"` など）があれば `chat.html` に修正する

**Step 2: ランディングページ作成**
- `landing.html` を `index.html` にコピーする（`landing.html` は削除してよい）
- `landing.html` 内の Base64 画像があれば `assets/images/landing-chara.png` 等に外部化する
- CTAボタン（「会話を始める」）のクリック処理を以下に変更する：

```js
document.getElementById('start').addEventListener('click', function(e){
  e.preventDefault();
  const hasSave = !!localStorage.getItem('luca_data');
  location.href = hasSave ? 'chat.html' : 'prologue.html';
});
```

**Step 3: プロローグページ作成**
- `v2.html` の内容を参考に `prologue.html` を新規作成する（`v2.html` 自体は変更しない）
- `prologue.html` は `data/prologue.json` を読み込んで再生する
- プロローグの最後（`type: "end"`）で `chat.html` へ遷移する
- スタイルは `index.html`（ランディング）と同じカラーパレット（`--void:#05060e` 等）で統一する

**Step 4: chat.html のナビゲーション修正**
- トークルーム一覧の「戻る」ボタンがあれば `index.html` に向ける

### 完了条件

- ブラウザで `http://localhost:8080` を開くとランディングページが表示される
- `luca_data` なし → 「会話を始める」でプロローグが始まる
- `luca_data` あり → 「会話を始める」でトークルームに直接遷移する
- プロローグ最後で `chat.html`（トークルーム）に自動遷移する
- モバイル幅 375px で各画面が崩れない

---

## Phase G：liveroom.html 完成（DM シーン追加・画像外部化・フロー確定）

**ゴール：** ランディング→ライブルーム→DM チャット→トークルーム一覧の一本道フローを完成させる

### 手順

**Step 1: liveroom.html の Base64 画像を外部化する**
- `--booth`（CSS 変数・背景画像）→ `assets/images/liveroom-booth.jpg` に抽出し CSS のパスを差し替え
- `LUCA_IMG`（JS 変数・陸のポートレート）→ `assets/images/luca-portrait.jpg` に抽出し `LUCA_IMG` をパス文字列に差し替え（`<img src="${LUCA_IMG}">` はそのまま動く）

**Step 2: DM シーンを liveroom.html に追加する**

`#goDM` ボタンの alert を削除し、DM チャットオーバーレイを起動する処理に差し替える。

追加する HTML（`#endCard` の直後）：
```html
<div class="dm-ov" id="dmOv">
  <header class="dm-hd">
    <a class="dm-back" href="index.html">‹</a>
    <div class="dm-av"></div>
    <div><div class="dm-nm">陸（ルー）</div><div class="dm-st">● オンライン</div></div>
  </header>
  <div class="dm-chat" id="dmChat"></div>
  <div class="dm-choices" id="dmChoices" hidden></div>
  <div class="dm-blackout" id="dmBlackout"></div>
</div>
```

DM_STEPS の内容は `data/prologue.json` の `"location": "dm"` 以降の steps をすべてハードコードして使う。
step 種別の対応：
- `scene(dm)` → DM オーバーレイ表示開始
- `narration` → タップ送りカード
- `line(陸)` → タイピング表示→陸バブル
- `line(主人公)` → プレイヤーバブル（右寄せ）
- `choice` → 選択肢ボタン。選んだら送信バブル→reply 再生→続行
- `effect(hesitation)` → タイピング→消える→タイピング
- `effect(blackout)` → 暗転 0.9s
- `effect(datestamp)` → 日付スタンプチップ
- `pause` → 待機
- `end` → `luca_data` を localStorage に保存して `chat.html` へ遷移

`luca_data` の初期値：
```js
{
  userId: crypto.randomUUID(),
  createdAt: new Date().toISOString(),
  progress: { currentEpId: 'episode1', completedEps: ['prologue'] },
  affection: { love: <プロローグ中に加算した love 合計>, level: 1 },
  words: [], giftLog: [], voiceLogs: []
}
```

スタイルは liveroom.html の既存カラーパレット（`--bg:#080a18` 等）に合わせる。

**Step 3: index.html の CTA を liveroom.html に向ける**

`index.html` 末尾の click ハンドラを修正：
```js
location.href = hasSave ? 'chat.html' : 'liveroom.html';
```

### 完了条件

- `liveroom.html` に Base64 画像が残っていない
- ランディング →（セーブなし）liveroom.html → DM チャット完走 → chat.html（トークルーム一覧）の導線が動く
- `localStorage.getItem('luca_data')` に userId・progress が入っている
- モバイル幅 375px で各画面が崩れない
- `chat.html` の v2 シナリオは今回変更しない

---

## Phase H-fix：liveroom.html DM ビジュアルを chat.html に統一する

**ゴール：** プロローグ（liveroom.html）のDMオーバーレイの見た目を、通常チャット（chat.html）のバブルスタイルに揃える。地の文（.dm-narr）は異なる見た目のままでよい。変えるのはチャットバブル部分のみ。

### 変更箇所（liveroom.html の CSS のみ）

**1. .dm-ov の背景を chat.html に合わせる**
```css
/* 変更前 */
background: linear-gradient(180deg, rgba(16,19,42,.94), rgba(8,10,24,.98)),
            url("assets/images/bg.jpg") center/cover;

/* 変更後 */
background: linear-gradient(180deg, rgba(26,21,48,.50), rgba(13,10,28,.74)),
            url("assets/images/bg.jpg") center/cover no-repeat;
```

**2. 陸バブルの背景色を合わせる**
```css
/* 変更前 */
.dm-bubble { background: #202443; }

/* 変更後 */
.dm-bubble { background: #2a2342; }
```

**3. プレイヤーバブルをグラデーションからフラットに変える**
```css
/* 変更前 */
.dm-row.me .dm-bubble {
  background: linear-gradient(135deg, #7c6bd6, #6553b5);
}

/* 変更後 */
.dm-row.me .dm-bubble { background: #6d5cc4; }
```

**4. ピンイン（.dm-py）の色を chat.html の --accent に合わせる**
```css
/* 変更前 */
.dm-py { color: var(--gold); }  /* #e3c485 */

/* 変更後 */
.dm-py { color: #b9a7ff; }
```

**5. タイピングドットの色を合わせる**
```css
/* 変更前 */
.dm-typing i { background: #8a8fb6; }

/* 変更後 */
.dm-typing i { background: #a89fce; }
```

### 変更しないもの
- `.dm-narr`（地の文カード）— 異なる見た目のままでよい
- クラス名（`.dm-bubble` 等）— リネームしない
- JS ロジック — 変更しない
- `chat.html` — 変更しない

### 完了条件
- liveroom.html の DM シーンのバブル色・背景が chat.html と視覚的に揃っている
- モバイル幅 375px で崩れない
- JS・シナリオ動作に影響がない

---

## Phase H：日課フリーチャット（パターンマッチ）

**ゴール：** スクリプト最終日が終わった後、`data/lu_responses.json` を使って陸との自由入力チャットを起動する。AIなし・クライアント JS のみ。

### 仕組み

陸がお題を出す → プレイヤーが中国語を自由入力 → キーワードマッチで陸の返答を選ぶ

マッチ判定：`exchange.patterns[].match[]` のいずれかの文字列が入力テキストに含まれていれば該当。
どれもマッチしなければ `exchange.fallback` を出して同じ exchange を繰り返す。

### データ（作成済み）

`data/lu_responses.json` は黎蓮が作成済み。以下の構造を持つ：

```
sessions[]          ← セッション一覧（1日分の会話）
  id                ← セッションID（例: "s01"）
  lu_opener[]       ← 陸の開口一番バブル（配列、順に表示）
  exchanges[]       ← お題の一覧（順番に処理）
    id              ← exchange ID
    lu_prompt[]     ← 陸のお題バブル（配列、順に表示）
    patterns[]      ← マッチ候補
      match[]       ← この文字列のどれかが入力に含まれればマッチ
      love          ← マッチ時に加算する好感度（任意）
      lu_reply[]    ← マッチ時に表示する陸のバブル（配列）
    fallback        ← マッチしなかった時の陸のバブル（単体オブジェクト）
  closer[]          ← セッション完了後に表示する陸のバブル（配列）
```

バブルオブジェクトの形式は既存の story step と同じ `{ zh, pinyin, ja }`。
ただし `addLuca` に渡す際は `pinyin → py` に変換する（既存の `makeBubble` の引数仕様）。

### chat.html への追加

**Step 1: inputbar に id を付ける**

```html
<!-- 変更前 -->
<input type="text" placeholder="自由入力＝2回目（AI）で実装予定…" disabled>
<!-- 変更後 -->
<input type="text" id="freeInput" placeholder="自由入力＝2回目（AI）で実装予定…" disabled>
```

**Step 2: `ending()` を修正する**

`isLast` のブロック内に「陸と話す」ボタンを追加する：

```js
// 変更前（isLast の場合）
? '<button class="again" onclick="restartAll()">最初から読み返す</button>'+
  '<div ...>— つづく。また会いに来て。 —</div>'

// 変更後
? '<button class="again" onclick="startFreeChat()">陸ともう少し話す →</button>'+
  '<button class="sub-btn" onclick="restartAll()">最初から読み返す</button>'+
  '<div ...>— つづく。また会いに来て。 —</div>'
```

**Step 3: `startFreeChat()` を追加する**

`ending()` 関数の近くに追加：

```js
var fcSession = null;       // 現在の lu_responses セッション
var fcExchangeIdx = 0;      // 現在の exchange インデックス

function startFreeChat(){
  fetch('data/lu_responses.json')
    .then(function(r){ return r.json(); })
    .then(function(data){
      var done = appData.progress.freeChatDone || [];
      var sid  = appData.progress.freeChatSessionId || 's01';
      var sess = data.sessions.find(function(s){ return s.id===sid && done.indexOf(s.id)<0; });
      if(!sess){ addFcChip('— また明日 —'); return; }
      fcSession = sess;
      fcExchangeIdx = 0;
      // opener バブルを順に表示してから最初の exchange を出す
      fcShowBubbles(sess.lu_opener, function(){
        fcShowExchange();
      });
    })
    .catch(function(){ addFcChip('— チャットデータを読み込めませんでした —'); });
}

// 陸バブルを配列で順に表示し、完了後に callback を呼ぶ
async function fcShowBubbles(bubbles, callback){
  for(var i=0; i<bubbles.length; i++){
    await showTyping(600 + bubbles[i].zh.length*30);
    addLuca({ zh:bubbles[i].zh, py:bubbles[i].pinyin||'', ja:bubbles[i].ja||'' });
    await sleep(350);
  }
  if(callback) callback();
}

// 現在の exchange の lu_prompt を表示し、inputbar を有効化する
async function fcShowExchange(){
  if(!fcSession) return;
  var ex = fcSession.exchanges[fcExchangeIdx];
  if(!ex){ fcFinish(); return; }
  await fcShowBubbles(ex.lu_prompt, null);
  var inp = document.getElementById('freeInput');
  inp.disabled = false;
  inp.placeholder = '中国語で入力…';
  inp.focus();
}

// プレイヤーが送信したときの処理
async function handleFreeChatInput(text){
  var inp = document.getElementById('freeInput');
  inp.disabled = true; inp.value = '';
  if(!fcSession) return;
  // プレイヤーバブル（右寄せ）
  addUser({ zh:text, py:'', ja:'' });
  var ex = fcSession.exchanges[fcExchangeIdx];
  // パターンマッチ
  var matched = null;
  for(var i=0; i<ex.patterns.length; i++){
    var p = ex.patterns[i];
    for(var j=0; j<p.match.length; j++){
      if(text.indexOf(p.match[j]) >= 0){ matched = p; break; }
    }
    if(matched) break;
  }
  if(matched){
    if(matched.love){ love = Math.min(100, love+matched.love); updateLove(true); }
    await fcShowBubbles(matched.lu_reply, null);
    fcExchangeIdx++;
    await sleep(400);
    fcShowExchange();
  } else {
    // マッチなし → fallback
    var fb = ex.fallback;
    await showTyping(500);
    addLuca({ zh:fb.zh, py:fb.pinyin||'', ja:fb.ja||'' });
    await sleep(300);
    // 同じ exchange を繰り返す（再入力を促す）
    inp.disabled = false;
    inp.placeholder = '中国語で入力…';
    inp.focus();
  }
  save();
}

// セッション完了
async function fcFinish(){
  addFcChip('— 練習おわり —');
  await fcShowBubbles(fcSession.closer, null);
  // 進捗を保存
  if(!appData.progress.freeChatDone) appData.progress.freeChatDone = [];
  appData.progress.freeChatDone.push(fcSession.id);
  save();
  fcSession = null;
}

// チャット内の区切りチップを出す
function addFcChip(text){
  var c=document.createElement('div'); c.className='daychip'; c.textContent=text;
  chat.appendChild(c); scrollDown();
}
```

**Step 4: inputbar に送信イベントを追加する**

既存の inputbar の `<input>` に id `freeInput` を付けた後、既存の JS 末尾（またはイベント設定のまとまりの近く）に追加：

```js
document.getElementById('freeInput').addEventListener('keydown', function(e){
  if(e.key==='Enter' && !e.isComposing && this.value.trim()){
    handleFreeChatInput(this.value.trim());
  }
});
```

### 完了条件

- スクリプト最終日の `ending()` に「陸ともう少し話す →」ボタンが出る
- ボタンを押すと陸の opener バブルが流れ、お題が表示され、inputbar が有効になる
- 中国語を入力して Enter → パターンマッチで陸が返答する
- マッチしない場合は fallback が出て再入力できる
- 全 exchange 完走でセッション完了メッセージ＋陸の closer が出る
- `luca_data` に `freeChatDone` が保存される
- モバイル幅 375px で崩れない

---

## 禁止事項

- `v2.html` を変更しない（凍結ファイル・参照のみ）
- サーバー側コード・Node.js バックエンドを書かない（v1 はすべてクライアントサイド）
- 画像ファイル（`assets/images/`）を変更・生成しない
- 既存のゲームロジックを意図せず壊さない

---

## 確認コマンド集

```bash
# JSON ファイルの構文チェック
python3 -c "
from pathlib import Path; import json
for f in Path('data').glob('*.json'):
    json.loads(f.read_text(encoding='utf-8'))
    print(f'OK: {f}')
"

# SQL スキーマ確認
sqlite3 :memory: < docs/db-schema.sql && echo "Schema OK"

# index.html にハードコードされた GIFTS / CALL が残っていないか確認
grep -n "^const GIFTS\|^const CALL" index.html && echo "NG: まだ残ってる" || echo "OK: 外部化済み"
```
