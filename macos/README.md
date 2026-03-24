# Mo.app — macOS Finder Integration

Mo.app is a lightweight AppleScript wrapper that enables macOS Finder's **"Open With"** menu to work with `mo`.

## Install

Requires `mo` CLI to be installed separately (e.g. `brew install k1LoW/tap/mo`).

```bash
# Build Mo.app in the project root
make app

# Copy to /Applications and register with Launch Services
make install-app
```

After installation, `.md` files will show **Mo** in Finder's "Open With" menu.

## How It Works

macOS Finder only recognizes `.app` bundles for "Open With" and sends file paths via Apple Events (`kAEOpenDocuments`), not command-line arguments. Mo.app bridges this gap:

1. Finder sends `kAEOpenDocuments` with selected file paths
2. Mo.app receives the event via AppleScript's `on open` handler
3. Mo.app calls `mo --open <files...>` to forward to the CLI
4. If a mo server is already running, files are added to the existing session

Double-clicking Mo.app (without files) runs `mo --open` to restore the last session and open the browser.

## Supported File Extensions

`.md`, `.markdown`, `.mdown`, `.mkd`, `.mdx`

Mo.app registers as an **Alternate** handler (`LSHandlerRank: Alternate`), so it won't override your default Markdown editor.

## mo CLI Lookup Order

Mo.app searches for the `mo` binary in this order:

1. `/opt/homebrew/bin/mo` (Homebrew on Apple Silicon)
2. `/usr/local/bin/mo` (Homebrew on Intel)
3. `which mo` (fallback to PATH)

If not found, a dialog is shown with installation instructions.

## Files

```
macos/
├── mo-wrapper.applescript   # AppleScript source
├── Info.plist.tmpl          # Info.plist template (__VERSION__ placeholder)
└── build-app.sh             # Build script (osacompile + codesign)
```

## Notes

- Mo.app is ad-hoc signed. If downloaded from the internet, macOS Gatekeeper may block it. Run `xattr -d com.apple.quarantine /Applications/Mo.app` or right-click → "Open" to bypass.
- The build uses a temp directory internally because `osacompile` cannot write directly to iCloud Drive paths.
