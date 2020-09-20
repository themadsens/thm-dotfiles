#!LUA
--[[
 * @file init.lua
 * ABSTRACT HERE << 
 *
 * $Id$
 *
 * (C) Copyright 2020 Amplex, fm@amplex.dk
--]]

require 'hs.ipc'
hs.loadSpoon("SpoonInstall")
local Install = spoon.SpoonInstall
local allofthem = {"cmd","alt","ctrl","shift"}

local winCache = {_="INIT"}
function findMyWindows(pr)
  winCache = {_="FIND"}
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
    elseif app == "Google Chrome" and frame.w > 1000 then
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

function findWindow(i)
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
   hs.hotkey.bind({"cmd", "shift"}, tostring(i), findWindow(i))
end
hs.hotkey.bind({"cmd", "shift"}, tostring("0"), function() findMyWindows("print") end)


Install:andUse('ReloadConfiguration', {start=true})
Install:andUse('RoundedCorners',      {start=true})
Install:andUse('LightAndScroll',      {start=true})

Install:andUse("MouseCircle", {
  config={color=hs.drawing.color.lists().Crayons.Tin},
  hotkeys={
    show={{"cmd", "shift"}, "M"},
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
