
local wezterm = require "wezterm"

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  -- itit "$Tty - $(cut -c1-3 <<< ${AMPROOT##*/}) - ${p##*/}"
  -- stln "-- $HostnTty $(ttprompt 2)- ${AMPROOT##*/} - $p --"
  local tty, root, pwd = tab.active_pane.title:match('%-%- +[^:]*%:(%w*) *[^-]*%- ([%w_-]*) %- (.*) %-%-$')
  --print(tab.active_pane.title, tty, root, pwd)
  return pwd and tty.." - "..root:sub(1,3).." - "..pwd:match("%/?([^/]*)$") or tab.active_pane.title
end)

local stdFont = 'Monaco'
-- local stdFont = 'MonacoB for Powerline'
-- local stdFont = 'Monaco Nerd Font Mono'
-- local stdFont = 'JetBrains Mono'
local function setFont(font, params)
  return wezterm.font_with_fallback({font or stdFont, 'JetBrains Mono'}, params)
end


return {
  -- color_scheme = "Atelier Cave Light (base16)",
  -- color_scheme = "Atelier Dune Light (base16)",
  color_scheme = "Novelty-fm2",
  enable_scroll_bar = true,
  use_fancy_tab_bar = true,
  font = setFont(stdFont, {weight = 'Regular', stretch='Normal'}),
  font_size=10.5,
  line_height=0.9,
  cell_width=0.9,
  bold_brightens_ansi_colors = false,
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
  font_rules = {
     {italic=true,      font=setFont(nil, {style='Oblique'})},
     {intensity='Bold', font=setFont(nil, {weight='DemiBold'})},
  },
  window_padding = { left = '0.5cell', right = '0.5cell', top = '0.2cell', bottom = '0cell', },
  visual_bell = { fade_in_duration_ms = 125, fade_out_duration_ms = 25,},--target = 'CursorColor', },


  skip_close_confirmation_for_processes_named = {},
  bypass_mouse_reporting_modifiers = 'ALT',
  keys = {
    { key = 'L', mods = 'CTRL',  action = wezterm.action.ShowDebugOverlay },
    { key = 'w', mods = 'CMD',   action = wezterm.action.CloseCurrentPane { confirm = true }, },
  },

}

