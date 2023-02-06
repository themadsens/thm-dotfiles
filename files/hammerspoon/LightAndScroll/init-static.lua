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
local refresh, toggleLight
local spoon = {
  name = "LightAndScroll",
  version = "1.0",
  author = "Flemming <hammerspoon@themadsens.dk>",
  homepage = "https://github.com/Hammerspoon/Spoons",
  license = "MIT - https://opensource.org/licenses/MIT",
  user = "amplexfm",
  pw = "ccswe124",
}
setmetatable(spoon, spoon)
spoon.__gc = function(t)
  t:stop()
end

local segs = {
  topNode = 1197,
  server = "demo.gridlight.dk",
  {name = "Kantine",  node = 1210, on=1},
  {name = "Udendørs", node = 1199, on=1},
  {name = "Kælder",   node = 1209},
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
local buttonDownToScroll = hs.eventtap.new({ eventTypes.flagsChanged }, function(e)
  if e:getFlags().ctrl then
    buttonDownMouseTracker:start()
    spoon.menuBar:setIcon(imgScroll)
  else
    buttonDownMouseTracker:stop()
    setDisplay(spoon.scrollOn)
  end
end)

function spoon.start()
  if spoon.menuBar then spoon:stop() end

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
    {title="Clear console", fn=function()
      hs.console.setConsole('')
    end},
--[[{title="Ctrl scroll", checked=true, fn=function()
      spoon.scrollOn = not spoon.scrollOn
      menu[3].checked = spoon.scrollOn
      if spoon.scrollOn then
        buttonDownToScroll:start()
      else
        buttonDownToScroll:stop()
      end
    end}, ]]
    {title="-"},
    --{title="Refresh", fn=refresh},
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
    refresh() -- OK. So synchronous for now
    return menu
  end)
  --[[:setTitle(hs.styledtext.new("Text", {
    font=hs.styledtext.defaultFonts.label,
    paragraphStyle={maximumLineHeight=9}
  }))]]

  spoon.menu = menu
  buttonDownToScroll:start()

  refresh()
end

local function setSegs()
  for _,seg in ipairs(segs) do
    spoon.menu[seg.ix].checked = not not seg.on
  end
  setDisplay()
end

local function makeUrl(url, repl)
  repl.user = spoon.user
  repl.pw = spoon.pw
  return url:gsub('{{([%w_-]+)}}',repl)
end

local cookie
local wsNotice
function refresh()
  local url = makeUrl("https://"..segs.server.."/gridlight/rs/segment/below/{{node}}", {node=segs.topNode})
  local headers = {['content-type']='application/json'}
  if cookie then
    headers.cookie = cookie
  else
    headers.authorization = "Basic "..hs.base64.encode(spoon.user..":"..spoon.pw)
  end
  --hs.http.asyncGet(url, headers, function(_, body, rethdrs)
  local _, body, rethdrs = hs.http.get(url, headers)
    --print(url, pp(headers), pp(rethdrs), body)
    if rethdrs['set-cookie'] then
      cookie = rethdrs['set-cookie']
    end
    local r, s = pcall(hs.json.decode, body)
    --print(r, pp(s,2))
    if r then
      local segOn = {}
      for _,seg in pairs(s) do
        segOn[seg.nodeId] = seg.state ~= 'off'
      end
      for _,seg in ipairs(segs) do
        seg.on = segOn[seg.node]
      end
      print(pp(segOn,2))
      setSegs()
      spoon.restNotify()
    end
  --end)
  setSegs()
end

function toggleLight(_, menuItem)
  print(pp(menuItem, 2))
  local seg = menuItem.seg
  local url = makeUrl("https://"..segs.server.."/gridlight/rs/segment/action/{{node}}", {node=seg.node})
  local headers = {['content-type']='application/json'}
  if cookie then
    headers.cookie = cookie
  else
    headers.authorization = "Basic "..hs.base64.encode(spoon.user..":"..spoon.pw)
  end
  seg.on = not seg.on
  menuItem.checked = seg.on
  print(url, hs.http.doRequest(url.."?action="..(seg.on and "on" or "off"), "PUT", "", headers))
  setDisplay()
end

function spoon.notified(str)
  local r, s = pcall(hs.json.decode, str)
  print("spoon.notified", r, #str, str)
  if r and s.messages then
    local segOn = {}
    for _,seg in pairs(s.messages) do
      if seg.data and seg.data.event and seg.data.event.type == "light" then
        segOn[seg.data.event.nodeId] = seg.data.event.entities:find('"state":"on"', 1, true) ~= nil
      end
    end
    for _,seg in ipairs(segs) do
      seg.on = segOn[seg.node]
    end
    print(pp(segOn,2))
    setSegs()
  end
end

local restNotice = 1
function spoon.restNotify()
  print("spoon.restNotify", restNotice)
  if restNotice then
    return
  end
  restNotice = true
  local upld = hs.json.encode({type="navigation", data={type="node", id=segs.topNode}})
  local headers = { authorization = "Basic "..hs.base64.encode(spoon.user..":"..spoon.pw) }
  local url = "https://"..segs.server.."/greenwise/rs/subscription?timeout=95000"
  hs.http.doAsyncRequest(url, "GET", upld, headers, function(code, body)
    print("DONE", code, #body)
    restNotice = nil
  end, nil, function(chunk)
    spoon.notified(chunk)
  end)
end

function spoon.wsNotify(customer)
  if wsNotice then
    wsNotice:close()
  end
  --local headers = { authorization = "Basic "..hs.base64.encode(spoon.user..":"..spoon.pw) }
  --wsNotice = hs.websocket.new("wss://"..segs.server.."/changes",  headers, function(typ, msg)
  wsNotice = hs.websocket.new("wss://"..segs.server.."/changes", function(typ, msg)
    print(typ, msg)
    if typ == "open" then
      wsNotice:send(hs.json.encode {
        customerId = customer, type = "navigation", username = spoon.user,
        data = {type = "node", id = segs.topNode, pagerefresh = true},
      })
    elseif typ == "closed" then
      wsNotice = nil
    elseif typ == "received" then
      spoon.notified(msg)
    end
  end)
end

function spoon.stop()
end

return spoon
-- vim: set sw=2 sts=2 et:
