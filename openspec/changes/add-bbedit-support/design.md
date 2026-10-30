## Context

BBEdit starts a language server named in a language module's `BBLMLanguageServerInfo` with a minimal `PATH`, speaks LSP over stdio, and offers completion, diagnostics, hover, definition, symbols, rename and formatting. It has no UI for server commands (`workspace/executeCommand`), opens the file from `window/showDocument` but ignores the selection, sends no cursor notifications, and has no workspace folders. Tinymist's browser preview runs as a background preview on a fixed port; the editor-to-preview direction needs `tinymist.scrollPreview`, the preview-to-editor direction arrives as `window/showDocument` with a selection.

## Goals / Non-Goals

**Goals:**
- Typst files are recognized, coloured and served by tinymist after copying files into BBEdit's application support folder, without preference changes.
- The browser preview follows the editor while typing and on demand from a menu script, and a click in the preview opens the source at the right line.
- Multi-file projects compile from their main file, found through `typst.toml`.
- Everything in the proxy is removable once BBEdit gains the missing client features.

**Non-Goals:**
- A BBEdit package or installer; the documented `cp` lines suffice.
- Replacing the browser preview by a PDF viewer (separate change).
- Windows or Linux; BBEdit is macOS only.

## Decisions

### 1. A codeless language module names the server

`Typst.plist` declares the language (`.typ`, syntax colouring patterns, headings in the function menu) and sets `ServerCommand` to the proxy. BBEdit reads language modules at launch, so no preference change is needed; `Typst.json` in `Language Servers/Configuration/` carries `initializationOptions` and `workspaceConfigurations`, including the background preview on port 23635.

Alternative considered:
- Ship only documentation on setting `tinymist` in the Languages preferences. Rejected: without a language module BBEdit has no Typst language to attach a server to.

### 2. A stdio proxy instead of server-side workarounds

`tinymist-bbedit` is a Python script that spawns `tinymist lsp`, forwards messages in both directions whole (never splitting a message when injecting one), and intercepts what BBEdit cannot handle. Keeping the adaptation in the editor directory leaves the server unchanged and makes the proxy disposable: once BBEdit honours `showDocument` selections and offers commands, `ServerCommand` can point at `tinymist` directly.

Alternative considered:
- Teach the server BBEdit quirks behind a client-name check. Rejected: BBEdit-specific code in every editor's binary, and the quirks are the client's, not the protocol's.

### 3. `window/showDocument` is answered by the proxy

The proxy opens the file at the requested line and column with the `bbedit` command-line tool and returns `{"success": true}` to the server itself; BBEdit never sees the request. Without the tool the request is forwarded, and BBEdit opens the file at line 1.

### 4. Cursor positions reach the proxy over a Unix socket

BBEdit scripts receive the document path and selection in environment variables. "Sync Typst with Preview.sh" writes path, line and column to `~/Library/Caches/tinymist-bbedit.sock`; the proxy turns them into `tinymist.scrollPreview`. While typing, the proxy derives the position from the last `textDocument/didChange` range and scrolls 0.3 s after the last keystroke, since LSP carries no cursor notification.

Alternative considered:
- AppleScript polling of BBEdit's selection. Rejected: polling cost and latency for a workaround the editor may make obsolete.

### 5. Positions snap to resolvable text

The server resolves a position only directly behind a character of markup or math text. The proxy keeps the open documents' text from `didOpen`/`didChange` and moves each position to the nearest such place on the same line, then on neighbouring lines, before sending it. Blank lines, list markers and the start of a word therefore scroll the preview as well.

### 6. `typst.toml` selects the main file

On every `didOpen` and `didChange` the proxy looks for the nearest `typst.toml` above the file and, when its `entrypoint` differs from the pinned one, issues `tinymist.pinMain`; tinymist takes the manifest's directory as root. Changing `typstExtraArgs` through `didChangeConfiguration` would recreate the project and drop the background preview's document, so command-line arguments stay in `Typst.json`.

### 7. Exit without a crash report

Turning the server off or quitting BBEdit closes the proxy's stdin while a pump thread holds the buffer lock; interpreter finalization then aborts with SIGABRT. The proxy exits with `os._exit` after the server is gone and terminates `tinymist` if it outlives the closed pipe by five seconds, so the preview port is free for the next start.

## Risks / Trade-offs

- [The proxy depends on BBEdit's current behavior] -> Documented per workaround with the condition under which it can go.
- [Python 3 and the `bbedit` tool must be present] -> Both come with BBEdit's install menu and Apple's developer tools; the proxy degrades to forwarding without them.
- [`editors/bbedit/README.md` is generated from `bbedit.typ`] -> Regenerate with `node scripts/link-docs.mjs`; the mapping is in place.
- [One background preview port for all projects] -> Switching projects switches the preview's document; two previews at once are out of scope.

## Migration Plan

1. Add the language module, configuration, proxy and sync script.
2. Add the docs page, book and README entries, and the link-docs mapping; regenerate the Markdown.
3. Verify with BBEdit 15.5 and 16.0: server starts, preview follows typing and the menu script, click in the preview opens the line, chapter files compile from the main file.

No rollback concerns: files are additive and live under `editors/bbedit/`.

## Open Questions

- Whether the proxy's snapping logic should move into the server's `scrollPreview` handler, where every editor would benefit.
