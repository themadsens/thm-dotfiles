# Local Zellij 0.46.0 patches

A numbered series against the Zellij v0.46.0 source tarball. Apply them in order:

```bash
cd zellij-0.46.0
for p in ~/.config/zellij/patches/00*.patch; do patch -p1 < "$p"; done
```

Patches 0001 and 0004–0008 change the built-in `bars` plugin, which is compiled into the
`zellij` binary. Build the plugin first, copy it into the bundled assets, then build zellij:

```bash
cargo build --release --target wasm32-wasip1 -p bars
cp target/wasm32-wasip1/release/bars.wasm zellij-utils/assets/plugins/bars.wasm
cargo build --release --bin zellij
```

This needs the Rust toolchain pinned in `rust-toolchain.toml` (1.95.0) with the `wasm32-wasip1`
target. The result is installed as `~/.local/bin/zellij` (ahead of Homebrew's in PATH).

## 0001 – Hostname instead of "Zellij" in the tab bar and compact bar

Adds a `prefix` setting to the tab-bar and compact-bar plugins, replacing the fixed " Zellij "
label. The server replaces `{hostname}` in plugin settings with the short hostname:

```kdl
tab-bar location="zellij:bars" { role "tab-bar"; prefix " {hostname} "; }
```

## 0002 – Window title without the session name

The host terminal's window title no longer starts with `<session name> | `; it shows only the
focused pane's title.

## 0003 – Window title updates when switching tabs

Each tab remembered the last title it sent and only sent a new one when it changed, so going back
to a tab left the previous tab's title in the window. The title is now sent again whenever a
client enters a tab.

## 0004 – Bars not dimmed in a locked nested session

Zellij 0.46 dims a nested session's tab bar and compact bar unless the outer zellij has
descended into it. With the outer zellij only locked, the active tab could not be seen. The bars
now dim only for zellij's other dimming case.

## 0005 – `tooltip_hint` setting for the compact bar

`tooltip_hint "false"` hides the "<key> > Tooltip >" text on the right of the compact bar, while
the tooltip key keeps working.

## 0006 – `tooltip_position` setting for the compact bar

Places the key hints tooltip in a corner: `"bottom-left"` (default), `"bottom-right"`,
`"top-left"` or `"top-right"`.

## 0007 – Fix for key hints that stay open

Entering a mode starts the tooltip pane, which takes a moment to load. Leaving the mode (eg. with
Esc) before it appeared left it open. A tooltip that arrives after its mode was left is now closed
as soon as it appears.

## 0008 – Shorter "Open in editor" hint

The scroll mode hint for EditScrollback says "Open in editor" instead of "Open pane scrollback in
editor", to keep the hints box narrow.

## 0009 – Full scrollback in EditScrollback

While a pane was scrolled up, the scrollback dump (used by EditScrollback, `e`/`v` in scroll mode)
left out the lines below the current view. The dump now includes them, and the editor still opens
at the scroll position.

## 0010 – `titles_on_single_pane` setting

With `pane_frame_style "titles"`, zellij leaves out the title line when a tab has a single pane,
which also hides the search pattern while searching. This setting keeps it:

```kdl
ui {
    pane_frames {
        titles_on_single_pane true
    }
}
```

## 0011 – `Run` bindings in the mode hints

The hints box only lists a fixed set of built-in actions for each mode, so a key bound to `Run`
(such as `y` → `copy-rich` in session mode) was missing. Keys whose first action is `Run`, with or
without `background true`, are now added at the end of the list for every mode except Normal and
Locked. Each one is labelled with the command's file name.

## 0012 – `zellij action` keeps working after a session rename

Shells get the session name in `ZELLIJ_SESSION_NAME` when they start, and a rename doesn't change
it in shells that are already running. With more than one session running, `zellij action` in
such a shell looked for a socket under the old name and hung forever, because the client retries
the connection every 50 ms. This happened to a `PROMPT_COMMAND` calling `zellij action
rename-tab` after a rename. Two changes:

- The server also gives panes `ZELLIJ_SESSION_ID`, the session's stable id, which is the name of
  its socket and doesn't change on rename. `zellij action`, `zellij subscribe`, `zellij prompt`
  and `zellij --layout` inside a session find the session by this id first, and fall back to
  `ZELLIJ_SESSION_NAME`.
- When the session's socket doesn't exist, the command-line client reports
  "Session '…' not found" and exits instead of retrying forever (Unix only).
