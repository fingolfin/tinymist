## Why

BBEdit (macOS) has had a language server client since version 14, but no Typst language: no syntax colouring, no server, no preview. Its LSP client also lacks three things tinymist relies on in other editors: it cannot invoke server commands, it ignores the selection in `window/showDocument`, and it has no workspace folders. A plain `tinymist lsp` therefore gives completion and diagnostics, but no preview that follows the editor, no jump from the preview into the source, and no main file for multi-file projects.

## What Changes

- Add `editors/bbedit/` with a codeless language module (`Typst.plist`) that declares the Typst language and names the language server, a server configuration (`Typst.json`), and a Python proxy (`tinymist-bbedit`) between BBEdit and `tinymist lsp`.
- The proxy answers `window/showDocument` requests itself through the `bbedit` command-line tool, so clicks in the preview open the file at the right line; it listens on a Unix socket for cursor positions from a Scripts-menu script and issues `tinymist.scrollPreview`; it follows the edit position from `textDocument/didChange` while typing; and it pins the `entrypoint` of the nearest `typst.toml` as main file with `tinymist.pinMain`, switching projects when the user switches files.
- Positions sent to the preview are moved to the nearest resolvable text on the same or a nearby line, since the server resolves only positions directly behind markup or math text.
- Add the editor documentation `docs/tinymist/frontend/bbedit.typ`, the generated `editors/bbedit/README.md`, and the entries in the docs book, the main README and `scripts/link-docs.mjs`.

## Capabilities

### New Capabilities

- `bbedit-editor-support`: Defines what the BBEdit integration provides: language module, server start, preview synchronization in both directions, and main-file selection by `typst.toml`.

### Modified Capabilities

- None.

## Impact

- New files under `editors/bbedit/` and `docs/tinymist/frontend/`; one entry each in `README.md`, `docs/tinymist/book.typ`, `docs/tinymist/frontend/main.typ` and `scripts/link-docs.mjs`.
- No change to the Rust crates; the proxy uses only the existing LSP protocol and the `tinymist.scrollPreview` and `tinymist.pinMain` commands.
- Requires Python 3 (ships with macOS developer tools) and BBEdit's `bbedit` command-line tool for the jump from the preview.
