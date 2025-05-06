--[[
* @file init.lua
* ABSTRACT HERE <<
*
* (C) Copyright 2020 Amplex, fm@themadsens.dk
--]]
local hs = _G.hs
local image = require "hs.image"

local inspect = require('inspect') or function(s) return tostring(s) end
local function noMetas(item, path) return path[#path] ~= inspect.METATABLE and item end
--local pm = function(val, opt) return _G.pp(val, opt, true) end
local pp = function(val, opt, showMeta)
  if not opt then
    opt = {depth=1}
  elseif type(opt) == 'number' then
    opt = {depth=opt}
  end
  if not showMeta then
    opt.process = noMetas
  end
  return inspect(val, opt)
end

--local color = require "hs.drawing.color"
local toggleLight
local spoon = {
  name = "LightAndScroll",
  version = "1.0",
  author = "Flemming <hammerspoon@themadsens.dk>",
  homepage = "https://github.com/Hammerspoon/Spoons",
  license = "MIT - https://opensource.org/licenses/MIT",
}
setmetatable(spoon, spoon)
spoon.__gc = function(t)
  t:stop()
end

local segs = {
  topNode = 1197,
  server = "demo.gridlight.dk",
  url       = "http://gridlight-demo:8029",
  wsurl     = "ws://gridlight-demo:8029/greenwise/subscribe",
  user = "importer",
  pw = "importer",
  {name = "Fri", node = 1199, on=1},
  {name = "Kantine",  node = 1210, on=1},
  {name = "Kælder",   node = 1209},
}
local segs__ = {
  topNode = 1197,
  server = "demo.gridlight.dk",
  user = "knaptryk",
  pw = "hestsakspapir",
  {name = "Fri", node = 1199, on=1},
  {name = "Kantine",  node = 1210, on=1},
  {name = "Kælder",   node = 1209},
}
local segs_ = {
  topNode = 4,
  server = "localhost",
  user = "knaptryk",
  pw = "hestsakspapir",
  {name = "2900100006", node = 386, on=1},
  {name = "133-2",  node = 90, on=1},
  {name = "133",   node = 5},
}

local mePath = (function() return debug.getinfo(2, "S").source end)():sub(2):match("(.*/)")
--local imgOn = hs.image.imageFromPath(mePath.."/bulb-on.png"):size({h=16, w=16})
--local imgOff = hs.image.imageFromPath(mePath.."/bulb-off.png"):size({h=16, w=16})
local imgScroll = hs.image.imageFromPath(mePath.."/scroll.tiff"):size({h=16, w=16})
local dark={white=0.6}
local light={red=1.0, green=1.0, blue=0.0}
local imgOn = hs.canvas.new({x=0,y=0,h=32,w=32}):appendElements({type='circle',fillColor=light}):imageFromCanvas()
local imgOff = hs.canvas.new({x=0,y=0,h=32,w=32}):appendElements({type='circle',fillColor=dark}):imageFromCanvas()
print(mePath, hs.ipc.cliInstall(mePath))

local triplet = [[ASCII:
......................
..1###############2...
..#################6..
..##################..
..4###############36..
...8***************8..
......................
..A###############B...
..#################F..
..##################..
..D###############CF..
...H***************H..
......................
..J###############K...
..#################O..
..##################..
..M###############LO..
...Q***************Q..
......................]]

function spoon.setDisplayN(o)
  local black  = {alpha=1}
  local stroke = {alpha=1}
  local dim    = {white=0.5, alpha=1}
  local bright = {red=1.0, green=1.0, blue=0.0, alpha=1}
  local function col(on)
    local c = on and bright or dim
    return {fillColor=c, strokeColor=c, lineWidth=1, antialias=0}
  end

  black = {fillColor=black, strokeColor=stroke}
  local img = image.imageFromASCII(triplet, {
    col(o[1]), black, black, col(o[2]), black, black, col(o[3]), black, black
  })
  spoon.menuBar:setIcon(img, false)
end

local function setDisplay()
  local shadow = {white=0.3, alpha=1}
  local dim    = {red=0.4, green=0.6, blue=0.4}
  local bright = {red=0.4, green=1.0, blue=0.0}
  local img = hs.canvas.new({x=0, y=0, h=19, w=22})

  local function led(i, on)
    local ix = i-1
    img[i*2-1] = {
      type='rectangle', strokeWidth=0, antialias=false,
      fillColor=shadow, strokeColor=shadow,
      frame={x=3, y=ix*6+2, w=15, h=4}
    }
    img[i*2] = {
      type='rectangle', strokeWidth=0, antialias=false,
      fillColor=on and bright or dim, strokeColor=on and bright or dim,
      frame={x=2, y=ix*6+1, w=15, h=4}
    }
  end
  for i,seg in ipairs(segs) do led(i, seg.on) end
  spoon.menuBar:setIcon(img:imageFromCanvas(), false)
end

local function setSegs()
  for _,seg in ipairs(segs) do
    spoon.menu[seg.ix].checked = not not seg.on
  end
  setDisplay()
end

-- From https://gist.github.com/ParatechX/c03c1146f7cd719dbfd65a337c7228f3
local oldMousePosition = {}
local scrollIntensity = 1

local buttonDownMouseTracker = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function(e)
  oldMousePosition = hs.mouse.getAbsolutePosition()

  local dX = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
  local dY = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])

  hs.eventtap.scrollWheel({0 - dX * scrollIntensity , dY * scrollIntensity }, {})
  -- put the mouse back
  hs.mouse.setAbsolutePosition(oldMousePosition)
  return true
