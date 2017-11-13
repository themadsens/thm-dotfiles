#!/usr/bin/env luajit
-- ported to Lua from https://gist.github.com/graven/921334
-- Demonstrate using Lua coroutines as generators

-- print "color indexes should be drawn in bold text of the same color.\n"

local cocreate, yield, resume = coroutine.create, coroutine.yield, coroutine.resume

local function iter(co) return function()
    local r = { resume(co) }
    if r[1] and r[2] then
        return unpack(r, 2)
    end
    return nil
end end

local function colored() return cocreate(function()
   yield(0) for n=0,4 do yield(0x5f + 40 * n) end
end) end

local function gray() return cocreate(function()
    for n=0,23 do yield(8 + 10 * n) end
end) end

local gen = cocreate(function()
    local i = 16
    for r in iter(colored()) do for g in iter(colored()) do for b in iter(colored()) do
        yield(i, ("%02x/%02x/%02x"):format(r,g,b))
        i = i + 1
    end end end
    for a in iter(gray()) do
        yield(i, ("%02x/%02x/%02x"):format(a,a,a))
        i = i + 1
    end
end)

local normal = "\x1b[48;5;%sm"
local textfg = "\x1b[38;5;%sm"
local bold   = "\x1b[1;38;5;%sm"
local reset  = "\x1b[0m"

for t,typ in ipairs { "", "*" } do
    for c,colnm in ipairs {"black", "red ", "green", "yellow", "blue ", "magnta", "cyan ", "white"} do
        local i = (t-1) * 8 + c - 1
        local index = (bold.." %02d: "..reset):format(i, i)
        local color = (normal..textfg.."%6s"..reset):format(i, t == 1 and 15 or 0, colnm)
        io.stdout:write(index..color..(c==8 and '\n' or ''))
    end
end
for i, color in iter(gen) do
    local index = (bold.." %03d: "..reset):format(i, i)
    local hex   = (normal..textfg.."%s"..reset):format(i, (i-16) % 36 < 6 and 15 or 0, color)
    local indent = i % 6 == 4 and '  ' or ''
    local newline = i % 6 == 3 and '\n' or ''
    io.stdout:write(indent..index..hex..newline) 
end
