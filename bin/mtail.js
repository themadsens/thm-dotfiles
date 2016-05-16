#!/usr/bin/env node

function FileC(path, lines, id)
{
   local fd,err = io.open(path, "r")
   this.extendod{path=path, fd=fd, id=id}, { __index = FileC })
   if fd then
      fd:setvbuf("no")
      ret.lastInode = posix.stat(path, "ino")
      local pos = fd:seek("end")
      local size = 0
      local oldPos = 0
      while lines > 0 and pos > 0 do
         oldPos = pos
         local backUp = math.min(oldPos, 4096);
         pos = fd:seek("set", oldPos - backUp)
         local line = fd:read(backUp)
         fd:seek("set", pos)
         local nseps = 0
         line:reverse():gsub("[\n]?[\r]?[^\r\n]*", function(c)
                                                      nseps = nseps + 1
                                                      size = size + #c
                                                   end,
                             lines)
         lines = lines - nseps
         --print(oldPos, pos, "''"..line:sub(1, 20).."''", nseps, size)
      end
      fd:seek("set", math.max(oldPos - size, 0))
   else
      io.stdout:write("!!Cannot open "..err.."\n")
   end
   return ret
end

FileC.prototype.checkRead = function()
{
   if not self.fd then return false end

   local pos = self.fd:seek("cur")
   local sep; if pos == 0 then sep = "*" else sep = ":" end
   local tail = self.fd:read("*a")
   local size = 0
   local utll = false
   
   if #tail == 0 then return false end
   for line,eol in tail:gmatch("([^\r\n]*)([\r]?[\n]?)") do
      if #line + #eol == 0 then break end
      if #eol == 0 then utll=true; break end

      size = size + #line + #eol
      io.stdout:write(string.format("%d%s%s\n", self.id, sep,
                          (line:gsub("%c", function(c)
                              if c:byte() ~= 9 then
                                 return "^"..string.char(c:byte() + 64)
                              end
                           end))))
      sep = ":"
   end
   self.fd:seek("set", pos + size)
   if utll then return false end -- Force stat check
   return true
}

FileC.prototype.checkEnd = function()
{
   if self:checkRead() then
      return -- Something to read - Skip stat test
   end

   local st = posix.stat(self.path)
   local hadFd = self.fd ~= nil
   if not st or st.ino ~= self.lastInode then
      if self.fd then
         self:checkRead() -- Make sure there is no more to read now that he is done with it
         self.fd:close()
         self.fd = nil
      end
   end
   if not self.fd then
      local fd,err = io.open(self.path, "r")
      if fd == nil and hadFd then
         self.lastInode = 0
         io.stdout:write(self.id.."!Disappeared: "..self.path..": "..err..
                         "at "..os.date().."\n")
      elseif fd then
         self.fd = fd
         self.lastInode = posix.fstat(fd:getfd()).ino
         self.fd:setvbuf("no")
      end
   end
   self:checkRead()
}

function FWatch.

function consumeArg(arg)
{
}

for (var i = 2; i < #argv; i++) {
    consumeArg(argv[i])
}

// Fall into event loop