end)

local eventTypes = hs.eventtap.event.types
local buttonDownToScroll = hs.eventtap.new({eventTypes.flagsChanged, eventTypes.otherMouseDown, eventTypes.otherMouseUp},
                                           function(e)
  if e:getFlags().ctrl or e:getButtonState(2) then
    buttonDownMouseTracker:start()
    spoon.menuBar:setIcon(imgScroll)
  else
    buttonDownMouseTracker:stop()
    setDisplay(spoon.scrollOn)
  end
end)

function spoon.start()
  if spoon.menuBar then spoon.stop() end

  local menu
  menu = {
    {title="Console", checked=false, fn=function()
      local show = not hs.console.hswindow()
      menu[1].checked = show
      if show then
        hs.openConsole()
        hs.focus()
      else
        hs.closeConsole()
      end
    end},
    {title="Clear console", fn=function() hs.console.setConsole('') end},
    {title="Ctrl scroll", checked=true, fn=function()
      spoon.scrollOn = not spoon.scrollOn
      menu[3].checked = spoon.scrollOn
      if spoon.scrollOn then
        buttonDownToScroll:start()
      else
        buttonDownToScroll:stop()
      end
    end},
    {title="-"},
    {title="Hammerspoon", menu = {
      {title="Help ...", fn=function() hs.hsdocs() end},
      {title="Preferences ...", fn=function() hs.openPreferences() end},
      {title="Updates ...", fn=function() hs.checkForUpdates() end},
      {title="About ...", fn=function() hs.openAbout() end},
      {title="Reload config", fn=function() hs.reload() end},
      {title="Exit", fn=function() os.exit() end},
    }},
    {title="-"},
    {title="Refresh", fn=function() spoon.refresh() end},
  }

  for _,seg in ipairs(segs) do
    table.insert(menu, {title=seg.name, offStateImage=imgOff, onStateImage=imgOn,
                        checked=seg.on, seg=seg, fn=toggleLight})
    seg.ix = #menu
  end

  spoon.menuBar = hs.menubar.new():setMenu(function()
    menu[1].checked = hs.console.hswindow() ~= nil
    if menu[1].checked then
      hs.openConsole(true)
    end
    return menu
  end)
  --[[:setTitle(hs.styledtext.new("Text", {
    font=hs.styledtext.defaultFonts.label,
    paragraphStyle={maximumLineHeight=9}
  }))]]

  spoon.menu = menu
  buttonDownToScroll:start()

  --setSegs() -- FIXME: SHOULD BE: refresh() 
  spoon.refresh()
  return spoon
end

local function makeUrl(url, repl)
  repl.user = segs.user
  repl.pw = segs.pw
  return url:gsub('{{([%w_-]+)}}',repl)
end

