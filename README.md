# omarchy-float-new-windows-toggle

An ON/OFF toggle for [Omarchy](https://omarchy.org/) that makes every newly
opened window float instead of tile. Turn it ON and new windows open
floating; turn it OFF and Hyprland's default tiling behavior comes back.

Two independent ways to use it, both reading/writing the same state so they
always agree:

1. **Launcher menu toggle** — a row under **Toggle -> Float New Windows**
   in the Omarchy launcher.
2. **Bar widget** — a clickable icon in the status bar. Left click toggles
   the setting for *new* windows, same as the menu row. Right click is a
   separate, one-shot action: it flips the floating state of every window
   already open on the current workspace, without touching the setting
   itself.

Install either one, or both.

## How it works

Both pieces write or remove
`~/.local/state/omarchy/toggles/hypr/float-new-windows.lua`, which contains
a single Hyprland window rule:

```lua
o.window(".*", { float = true })
```

That state directory is already auto-sourced by Omarchy's built-in
`default.hypr.toggles` on every Hyprland reload, so no core Hyprland config
files are touched — each side just runs `hyprctl reload` after flipping the
flag file. Nothing under `/usr/share/omarchy/` is modified, so this
survives `omarchy update`.

## Install: launcher menu toggle

```bash
git clone https://github.com/spin1951/omarchy-float-new-windows-toggle.git
cd omarchy-float-new-windows-toggle
./install.sh
```

This copies `bin/omarchy-hyprland-window-float-new-toggle` to
`~/.local/bin/` and adds the `trigger.toggle.float-new-windows` row to
`~/.config/omarchy/extensions/omarchy-menu.jsonc` (creating the file if it
doesn't exist yet, and skipping the insert if the entry is already there).

Uninstall:

```bash
rm ~/.local/bin/omarchy-hyprland-window-float-new-toggle
rm -f ~/.local/state/omarchy/toggles/hypr/float-new-windows.lua
# then remove the "trigger.toggle.float-new-windows" line from
# ~/.config/omarchy/extensions/omarchy-menu.jsonc
hyprctl reload
```

Manual use:

```bash
omarchy-hyprland-window-float-new-toggle           # flips it on/off
omarchy-hyprland-toggle-enabled float-new-windows   # check current state (exit 0 = on)
```

## Install: bar widget

This repo is itself a valid Omarchy shell plugin (`manifest.json` +
`BarWidget.qml` at the repo root), so it installs the same way any
third-party Omarchy plugin does:

```bash
omarchy plugin add https://github.com/spin1951/omarchy-float-new-windows-toggle.git --enable
```

Pick a bar section (left/center/right) when prompted, or move it later:

```bash
omarchy bar move spin1951.float-new-windows --section right
```

The widget's toggle logic is self-contained (it doesn't depend on the
`bin/` script or menu entry above), so it works whether or not you've also
run `install.sh`.

Uninstall:

```bash
omarchy plugin remove spin1951.float-new-windows
```

## Repo layout

```
manifest.json    # plugin manifest (bar-widget)
BarWidget.qml    # the bar widget itself
bin/             # the CLI toggle script
menu-snippet.jsonc
install.sh       # installs bin/ + the menu entry
```
