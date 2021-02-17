#!LUA
--[[
 * @file init.lua
 * ABSTRACT HERE <<
 *
 * $Id$
 *
 * (C) Copyright 2020 Amplex, fm@amplex.dk
--]]

local hs = _G.hs
require 'hs.ipc'
package.path = package.path:gsub('/thm%-dotfiles/files/', '/.hammerspoon/');
print("searchpath ", package.path)
hs.loadSpoon("SpoonInstall")
local spoon = _G.spoon
local Install = spoon.SpoonInstall

local hyper = {"cmd","alt","ctrl","shift"}

local winCache = {_="INIT"}
local function findMyWindows(pr)
  winCache = {_="FIND"}
  _G.winCache = winCache
  for _,w in ipairs(hs.window.allWindows()) do
    local ix;
    local app = w:application():name()
    local frame = w:frame()
    if app == "Preview" then
      ix = 1;
    elseif app == "iTerm2" and frame.h > 500 and frame.x < 500 then
      ix = 2;
    elseif app == "iTerm2" and frame.h > 500 and frame.x > 500 then
      ix = 3;
    elseif app == "Google Chrome" and frame.w > 1000 and not winCache[4]
      and w:screen():position() == 0 and not w:title():match("^GridLight") then
      ix = 4;
    elseif app == "Google Chrome" and (frame.w > 1000 or w:title():match("^GridLight")) then
      ix = 5;
    elseif app == "Safari" then
      ix = 6;
    elseif app == "Finder" then
      ix = 7;
    end
    ix = ix or "_"
    if pr == "print" then
      print("Found ix,w", ix, frame.x, frame.h, app, w:title())
    end
    winCache[ix] = w
  end
end

local function findWindow(i)
  return function()
    if not winCache[i] then
      findMyWindows()
    end
    local w =winCache[i]
    if w then
      print("Window:", i, w);
      w:raise()
      w:focus()
      local pos = w:frame()
      hs.mouse.setAbsolutePosition({x=pos.x+50, y=pos.y+50})
      spoon.MouseCircle:show()
    end
  end
end

for i=1, 7 do
   hs.hotkey.bind(hyper, tostring(i), findWindow(i))
end
hs.hotkey.bind(hyper, "0", function() findMyWindows("print") end)

local savedWin = {}
local function WHFunc(key)
  local win = hs.window.frontmostWindow()
  if not win then return end

  local dir
  local cur = savedWin[win:id()]
  local last = cur and cur.key
  if win:id() == winCache[2]:id() then
    dir = 'left';
  elseif win:id() == winCache[3]:id() then
    dir = 'right';
  end
  if not cur then
    cur = {key=key, frame=win:frame():copy()}
    savedWin[win:id()] = cur
  end
  cur.key = key
  local frame
  if key == last and cur and cur.done then
    frame = cur.frame
    savedWin[win:id()] = nil
  elseif key == 'F' then
    cur.done = true
    frame = win:screen():frame():copy()
  elseif key == 'H' then
    cur.done = true
    frame = win:frame():copy()
    frame.y = win:screen():frame().y
    frame.h = win:screen():frame().h
  elseif key == "W" and not cur.scale and win:frame().w < (win:screen():frame().w // 2) then
    cur.scale = 1
    cur.done = nil
    frame = win:frame():copy()
    local delta = frame.w
    frame.w = frame.w * 7 // 4
    delta = frame.w - delta
    frame.x = dir == 'left' and frame.x or frame.x - (dir and delta or (delta // 2))
    frame:fit(win:screen():frame())
  elseif key == "W" then
    cur.done = true
    frame = win:frame():copy()
    frame.x = win:screen():frame().x
    frame.w = win:screen():frame().w
  end

  if frame then
    win:setFrame(frame, 0)
  end
end
hs.hotkey.bind(hyper, "W", function() WHFunc("W") end)
hs.hotkey.bind(hyper, "H", function() WHFunc("H") end)
hs.hotkey.bind(hyper, "F", function() WHFunc("F") end)

local mspoon = hs.loadSpoon('LightAndScroll'):start()
hs.hotkey.bind(hyper, "S", function()
  local pos = mspoon.menuBar:frame()
  mspoon.menuBar:popupMenu(pos)
end)

Install:andUse('ReloadConfiguration', {start=true})
Install:andUse('RoundedCorners',      {start=true})

local clock
Install:andUse('AClock',              {fn=function(s) clock = s s:init():hide() end})
hs.hotkey.bind(hyper, "C", function() clock:toggleShow() end)

Install:andUse("MouseCircle", {
  config={color=hs.drawing.color.lists().Crayons.Tangerine},
  hotkeys={
    show={hyper, "M"},
  },
})

Install:andUse("FadeLogo", {
  config = {
    default_run = 1.0,
    zoom_scale_timer = 0.05,
    run_time = 0.1,
    fade_in_time = 0.2,
    fade_out_time = 0.3,
  },
  start = true
})


hs.timer.doAfter(0.6, findMyWindows)
print "\n\n-------------------------------------\n\n"

-- vim: set sw=2 sts=2 et:
