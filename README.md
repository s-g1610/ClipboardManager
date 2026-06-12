# ClipboardManager

> A lightweight, fully offline macOS menu bar app that remembers everything you copy.

Never lose a copied item again. ClipboardManager silently runs in your menu bar, capturing everything you copy — text, images, and files — and lets you paste any of it back with a single click.

---

## Why ClipboardManager?

macOS only remembers your **last copied item**. The moment you copy something new, the previous item is gone forever. ClipboardManager fixes that — it keeps a running history of everything you've copied, right in your menu bar, always one click away.

- **No cloud. No account. No subscription.** Everything stays on your Mac.
- **224 KB app size.** Runs in ~15–20 MB of RAM.
- **Zero configuration needed.** Install and forget — it just works.

---

## Features

| Feature | Detail |
|---|---|
| **Menu bar access** | Lives in the top-right status bar — no Dock icon, never in your way |
| **Clipboard history** | Retains last 10, 20, or 50 items — your choice |
| **All content types** | Text, images, and file URLs |
| **One-click re-copy** | Click any item to copy it back instantly |
| **Most recent on top** | Latest copied item always appears first |
| **Deduplication** | Same content won't appear twice — it moves to the top |
| **Clear All** | Wipe the entire history in one click |
| **Launch at Login** | Toggle from the menu — auto-starts on every reboot |
| **Fully offline** | No internet connection ever required |
| **Persists across reboots** | History survives restarts and shutdowns |

---

## How it works

ClipboardManager monitors your system clipboard every 0.5 seconds. When it detects a change, it reads and stores the new content locally:

- **Text** is saved in a JSON file
- **Images** are saved as PNG files
- **File URLs** (from Finder) are stored as paths

All data lives in `~/Library/Application Support/ClipboardManager/` — never leaves your machine.

---

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ (to build from source)

---

## Build & Run

```bash
git clone https://github.com/s-g1610/ClipboardManager.git
cd ClipboardManager
open ClipboardManager.xcodeproj
```

1. Select **My Mac** as the run destination in Xcode
2. Press **⌘R**

The clipboard icon will appear in your menu bar immediately.

---

## Install as a persistent app (Release build)

```bash
xcodebuild -project ClipboardManager.xcodeproj \
  -scheme ClipboardManager \
  -configuration Release \
  build CODE_SIGNING_ALLOWED=NO

cp -R ~/Library/Developer/Xcode/DerivedData/ClipboardManager-*/Build/Products/Release/ClipboardManager.app \
  ~/Applications/

open ~/Applications/ClipboardManager.app
```

Then enable **Launch at Login** from the menu bar dropdown so it starts automatically on every boot.

---

## Storage

| Type | Location |
|---|---|
| History index | `~/Library/Application Support/ClipboardManager/history.json` |
| Saved images | `~/Library/Application Support/ClipboardManager/images/` |
| Settings (history limit) | `UserDefaults` — `com.personal.ClipboardManager` |

---

## Project structure

```
ClipboardManager/
├── ClipboardManagerApp.swift   — App entry point, MenuBarExtra scene
├── ClipboardItem.swift         — Data model (type, content, timestamp)
├── ClipboardStore.swift        — Pasteboard monitor + local persistence
└── MenuBarView.swift           — SwiftUI menu UI
```

---

## Roadmap

- [ ] Global hotkey to open history (e.g. `⌘⇧V`)
- [ ] Search through clipboard history
- [ ] Pinned / favourite items
- [ ] Auto-detect content type (URLs, emails, phone numbers, code)
- [ ] Clipboard rules (e.g. never save from password managers)
- [ ] iCloud sync (opt-in)

---

## Contributing

PRs and issues welcome. This started as a personal tool — if you have ideas that would make it genuinely useful for others, open an issue.

---

## License

MIT
