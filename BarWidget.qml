import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

// Bar button mirroring the "Float New Windows" launcher toggle. Both read
// and write the same flag file the toggle script and menu entry use
// (~/.local/state/omarchy/toggles/hypr/float-new-windows.lua, sourced by
// Omarchy's default.hypr.toggles on Hyprland reload), so this widget, the
// launcher menu row, and the CLI stay in sync no matter which one is used.
// The toggle logic is inlined (not shelling out to the CLI script) so this
// widget works even if only the plugin — not the separate install.sh — was
// installed.
//
// Left click only ever affects *new* windows (the persistent setting).
// Right click is a separate, one-shot action: it flips the floating state
// of every window already open on the current workspace, and leaves the
// persistent setting untouched.
BarWidget {
  id: root
  moduleName: "spin1951.float-new-windows"

  readonly property string flagPath: Quickshell.env("HOME") + "/.local/state/omarchy/toggles/hypr/float-new-windows.lua"
  property bool active: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  FileView {
    id: flagFile
    path: root.flagPath
    watchChanges: true
    printErrors: false
    onLoaded: root.active = true
    onLoadFailed: root.active = false
    onFileChanged: reload()
  }

  Process {
    id: toggleProc
    command: ["bash", "-c", "\
      set -e; \
      flag=\"$HOME/.local/state/omarchy/toggles/hypr/float-new-windows.lua\"; \
      if [[ -f $flag ]]; then \
        rm -f \"$flag\"; state=off; \
      else \
        mkdir -p \"$(dirname \"$flag\")\"; \
        printf '%s\\n' \
          '-- Float every newly opened window instead of tiling it.' \
          'o.window(\".*\", { float = true })' > \"$flag\"; \
        state=on; \
      fi; \
      hyprctl reload >/dev/null; \
      omarchy-notification-send -g 󰖲 \"Float new windows: $state\" \
    "]
  }

  // hl.dsp.window.float (Hyprland's Lua dispatcher, default action "toggle")
  // is tried first; togglefloating is the pre-Lua fallback for older
  // Hyprland builds. Built through printf into a variable rather than
  // interpolated straight into the dispatch argument, so the address never
  // has to sit inside nested double quotes.
  Process {
    id: toggleWorkspaceProc
    command: ["bash", "-c", "\
      set -e; \
      ws=$(hyprctl activeworkspace -j | jq -r '.id'); \
      count=0; \
      while IFS= read -r addr; do \
        [[ -n $addr ]] || continue; \
        lua_call=$(printf 'hl.dsp.window.float({ window = \"address:%s\" })' \"$addr\"); \
        hyprctl dispatch \"$lua_call\" >/dev/null 2>&1 || \
          hyprctl dispatch togglefloating \"address:$addr\" >/dev/null 2>&1; \
        count=$((count+1)); \
      done < <(hyprctl clients -j | jq -r --argjson ws \"$ws\" '.[] | select(.workspace.id == $ws) | .address'); \
      omarchy-notification-send -g 󰖲 \"Toggled floating for $count window(s) in this workspace\" \
    "]
  }

  function toggle() {
    if (!toggleProc.running) toggleProc.running = true
  }

  function toggleExistingInWorkspace() {
    if (!toggleWorkspaceProc.running) toggleWorkspaceProc.running = true
  }

  WidgetButton {
    id: button
    bar: root.bar
    text: "󰖲"
    useActiveColor: false
    dimmed: !root.active
    tooltipText: (root.active ? "New windows float — click to disable" : "New windows tile — click to enable")
      + "\nRight click: toggle floating for windows already open here"
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) root.toggleExistingInWorkspace()
      else if (mouseButton === Qt.LeftButton) root.toggle()
    }
  }
}
