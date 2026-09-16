#!/bin/bash
# Installs the "Float New Windows" Omarchy toggle for the current user.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_TARGET="$HOME/.local/bin/omarchy-hyprland-window-float-new-toggle"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"

mkdir -p "$HOME/.local/bin"
install -m 755 "$SCRIPT_DIR/bin/omarchy-hyprland-window-float-new-toggle" "$BIN_TARGET"
echo "Installed $BIN_TARGET"

if [[ -f $MENU_FILE ]] && grep -q '"trigger.toggle.float-new-windows"' "$MENU_FILE"; then
  echo "Menu entry already present in $MENU_FILE"
else
  mkdir -p "$(dirname "$MENU_FILE")"
  [[ -f $MENU_FILE ]] || printf '{\n}\n' >"$MENU_FILE"
  ENTRY='  "trigger.toggle.float-new-windows": {"icon":"󰖲","label":"Float New Windows","checked":"omarchy-hyprland-toggle-enabled float-new-windows","action":"omarchy-hyprland-window-float-new-toggle"},'
  # Insert the entry just before the final closing brace of the JSONC object.
  awk -v entry="$ENTRY" '
    { lines[NR] = $0 }
    END {
      last = NR
      while (last > 0 && lines[last] !~ /}/) last--
      for (i = 1; i < last; i++) print lines[i]
      print entry
      for (i = last; i <= NR; i++) print lines[i]
    }
  ' "$MENU_FILE" >"$MENU_FILE.tmp"
  mv "$MENU_FILE.tmp" "$MENU_FILE"
  echo "Added menu entry to $MENU_FILE"
fi

echo "Done. Find it in the launcher under Toggle -> Float New Windows."
