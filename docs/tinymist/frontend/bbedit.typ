#import "/docs/tinymist/frontend/mod.typ": *

#show: book-page.with(title: [Tinymist BBEdit Support for Typst])

Run and configure tinymist in #link("https://www.barebones.com/products/bbedit/")[BBEdit] (14.0 or later, tested with 15.5 and 16.0) for Typst.

= Features

See #link("https://github.com/Myriad-Dreamin/tinymist#features")[Tinymist Features] for a list of features. BBEdit uses the language server for completion, diagnostics, hover, go to definition, symbol search, rename and formatting; it has no menu for server commands, so the preview runs as a #cross-link("/feature/preview.typ", reference: <background-preview>)[background preview] in a browser.

= Finding Executable
<finding-executable>

#include "common-finding-executable.typ"

BBEdit starts language servers with a minimal `PATH` that does not include Homebrew or Cargo directories, so put a symlink to the executable into `~/Library/Application Support/BBEdit/Language Servers/` or use the proxy below, which looks there as well.

= Setup Server

BBEdit has no built-in Typst language, so a codeless language module provides it, with the language server declared inside the module. Copy the files from #github-link("/editors/bbedit")[editors/bbedit] into BBEdit's application support folder:

```bash
cd ~/Library/Application\ Support/BBEdit
cp editors/bbedit/Typst.plist "Language Modules/"
cp editors/bbedit/tinymist-bbedit "Language Servers/"
cp editors/bbedit/Typst.json "Language Servers/Configuration/"
cp "editors/bbedit/Sync Typst with Preview.sh" Scripts/
```

- `Typst.plist` is the language module: `.typ` files, syntax colouring, headings in the function menu, and the `BBLMLanguageServerInfo` entry that names the server, so nothing needs to be set in the Languages preferences.
- `tinymist-bbedit` is a small Python proxy around `tinymist lsp`, see below.
- `Typst.json` holds the server configuration (`initializationOptions` and `workspaceConfigurations`, see BBEdit's #link("https://www.barebones.com/support/bbedit/lsp-notes.html")[language server notes]).
- `Sync Typst with Preview.sh` is a script for the Scripts menu that scrolls the preview to the cursor.

Restart BBEdit: it reads language modules at launch. Open a `.typ` file; the status bar shows the language as "Typst" and the server starts.

= Tips

== Getting Preview Feature

`Typst.json` enables the #cross-link("/feature/preview.typ", reference: <background-preview>)[background preview] on port 23635. Open #link("http://127.0.0.1:23635")[http://127.0.0.1:23635] in a browser next to BBEdit; it re-renders as you type. Clicking in the preview jumps to the source in BBEdit.

The jump needs the proxy. BBEdit opens the file named in the `window/showDocument` request but ignores the selection, so the cursor would land on line 1. `tinymist-bbedit` intercepts these requests, opens the file at the position with the `bbedit` command-line tool (installed from BBEdit's application menu) and answers the server itself. Once BBEdit honours the selection, set `ServerCommand` in `Typst.plist` to `tinymist` and put a symlink to the executable into `Language Servers/`.

The other direction: while you type, the preview follows the edit position shortly after the last keystroke, taken from the `textDocument/didChange` notifications. Moving the cursor without editing is invisible to the server, since LSP has no cursor notification; for that, "Sync Typst with Preview" in the Scripts menu scrolls the preview to the cursor (assign it a shortcut in the Menus & Shortcuts preferences). BBEdit cannot invoke server commands itself, so the script hands the position to the proxy over a Unix socket, and the proxy issues the `tinymist.scrollPreview` command.

== Working with Multiple-File Projects

BBEdit has no workspace folders and cannot pin a main file, so on its own the server would compile each chapter file by itself. Put a `typst.toml` into the project's root directory that names the main file:

```toml
[package]
name = "my-notes"
version = "0.1.0"
entrypoint = "src/main.typ"
```

Whenever BBEdit opens or edits a file, the proxy looks for the nearest `typst.toml` above it and pins its `entrypoint` with `tinymist.pinMain`; tinymist takes the manifest's directory as root. Switching between files of different projects switches the main file, and so the preview, without a restart. A file with no manifest above it is compiled on its own.

== Working under Power-Saving Mode or with Resource-consumed Projects
<working-with-resource-consumed-projects>
#include "syntax-only.typ"

= Extra Settings

Edit `Typst.json` and restart BBEdit. See #github-link("/editors/neovim/Configuration.md")[Tinymist Server Configuration] for the available keys.

Command-line arguments for the compiler go into `typstExtraArgs`, for example `["--input", "variant=private"]` to preview a variant selected with `sys.inputs`; put the key into both `initializationOptions` and `workspaceConfigurations`.

= Troubleshooting

BBEdit does not restart a language server that exits; after replacing `tinymist-bbedit` or changing `Typst.json`, restart BBEdit. The server log is `LanguageServerProtocol-Typst.txt` in BBEdit's Logs folder (application menu, Folders), see BBEdit's #link("https://www.barebones.com/support/bbedit/lsp-notes.html")[language server notes].
