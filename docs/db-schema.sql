-- db-schema.sql  将来の Supabase 移行用 SQLite 互換スキーマ
-- 作成：黎蓮・麗蘭 / 2026-06-19

CREATE TABLE IF NOT EXISTS rooms (
  id TEXT PRIMARY KEY,
  character_name TEXT NOT NULL,
  title_ja TEXT NOT NULL,
  description_ja TEXT,
  face_image TEXT,
  unlock_love_required INTEGER DEFAULT 0,
  sort_order INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS episodes (
  id TEXT PRIMARY KEY,
  room_id TEXT NOT NULL,
  episode_number INTEGER NOT NULL,
  title_ja TEXT,
  data_file TEXT NOT NULL,
  unlock_love_threshold INTEGER DEFAULT 0,
  FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  created_at TEXT DEFAULT (datetime('now')),
  lang TEXT DEFAULT 'ja',
  auto_play INTEGER DEFAULT 0,
  hints_seen TEXT DEFAULT '[]'
);

CREATE TABLE IF NOT EXISTS progress (
  user_id TEXT NOT NULL,
  room_id TEXT NOT NULL,
  current_episode_id TEXT,
  current_step_idx INTEGER DEFAULT 0,
  completed_episodes TEXT DEFAULT '[]',
  unlocked_content TEXT DEFAULT '[]',
  updated_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, room_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE IF NOT EXISTS affection (
  user_id TEXT NOT NULL,
  room_id TEXT NOT NULL,
  love INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  updated_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, room_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE IF NOT EXISTS awards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  room_id TEXT NOT NULL,
  award_key TEXT NOT NULL,
  source TEXT NOT NULL,
  delta INTEGER DEFAULT 0,
  awarded_at TEXT DEFAULT (datetime('now')),
  UNIQUE (user_id, room_id, award_key),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS choice_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  room_id TEXT NOT NULL,
  episode_id TEXT NOT NULL,
  step_idx INTEGER NOT NULL,
  option_idx INTEGER NOT NULL,
  sent_zh TEXT,
  chosen_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS vocab (
  user_id TEXT NOT NULL,
  zh TEXT NOT NULL,
  pinyin TEXT NOT NULL,
  ja TEXT NOT NULL,
  first_seen_ep TEXT,
  first_seen_at TEXT DEFAULT (datetime('now')),
  seen_count INTEGER DEFAULT 1,
  PRIMARY KEY (user_id, zh),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS gift_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  room_id TEXT NOT NULL,
  gift_id INTEGER NOT NULL,
  sent_date TEXT NOT NULL,
  count INTEGER DEFAULT 1,
  delta INTEGER DEFAULT 0,
  sent_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS voice_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  room_id TEXT NOT NULL,
  episode_id TEXT NOT NULL,
  step_idx INTEGER NOT NULL,
  target_zh TEXT NOT NULL,
  transcript TEXT,
  score REAL,
  passed INTEGER DEFAULT 0,
  attempted_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
