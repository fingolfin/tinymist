## ADDED Requirements

### Requirement: Typst is a BBEdit language served by tinymist
After copying `Typst.plist`, `tinymist-bbedit` and `Typst.json` into BBEdit's application support folder and restarting BBEdit, `.typ` files SHALL be recognized as Typst with syntax colouring and headings in the function menu, and tinymist SHALL be started for them without changes to BBEdit's preferences.

#### Scenario: Opening a Typst file
- **WHEN** a `.typ` file is opened
- **THEN** the status bar shows the language "Typst"
- **AND** completion, diagnostics, hover, go to definition, symbols, rename and formatting come from tinymist

#### Scenario: Executable outside BBEdit's PATH
- **GIVEN** `tinymist` installed by Homebrew or Cargo
- **WHEN** the proxy starts
- **THEN** it finds the executable in `Language Servers/`, the Homebrew or the Cargo directory without the user editing `PATH`

### Requirement: Clicks in the preview open the source line
A click in the background preview SHALL open the clicked source file in BBEdit at the clicked line and column.

#### Scenario: Jump from the preview
- **WHEN** the preview sends `window/showDocument` with a selection
- **THEN** the proxy opens the file at that position through the `bbedit` tool and answers the request with success
- **AND** BBEdit does not receive the request

#### Scenario: `bbedit` tool missing
- **WHEN** the command-line tool is not installed
- **THEN** the request is forwarded to BBEdit, which opens the file at line 1

### Requirement: The preview follows the editor
The background preview SHALL scroll to the edit position shortly after typing stops and to the cursor when the user runs "Sync Typst with Preview" from the Scripts menu.

#### Scenario: Typing
- **WHEN** the user edits a document and pauses for 0.3 s
- **THEN** the preview scrolls to the start of the last change

#### Scenario: Menu script
- **WHEN** the user runs "Sync Typst with Preview" with the cursor on a line
- **THEN** the preview scrolls to that line

#### Scenario: Position without resolvable text
- **WHEN** the position is on a blank line, a list marker or the start of a word
- **THEN** the proxy moves it to the nearest markup or math text on the same or a nearby line before scrolling

### Requirement: `typst.toml` selects the main file
For a file with a `typst.toml` above it, tinymist SHALL compile the manifest's `entrypoint` with the manifest's directory as root; files without a manifest compile on their own.

#### Scenario: Opening a chapter file
- **GIVEN** `notes/typst.toml` with `entrypoint = "main.typ"`
- **WHEN** `notes/chapters/one.typ` is opened or edited
- **THEN** diagnostics and the preview come from compiling `notes/main.typ`

#### Scenario: Switching projects
- **WHEN** the user switches from a file of one project to a file of another
- **THEN** the main file and the preview switch without restarting the server

### Requirement: Server shutdown leaves no crash report
When BBEdit turns the language server off or quits, the proxy SHALL exit cleanly and the `tinymist` process SHALL end, freeing the preview port.

#### Scenario: Quitting BBEdit
- **WHEN** BBEdit closes the proxy's standard input
- **THEN** the proxy exits without a macOS crash report
- **AND** `tinymist` is terminated if it is still running five seconds later

### Requirement: Documentation is generated from the Typst source
The BBEdit editor page SHALL live in `docs/tinymist/frontend/bbedit.typ`; `editors/bbedit/README.md` SHALL be produced by `node scripts/link-docs.mjs` and not edited by hand.

#### Scenario: Docs check
- **WHEN** `node scripts/link-docs.mjs --check` runs
- **THEN** it reports no difference for `editors/bbedit/README.md`
