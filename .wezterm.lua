
local wezterm = require "wezterm"
local act = wezterm.action

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local zoomed = tab.active_pane.is_zoomed and '[Z] ' or ''
  dims = ''
  if 1 or tab.active_pane.height ~= wezterm.GLOBAL.height or tab.active_pane.width ~= wezterm.GLOBAL.width then
     dims = '  ['..tab.active_pane.height..'×'..tab.active_pane.width..']'
     wezterm.GLOBAL.height = tab.active_pane.height
     wezterm.GLOBAL.width = tab.active_pane.width
  end
  return zoomed .. tab.active_pane.title .. dims
end)


wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  return " "..(pane.user_vars.itit or pane.title).." "
end)

wezterm.on('toast-test', function(window, pane)
  print 'toast-test 1'
  window:toast_notification('wezterm', 'Toast!', nil, 1500)
  print 'toast-test 2'
end)

wezterm.on('window-config-reloaded', function(window, pane)
  window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
end)

wezterm.on('select-special-at-cursor', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local select_save = overrides.selection_word_boundary
  overrides.selection_word_boundary = " \t\n\"'"
  window:set_config_overrides(overrides)
  window:perform_action(act.SelectTextAtMouseCursor 'Word', pane)
  overrides.selection_word_boundary = select_save
  window:set_config_overrides(overrides)
  print("select set was:", select_save)
end)

-- local stdFont = 'Monaco'
-- local stdFont = 'Monaco for Powerline'
local stdFont = 'Monaco Nerd Font Mono'
-- local stdFont = 'JetBrains Mono'
-- local stdFont = 'Monospace'
local function setFont(font, params)
  return wezterm.font_with_fallback({font or stdFont, 'Arial Unicode MS'}, params)
end

return {
  font = setFont(nil, {weight="Regular"}),
  -- color_scheme = "Atelier Cave Light (base16)",
  -- color_scheme = "Atelier Dune Light (base16)",
  color_scheme = "Novelty-fm2",
  enable_scroll_bar = true,
  use_fancy_tab_bar = true,
  window_background_opacity = 0.95,
  font_size=9,
  line_height=1.1,
  cell_width=0.9,
  bold_brightens_ansi_colors = false,
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  font_rules = {
     {italic=true,      font=setFont(nil, {style='Oblique'})},
     {intensity='Bold', font=setFont(nil, {weight='DemiBold'})},
  },
  window_padding = { left = '0.5cell', right = '0.5cell', top = '0.2cell', bottom = '0.2cell', },
  visual_bell = { fade_in_duration_ms = 125, fade_out_duration_ms = 25,},--target = 'CursorColor', },
  detect_password_input = true,
  -- enable_kitty_keyboard = true,
  scrollback_lines = 99000,

  colors = {
    quick_select_label_bg = { Color = 'Thistle' },
    quick_select_label_fg = { Color = 'Black' },
    quick_select_match_bg = { AnsiColor = 'Yellow' },
    quick_select_match_fg = { Color = 'Black' },

  },
  quick_select_patterns = { [['[^']*']], [["[^"]*"]], },

  skip_close_confirmation_for_processes_named = {},
  selection_word_boundary = " \t\n{}[]()\"'`/:;=",
  bypass_mouse_reporting_modifiers = 'ALT',

  mouse_bindings = {
    { event = { Up = { streak = 2, button = 'Right' } }, mods = 'NONE', action = act.PasteFrom 'Clipboard'  },
    { event = { Up = { streak = 4, button = 'Left'  } }, mods = 'NONE', action = act.EmitEvent 'select-special-at-cursor'  },
  },


  keys = {
    { key = 'L',         mods = 'CTRL',      action = act.ShowDebugOverlay },
    { key = 'w',         mods = 'CMD',       action = act.CloseCurrentPane { confirm = true }, },
    { key = 'F11',       mods = 'CMD|ALT',   action = act.ToggleFullScreen },
    { key = 'z',         mods = 'CMD',       action = act.TogglePaneZoomState },
    { key = 's',         mods = 'CMD',       action = act.ActivatePaneDirection 'Next' },
    { key = 'UpArrow',   mods = 'SHIFT|CMD', action = act.ScrollByLine(-3) },
    { key = 'DownArrow', mods = 'SHIFT|CMD', action = act.ScrollByLine(3) },
    { key = 'LeftArrow', mods = 'CMD',       action = act.ActivateTabRelative(-1) },
    { key = 'RightArrow',mods = 'CMD',       action = act.ActivateTabRelative(1) },
    { key = '"',         mods = 'SHIFT|CMD', action = act.SplitVertical{} },
    { key = '%',         mods = 'SHIFT|CMD', action = act.SplitHorizontal{} },
    { key = 'r',         mods = 'SHIFT|CMD', action = act.EmitEvent 'toast-test' },
    { key = 'r',         mods = 'CMD',       action = act.ResetTerminal },

  },

}

