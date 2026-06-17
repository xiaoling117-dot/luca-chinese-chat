# 画像ファイルの手動アップロード手順

Codex の PR 作成画面でバイナリ画像が扱えない場合は、まずテキスト変更だけを PR にし、画像は GitHub の画面から別途アップロードしてください。

## アップロード先

GitHub リポジトリの以下のフォルダにアップロードします。

```text
assets/images/
```

フォルダが存在しない場合は、GitHub の「Add file」→「Create new file」で `assets/images/.gitkeep` などを一度作成するか、「Upload files」で `assets/images` フォルダごとドラッグ＆ドロップしてください。

## 必要な画像ファイル

| ファイル | 形式 | サイズ | 画像サイズ |
| --- | --- | ---: | ---: |
| `assets/images/chat-bg.jpg` | JPEG | 105,307 bytes | 800×1387 |
| `assets/images/chat-panel-bg.png` | PNG | 205,784 bytes | 360×360 |
| `assets/images/luca-avatar-special.png` | PNG | 185,950 bytes | 360×360 |
| `assets/images/luca-avatar.png` | PNG | 181,205 bytes | 360×360 |

## 一番簡単な画面操作

1. Codex 画面では、このテキスト変更だけの PR を作成します。
2. GitHub の対象リポジトリを開きます。
3. `assets/images/` フォルダを開きます。存在しない場合は作成します。
4. 「Add file」→「Upload files」を押します。
5. 上記 4 画像をドラッグ＆ドロップします。
6. Commit message に `Add extracted image assets` と入力してコミットします。
7. 先に作った PR に同じブランチへ追加されているか確認します。

## 注意

この PR の `index.html` は上記画像ファイルを参照します。画像ファイルをアップロードする前にマージすると、表示時に画像が読み込めません。
