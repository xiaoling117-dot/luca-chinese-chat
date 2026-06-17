# Base64 形式の画像バックアップ

Codex の PR 作成画面がバイナリ画像ファイルを扱えない場合に備えて、外部化した画像を Base64 テキストとして保存しています。

## ファイル対応表

| Base64 テキスト | 復元後の画像ファイル |
| --- | --- |
| `chat-bg.jpg.b64` | `assets/images/chat-bg.jpg` |
| `chat-panel-bg.png.b64` | `assets/images/chat-panel-bg.png` |
| `luca-avatar.png.b64` | `assets/images/luca-avatar.png` |
| `luca-avatar-special.png.b64` | `assets/images/luca-avatar-special.png` |

## 復元方法（Linux）

```bash
mkdir -p assets/images
base64 -d docs/image-assets-base64/chat-bg.jpg.b64 > assets/images/chat-bg.jpg
base64 -d docs/image-assets-base64/chat-panel-bg.png.b64 > assets/images/chat-panel-bg.png
base64 -d docs/image-assets-base64/luca-avatar.png.b64 > assets/images/luca-avatar.png
base64 -d docs/image-assets-base64/luca-avatar-special.png.b64 > assets/images/luca-avatar-special.png
```

## 復元方法（macOS）

```bash
mkdir -p assets/images
base64 -D -i docs/image-assets-base64/chat-bg.jpg.b64 -o assets/images/chat-bg.jpg
base64 -D -i docs/image-assets-base64/chat-panel-bg.png.b64 -o assets/images/chat-panel-bg.png
base64 -D -i docs/image-assets-base64/luca-avatar.png.b64 -o assets/images/luca-avatar.png
base64 -D -i docs/image-assets-base64/luca-avatar-special.png.b64 -o assets/images/luca-avatar-special.png
```

## 復元方法（Windows PowerShell）

```powershell
New-Item -ItemType Directory -Force assets/images
[IO.File]::WriteAllBytes("assets/images/chat-bg.jpg", [Convert]::FromBase64String((Get-Content "docs/image-assets-base64/chat-bg.jpg.b64" -Raw)))
[IO.File]::WriteAllBytes("assets/images/chat-panel-bg.png", [Convert]::FromBase64String((Get-Content "docs/image-assets-base64/chat-panel-bg.png.b64" -Raw)))
[IO.File]::WriteAllBytes("assets/images/luca-avatar.png", [Convert]::FromBase64String((Get-Content "docs/image-assets-base64/luca-avatar.png.b64" -Raw)))
[IO.File]::WriteAllBytes("assets/images/luca-avatar-special.png", [Convert]::FromBase64String((Get-Content "docs/image-assets-base64/luca-avatar-special.png.b64" -Raw)))
```

## 注意

このフォルダの `.b64` ファイルは、画像を受け渡すためのバックアップです。実際のアプリ配信時は、復元した画像ファイルを `assets/images/` に置いてください。
