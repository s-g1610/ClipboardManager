# ClipboardManager

A lightweight offline macOS menu bar app for retaining clipboard history.

## Features

- **Lives in the menu bar** — no Dock icon, always accessible from the top-right status bar
- **Retains last 10, 20, or 50 clipboard items** — configurable from the menu
- **All content types** — text, images, and file URLs
- **Click to re-copy** — select any item from the menu to copy it back to clipboard
- **Deduplication** — same content won't appear twice; it moves to the top
- **Clear All** — wipe the entire history in one click
- **Launch at Login** — toggle from the menu to auto-start on reboot
- **Fully offline** — all data stored locally in `~/Library/Application Support/ClipboardManager/`
- **Persists across reboots** — history survives restarts

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ (to build)

## Build & Run

1. Clone the repo
2. Open `ClipboardManager.xcodeproj` in Xcode
3. Select **My Mac** as the run destination
4. Press **⌘R**

The clipboard icon will appear in your menu bar.

## Install as a persistent app

Build a Release version and copy to Applications:

```bash
xcodebuild -project ClipboardManager.xcodeproj -scheme ClipboardManager -configuration Release build CODE_SIGNING_ALLOWED=NO
cp -R ~/Library/Developer/Xcode/DerivedData/ClipboardManager-*/Build/Products/Release/ClipboardManager.app ~/Applications/
open ~/Applications/ClipboardManager.app
```

Then enable **Launch at Login** from the menu bar dropdown.

## Storage

| Type | Location |
|------|----------|
| History index | `~/Library/Application Support/ClipboardManager/history.json` |
| Images | `~/Library/Application Support/ClipboardManager/images/` |
| Settings | `UserDefaults` (`com.personal.ClipboardManager`) |
