#!lua
--[[
 * @file lua_debug.lua
 * Debug prolog
 * Usage: In lua agent main file insert the following:
 *
 * if os.getenv("DEBUGEE") then
 *    -- Note: Must "pak install lua-extra" first
 *    pcall(require, "lua_debug") In main
 * end
 *
 * $Id: lua_debug.lua 29052 2021-09-14 12:42:57Z fm $
 *
 * (C) Copyright 2020 Amplex, fm@amplex.dk
 ]]

local inspect
local function noMetas(item, path) return path[#path] ~= inspect.METATABLE and item end

local function pp(val, opt, showMeta)
  if not inspect then
    inspect = require "inspect"
  end
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
local function pm(val, opt) return pp(val, opt, true) end

_G.pp = pp
_G.pm = pm

-- vim: set sw=2 sts=2 et:
