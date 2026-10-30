## 1. Language Module and Configuration

- [x] 1.1 Add `editors/bbedit/Typst.plist`: `.typ` suffix, colouring patterns, headings in the function menu, `BBLMLanguageServerInfo` with `ServerCommand` `tinymist-bbedit`.
- [x] 1.2 Add `editors/bbedit/Typst.json` with `initializationOptions` and `workspaceConfigurations`, background preview on port 23635.

## 2. Proxy

- [x] 2.1 Add `editors/bbedit/tinymist-bbedit`: spawn `tinymist lsp` (looked up in `Language Servers/`, Homebrew and Cargo directories), pump messages whole in both directions.
- [x] 2.2 Answer `window/showDocument` by opening the file at the selection with the `bbedit` tool; forward when the tool is missing.
- [x] 2.3 Listen on `~/Library/Caches/tinymist-bbedit.sock` for `path\tline\tcolumn` and issue `tinymist.scrollPreview`; add `editors/bbedit/Sync Typst with Preview.sh` that writes the cursor there.
- [x] 2.4 Follow the edit position from `textDocument/didChange` 0.3 s after the last change.
- [x] 2.5 Keep document text from `didOpen`/`didChange` and snap positions to the nearest resolvable markup or math text before scrolling.
- [x] 2.6 Find the nearest `typst.toml` above opened and edited files and pin its `entrypoint` with `tinymist.pinMain` when it changes.
- [x] 2.7 Exit with `os._exit` once the server is gone and terminate `tinymist` if it survives the closed pipe for five seconds.
- [x] 2.8 Log pinned main files, scroll requests with their snapped positions and failed commands to `~/Library/Caches/tinymist-bbedit.log`.

## 3. Documentation

- [x] 3.1 Add `docs/tinymist/frontend/bbedit.typ`: features, finding the executable, setup, tips (preview, multi-file projects, syntax-only mode), extra settings, troubleshooting.
- [x] 3.2 Add the page to `docs/tinymist/book.typ` and `docs/tinymist/frontend/main.typ`, the editor to the main `README.md`, and the mapping to `scripts/link-docs.mjs`.
- [x] 3.3 Regenerate `editors/bbedit/README.md` with `node scripts/link-docs.mjs` and confirm `--check` passes.

## 4. Validate

- [x] 4.1 With BBEdit 15.5 and 16.0: open a `.typ` file, status bar shows "Typst", completion and diagnostics work.
- [x] 4.2 Preview at `http://127.0.0.1:23635` follows typing and the "Sync Typst with Preview" script; a click in the preview opens the source line in BBEdit.
- [x] 4.3 In a project with `typst.toml`, opening a chapter file compiles the entrypoint; switching to a file of another project switches the main file.
- [x] 4.4 Turning the server off or quitting BBEdit leaves no crash report and frees the preview port.
- [x] 4.5 `node scripts/link-docs.mjs --check`.