-- local wsNotice
function spoon.refresh()
  local url = makeUrl((segs.url or ("https://"..segs.server)).."/gridlight/rs/segment/below/{{node}}", {node=segs.topNode})
  local headers = {['content-type']='application/json'}
  headers.authorization = "Basic "..hs.base64.encode(segs.user..":"..segs.pw)
  hs.http.asyncGet(url, headers, function(code_, body, rethdrs_)
    print("URL", url, "CODE", code_, pp(headers), pp(rethdrs_), "#BODY", #body)
    local r, s = pcall(hs.json.decode, body)
    -- print(r, pp(s,2))
    if r and s then
      local segOn = {}
      for _,seg in pairs(s) do
        if seg.online then
          segOn[seg.nodeId] = seg.state ~= 'off'
        end
      end
      for _,seg in ipairs(segs) do
        seg.on = segOn[seg.node]
      end
      print(pp(segs,2), pp(segOn, 2))
      setSegs()
      spoon.wsNotify()
    end
  end)
  setSegs()
end

function toggleLight(_, menuItem)
  print(pp(menuItem, 2))
  local seg = menuItem.seg
  local url = makeUrl((segs.url or ("https://"..segs.server)).."/gridlight/rs/segment/action/{{node}}", {node=seg.node})
  local headers = {['content-type']='application/json'}
  headers.authorization = "Basic "..hs.base64.encode(segs.user..":"..segs.pw)
  --seg.on = not seg.on
  --menuItem.checked = seg.on
  print(url, hs.http.doRequest(url.."?action="..(seg.on and "off" or "on"), "PUT", "", headers))
  --setDisplay()
end

function spoon.notified(msg)
  if msg.messages then
    local segOn = {}
    for _,seg in pairs(msg.messages) do
      if seg.data and seg.data.event and seg.data.event.type == "light" then
        segOn[seg.data.event.nodeId] = seg.data.event.entities:find('"state":"on"', 1, true) ~= nil
      end
    end
    for _,seg in ipairs(segs) do
      if segOn[seg.node] ~= nil then
        seg.on = segOn[seg.node]
      end
    end
    print(pp(segOn,2))
    setSegs()
  end
end

spoon.pingTimer = hs.timer.delayed.new(330, function()
  print("WS Timeout")
  spoon.refresh()
end)
spoon.pingSender = hs.timer.delayed.new(30, function()
  if wsNotice then
      wsNotice:send(hs.json.encode {
      type = "navigation", username = spoon.user,
      data = {type = "node", id = segs.topNode, pagerefresh = true},
    }, false)
  end
end)
function spoon.wsNotify()
  if wsNotice then
    wsNotice:close()
  end
  --local headers = { authorization = "Basic "..hs.base64.encode(spoon.user..":"..segs.pw) }
  --wsNotice = hs.websocket.new("wss://"..segs.server.."/changes",  headers, function(typ, msg)
  local ws
  local wsUrl = segs.wsurl or ("wss://"..segs.server.."/changes")
  print("WS open", wsUrl)
  ws = hs.websocket.new(wsUrl, function(typ, msg)
    print("WS:", typ, msg)
    if typ == "open" then
      print("WS open", ws)
    elseif typ == "closed" then
      print("WS closed", ws)
      if wsNotice == ws then
        wsNotice = nil
      end
    elseif typ == "received" then
      if msg == "authenticate" then
        print(msg)
        --hs.timer.doAfter(0.2, function()
          local auth = hs.json.encode({user=segs.user, pw=segs.pw})
          print("Sending auth", ws, ws:status(), pp(auth))
          ws:send(auth, false)
        --end)
      elseif msg == "authenticated" then
        wsNotice = ws
        print("WS authenticated", ws)
      else
        local r, s = pcall(hs.json.decode, msg)
        print("spoon.notified", r, msg)
        if s.messages and #s.messages > 0 and s.messages[1].type == "session" then
          hs.timer.doAfter(0.1, function()
            print("sending sub")
            ws:send(hs.json.encode {
              type = "navigation", username = spoon.user,
              data = {type = "node", id = segs.topNode, pagerefresh = true},
            }, false)
          end)
        elseif s.status == "ok" then
          -- print("WS Heartbeat")
          spoon.pingTimer.start()
          -- Periodidally set up subscr as heartbeat
          spoon.pingSender.start()
        else
          spoon.notified(s)
        end
      end
    end
  end)
  spoon.pingTimer.start()
  spoon.pingSender.start()
end

function spoon.stop()
  if wsNotice then
    wsNotice:close()
  end
end

return spoon
-- vim: set sw=2 sts=2 et:
