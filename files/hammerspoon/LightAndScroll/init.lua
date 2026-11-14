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

-- Mirrors the 'demo' config in kaelderlys/spiffs-root/kaelderlys.lua
local segs__ = {
  topNodes = {1197, 1476}, -- Amplex Lighting, Carl Blochsgade
  server = "demo.gridlight.dk",
  url       = "http://gridlight-demo:8029",
  wsurl     = "ws://gridlight-demo:8029/greenwise/subscribe",
  user = "importer",
  pw = "importer",
  -- nodes: segments shown by this item; ctrl: node the toggle action is sent to (default nodes[1])
  {name = "Fri",      nodes = {1477, 1478}, ctrl = 1476, on=1}, -- Carl Blochsgade 11 + 29
  {name = "Kantine",  nodes = {1210}, on=1},
  {name = "Kælder",   nodes = {1209}},
}
local segs = {
  topNode = 1197,
  url       = "http://gridlight-demo:8029",
  wsurl     = "ws://gridlight-demo:8029/greenwise/subscribe",
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

  -- Accept the older single-node config shape too (topNode / node)
  segs.topNodes = segs.topNodes or {segs.topNode}
  for _,seg in ipairs(segs) do
    seg.nodes = seg.nodes or {seg.node}
  end

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

local function baseUrl()
  return segs.url or ("https://"..segs.server)
end

local function authHeaders()
  return {
    ['content-type'] = 'application/json',
    authorization = "Basic "..hs.base64.encode(segs.user..":"..segs.pw),
  }
end

-- Navigation (subscribe) message, as sent by kaelderlys.lua: needs the customerId
-- of the subscribed node, which comes from the segment/below REST reply.
local function sendNav(ws, top)
  print("WS navigation", top, segs.customerId and segs.customerId[top])
  ws:send(hs.json.encode {
    type = "navigation",
    customerId = segs.customerId and segs.customerId[top],
    data = {type = "node", id = top},
  }, false)
end

function spoon.refresh()
  local byNode = {}
  for _,seg in ipairs(segs) do
    for _,node in ipairs(seg.nodes) do byNode[node] = seg end
  end
  segs.bySeg = {}          -- segment id -> menu seg (light messages carry the segment id)
  segs.customerId = {}     -- top node -> customerId
  local segOn, pending, anyOk = {}, #segs.topNodes, false

  for _,top in ipairs(segs.topNodes) do
    local url = baseUrl().."/gridlight/rs/segment/below/"..top
    hs.http.asyncGet(url, authHeaders(), function(code, body, rethdrs_)
      print("URL", url, "CODE", code, "#BODY", body and #body)
      local r, s = pcall(hs.json.decode, body)
      if code // 100 == 2 and r and type(s) == 'table' then
        anyOk = true
        for _,seg in ipairs(s) do
          segs.customerId[top] = segs.customerId[top] or seg.customerId
          local cur = byNode[seg.nodeId]
          if cur then
            segs.bySeg[seg.id] = cur
            if seg.online then
              segOn[cur] = segOn[cur] or seg.state ~= 'off'
            end
          end
        end
      else
        print("REFRESH failed for", top, code, body)
      end
      pending = pending - 1
      if pending == 0 then
        for _,seg in ipairs(segs) do
          seg.on = segOn[seg]
        end
        print(pp(segs, 2), pp(segs.customerId, 2))
        setSegs()
        if anyOk then
          spoon.wsNotify()
        else
          spoon.reconnect:start()
        end
      end
    end)
  end
  setSegs()
end

function toggleLight(_, menuItem)
  local seg = menuItem.seg
  local ctrl = seg.ctrl or seg.nodes[1]
  local url = baseUrl().."/gridlight/rs/segment/action2/"..ctrl.."?action="..(seg.on and "off" or "on")
  print(url, hs.http.doRequest(url, "PUT", hs.json.encode {password = segs.pw}, authHeaders()))
end

function spoon.notified(msg)
  local changed = false
  for _,m in ipairs(msg.messages or {}) do
    if m.type == "light" and type(m.data) == 'table' then
      print("WS light message:", hs.json.encode(m.data))
      local seg = segs.bySeg and segs.bySeg[m.data.id]
      if seg then
        seg.on = m.data.state ~= "off"
        changed = true
      end
    end
  end
  if changed then
    setSegs()
  end
end

spoon.pingTimer = hs.timer.delayed.new(330, function()
  print("WS Timeout")
  spoon.refresh()
end)
-- Periodically resend the subscription as a heartbeat
spoon.pingSender = hs.timer.delayed.new(30, function()
  for top, ws in pairs(spoon.ws or {}) do
    sendNav(ws, top)
  end
end)
-- Re-login + reconnect shortly after a socket drops (kaelderlys does the same after 1.5s)
spoon.reconnect = hs.timer.delayed.new(5, function()
  print("WS reconnect")
  spoon.refresh()
end)

-- One websocket per top node, opened one after the other, like kaelderlys.lua
function spoon.wsNotify()
  spoon.stop()
  spoon.wsGen = (spoon.wsGen or 0) + 1
  local gen = spoon.wsGen
  local wsUrl = segs.wsurl or ("wss://"..segs.server.."/changes")

  local function open(ix)
    local top = segs.topNodes[ix]
    if not top or gen ~= spoon.wsGen then return end
    local ws
    local authenticated = false
    print("WS open", ix, top, wsUrl)
    ws = hs.websocket.new(wsUrl, function(typ, msg)
      if gen ~= spoon.wsGen then return end   -- stale socket from an earlier wsNotify()
      print("WS:"..ix, typ, msg)
      if typ == "closed" or typ == "fail" then
        if spoon.ws[top] == ws then
          spoon.ws[top] = nil
        end
        spoon.reconnect:start()
      elseif typ == "received" then
        if msg == "authenticate" then
          ws:send(hs.json.encode({user=segs.user, pw=segs.pw}), false)
        elseif msg == "authenticated" then
          spoon.ws[top] = ws
          sendNav(ws, top)
          if not authenticated then
            authenticated = true
            hs.timer.doAfter(0.5, function() open(ix + 1) end)
          end
        else
          local r, s = pcall(hs.json.decode, msg)
          if not r or type(s) ~= 'table' then
            print("WS bad message", msg)
            return
          end
          if s.status == "ok" then
            spoon.pingTimer:start()
            spoon.pingSender:start()
          end
          for _,m in ipairs(s.messages or {}) do
            if m.type == "session" then
              sendNav(ws, top)
              break
            end
          end
          spoon.notified(s)
        end
      end
    end)
    table.insert(spoon.sockets, ws)
  end

  open(1)
  spoon.pingTimer:start()
  spoon.pingSender:start()
end

function spoon.stop()
  local sockets = spoon.sockets or {}
  spoon.sockets, spoon.ws = {}, {}
  for _,ws in ipairs(sockets) do
    pcall(ws.close, ws)
  end
end

return spoon
-- vim: set sw=2 sts=2 et:
