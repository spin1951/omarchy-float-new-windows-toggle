# omarchy-float-new-windows-toggle

An ON/OFF toggle for [Omarchy](https://omarchy.org/) that makes every newly
opened window float instead of tile. Turn it ON and new windows open
floating; turn it OFF and Hyprland's default tiling behavior comes back.

It shows up in the Omarchy launcher menu under **Toggle -> Float New Windows**.

## How it works

- `bin/omarchy-hyprland-window-float-new-toggle` writes or removes
  `~/.local/state/omarchy/toggles/hypr/float-new-windows.lua`, which
  contains a single Hyprland window rule:

  ```lua
  o.window(".*", { float = true })
  ```

  That state directory is already auto-sourced by Omarchy's built-in
  `default.hypr.toggles` on every Hyprland reload, so no core Hyprland
  config files are touched. The script then runs `hyprctl reload`.

- `menu-snippet.jsonc` is the row added to the launcher's Toggle submenu,
  using `omarchy-hyprland-toggle-enabled` (already shipped with Omarchy)
  to show a checkmark when the toggle is ON.

Nothing under `/usr/share/omarchy/` is modified, so this survives
`omarchy update`.

## Install

```bash
git clone https://github.com/<you>/omarchy-float-new-windows-toggle.git
cd omarchy-float-new-windows-toggle
./install.sh
```

This copies the script to `~/.local/bin/` and adds the menu entry to
`~/.config/omarchy/extensions/omarchy-menu.jsonc` (creating the file if it
doesn't exist yet, and skipping the insert if the entry is already there).

## Uninstall

```bash
rm ~/.local/bin/omarchy-hyprland-window-float-new-toggle
rm -f ~/.local/state/omarchy/toggles/hypr/float-new-windows.lua
# then remove the "trigger.toggle.float-new-windows" line from
# ~/.config/omarchy/extensions/omarchy-menu.jsonc
hyprctl reload
```

## Manual use

```bash
omarchy-hyprland-window-float-new-toggle   # flips it on/off
omarchy-hyprland-toggle-enabled float-new-windows  # check current state (exit 0 = on)
```
