#!/bin/sh
# BBEdit script: scroll the tinymist preview to the cursor position.
# Install into ~/Library/Application Support/BBEdit/Scripts/ and run it
# from the Scripts menu (assign a shortcut in Menus & Shortcuts).

# BBEdit pipes the selection in; not needed
cat > /dev/null

# last request and nc's exit status, for troubleshooting
LOG="$HOME/Library/Caches/tinymist-bbedit.log"
SOCKET="$HOME/Library/Caches/tinymist-bbedit.sock"

[ -n "$BB_DOC_PATH" ] || exit 0
printf '%s\t%s\t%s\n' "$BB_DOC_PATH" "$BB_DOC_SELSTART_LINE" "$BB_DOC_SELSTART_COLUMN" \
  | nc -U "$SOCKET" 2>>"$LOG"
echo "$(date '+%F %T') $BB_DOC_PATH:$BB_DOC_SELSTART_LINE:$BB_DOC_SELSTART_COLUMN nc=$?" >>"$LOG"
