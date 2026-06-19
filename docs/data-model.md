# データモデル設計書

> 対象：陸チャットゲーム（luca-chinese-chat）  
> フェーズ：① ローカル設計（localStorage / JSON）→ ④ Supabase移行

---

## 1. 旧形式（移行元）

旧バージョンが `localStorage` に保存していた内容。現行の `index.html` は初回読込時に
`luca_data` へ自動移行し、これらの旧キーを削除する。

| キー | 型 | 内容 |
|---|---|---|
| `luca_save` | JSON | `{love, dayIdx, idx, awarded[]}` — 進捗・親密度・報酬取得済みフラグ |
| `gift_YYYY-MM-DD` | JSON | `{0:count, 1:count, ...}` — 当日ギフト送信回数（ギフト種別ごと） |

### luca_save の現構造

```json
{
  "love": 42,
  "dayIdx": 1,
  "idx": 7,
  "awarded": ["1-3", "1-5", "call"]
}
```

- `awarded` の値は `"dayIdx-stepIdx"` 形式のキー + 特殊イベントキー（`"call"` など）
- 二重取り防止に使用

---

## 2. 拡張データモデル（目標形）

エンジンの成長に合わせて保存データを整理する。  
ローカルでは `localStorage` または `data/*.json` に持ち、将来 Supabase テーブルに対応させる。

---

### 2-1. ユーザー (User)

```json
{
  "userId": "uuid-v4",
  "createdAt": "2026-06-18T00:00:00Z",
  "settings": {
    "lang": "ja",
    "autoPlay": false,
    "hintsSeen": ["tap_translate", "tap_play"]
  }
}
```

| フィールド | 説明 |
|---|---|
| `userId` | デバイス初回起動時に生成するUUID |
| `settings.hintsSeen` | 表示済みonboardingヒントID一覧（showOnce管理） |

**Supabase テーブル：** `users`

---

### 2-2. 進捗 (Progress)

```json
{
  "userId": "uuid-v4",
  "currentEpId": "episode1",
  "currentIdx": 7,
  "completedEps": ["prologue"],
  "unlockedContent": []
}
```

| フィールド | 説明 |
|---|---|
| `currentEpId` | 現在のエピソードID（`prologue` / `episode1` / `episode2` ...） |
| `currentIdx` | エピソード内のステップ位置 |
| `completedEps` | クリア済みエピソードID一覧 |
| `unlockedContent` | 解放済み特典コンテンツID（スタンプ・通話 等） |

**v1との対応：** `dayIdx` → `currentEpId`、`idx` → `currentIdx`

**Supabase テーブル：** `progress`

---

### 2-3. 親密度 (Affection)

```json
{
  "userId": "uuid-v4",
  "love": 42,
  "level": 2
}
```

| フィールド | 説明 |
|---|---|
| `love` | 現在の親密度ポイント（0〜100） |
| `level` | 現在の親密度レベル（ポイントから計算） |

**Supabase テーブル：** `affection`

---

### 2-4. 報酬・スタンプ取得ログ (Awards)

```json
{
  "userId": "uuid-v4",
  "awards": [
    { "key": "prologue-8",  "awardedAt": "2026-06-18T01:20:00Z", "source": "choice", "delta": 3 },
    { "key": "call",        "awardedAt": "2026-06-18T02:05:00Z", "source": "call",   "delta": 8 }
  ]
}
```

| フィールド | 説明 |
|---|---|
| `key` | `"epId-stepIdx"` 形式または特殊イベントキー |
| `source` | 報酬の発生元（`choice` / `gift` / `call` / `event`） |
| `delta` | 加算した親密度ポイント |

**v1との対応：** `awarded[]` Set の各値がここの `key` に対応  
**Supabase テーブル：** `awards`

---

### 2-5. 選択ログ (ChoiceLog)

```json
{
  "userId": "uuid-v4",
  "choices": [
    {
      "epId": "episode1",
      "stepIdx": 2,
      "optionIdx": 1,
      "sentZh": "有点累。",
      "ts": "2026-06-18T01:15:00Z"
    }
  ]
}
```

| フィールド | 説明 |
|---|---|
| `epId` | 選択が発生したエピソード |
| `stepIdx` | ステップ位置 |
| `optionIdx` | 選んだ選択肢の番号（0-indexed） |
| `sentZh` | 送信した中国語テキスト（表示復元用） |

**用途：** キャラクターAI応答のコンテキスト渡し、リプレイ、分析  
**Supabase テーブル：** `choice_logs`

---

### 2-6. 単語帳 (Vocab)

```json
{
  "userId": "uuid-v4",
  "words": [
    {
      "zh": "别紧张",
      "pinyin": "bié jǐnzhāng",
      "ja": "緊張しないで",
      "firstSeenEp": "prologue",
      "firstSeenAt": "2026-06-18T00:12:00Z",
      "seenCount": 3
    }
  ]
}
```

| フィールド | 説明 |
|---|---|
| `zh` | 中国語（主キー相当） |
| `firstSeenEp` | 初出エピソード |
| `seenCount` | 登場回数（SRS実装時に活用） |

**v1との対応：** `DAYS[].vocab` の静的リストを動的蓄積に発展させる  
**Supabase テーブル：** `vocab`

---

### 2-7. ギフトログ (GiftLog)

```json
{
  "userId": "uuid-v4",
  "giftLog": [
    { "date": "2026-06-18", "giftId": 2, "count": 1, "delta": 12 }
  ]
}
```

| フィールド | 説明 |
|---|---|
| `date` | 送信日（`YYYY-MM-DD`） |
| `giftId` | ギフト種別番号（0〜3） |
| `count` | その日の送信回数 |

**v1との対応：** `gift_YYYY-MM-DD` キーをテーブル1行ずつに展開  
**Supabase テーブル：** `gift_logs`

---

### 2-8. 音声判定ログ (VoiceLog)

```json
{
  "userId": "uuid-v4",
  "voiceLogs": [
    {
      "ts": "2026-06-18T01:30:00Z",
      "epId": "episode1",
      "zh": "晚安",
      "score": 0.85,
      "passed": true
    }
  ]
}
```

**※ 音声判定機能の実装後に有効化。現時点では空配列で確保するだけでよい。**

**Supabase テーブル：** `voice_logs`

---

## 3. ローカル実装方針

### localStorageへの格納（最小実装）

すべてのエンティティを `luca_data` 1キーにまとめる：

```json
{
  "userId": "uuid-v4",
  "createdAt": "ISO8601",
  "settings": { "lang": "ja", "autoPlay": false, "hintsSeen": [] },
  "progress": { "currentEpId": "prologue", "currentIdx": 0, "completedEps": [], "unlockedContent": [] },
  "affection": { "love": 0, "level": 1 },
  "awards": [],
  "choices": [],
  "words": [],
  "giftLog": [],
  "voiceLogs": []
}
```

**キー名：** `luca_data`。旧 `luca_save` は初回読込時に自動移行し、移行成功後に削除する。
音声評価結果は `voiceLogs` に保存する。

### SQLiteへの格納（② フェーズ）

`data/luca.db` を作成し、上記8テーブルをSQLで管理。  
APIサーバー（Node / Python）経由でゲームエンジンと接続。

### JSONファイルによる仮DB（② の簡易版）

`data/user.json`, `data/progress.json` 等に分割して保存。  
APIサーバー不要・GitHub Pages互換のまま動作確認できる。

---

## 3b. コンテンツ定義（静的JSONファイル）

アプリ構造をコード内ハードコードではなくデータで定義する。git で管理し、サーバー不要。

### `data/rooms.json`

トークルーム一覧。将来キャラクターが増えたとき行を追加するだけでよい。

```json
[
  {
    "id": "luca",
    "character_name": "陸（ルー）",
    "title_ja": "陸との練習部屋",
    "description_ja": "深夜の朗読ルームで出会った、傷を持つ不眠症の男。中国語しか話せない。",
    "face_image": "assets/images/luca-face-default.png",
    "unlock_love_required": 0,
    "sort_order": 0,
    "is_active": true,
    "episodes": ["prologue", "episode1", "episode2"]
  }
]
```

**Supabase テーブル：** `rooms`

---

### エピソード（既存 `data/*.json`）

各エピソードの `id` フィールドが `rooms.episodes[]` の値に対応する。
台本仕様は `data/prologue.json` の `_readme` を参照。

**Supabase テーブル：** `episodes`

---

## 4. Supabaseテーブル一覧（将来）

| テーブル | PK | FK |
|---|---|---|
| `users` | `id` | — |
| `rooms` | `id` | — |
| `episodes` | `id` | `rooms.id` |
| `progress` | `user_id` | `users.id` |
| `affection` | `user_id` | `users.id` |
| `awards` | `id` (auto) | `users.id` |
| `choice_logs` | `id` (auto) | `users.id` |
| `vocab` | `(user_id, zh)` | `users.id` |
| `gift_logs` | `id` (auto) | `users.id` |
| `voice_logs` | `id` (auto) | `users.id` |

Row Level Security（RLS）を有効にし、`user_id = auth.uid()` でユーザーが自分のデータだけ読み書きできる設計。

---

## 5. AIキャラクター接続（③ フェーズ）

陸のAI応答に渡すコンテキスト（最小セット）：

```json
{
  "charPrompt": "陸（ルー）のシステムプロンプト",
  "recentChoices": ["有点累。", "在吗？"],
  "love": 42,
  "currentEp": "episode2"
}
```

**ローカルテスト：** Ollama（`qwen2.5:7b` 等）にPOSTして応答確認  
**本番：** Claude API または 選定AIのAPIに差し替え

---

## 6. 実装ロードマップ

```
① ローカルで保存データ設計  ← いまここ（data-model.md 完成）
↓
② localStorage に luca_data を導入（v1エンジンへの段階移行）
   or data/*.json + シンプルAPIサーバーで仮DB
↓
③ Ollama接続：陸キャラクターのAI応答テスト
↓
④ Supabase移行：テーブル作成 + RLS設定 + APIサーバー差し替え
↓
⑤ GitHub Pages + APIサーバー構成で本番公開
```
