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

  function toggle() {
    if (!toggleProc.running) toggleProc.running = true
  }

  WidgetButton {
    id: button
    bar: root.bar
    text: "󰖲"
    active: root.active
    tooltipText: root.active
      ? "Float new windows: ON — click to disable"
      : "Float new windows: OFF — click to enable"
    onPressed: root.toggle()
  }
}
