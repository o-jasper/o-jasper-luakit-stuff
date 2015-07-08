-- Shows readme functions and/or 

local c = require "o_jasper_common"

local This = c.copy_meta(require "listview.infofun.show_1")

function This.newlist(creator, entry)
   if string.match(string.lower(entry.file), "[.]md$") then
      local got = io.open(entry.dir .. "/" .. entry.file)
      if got then
         got:close()
         return {setmetatable({ dir=entry.dir, file=entry.file }, This)}
      else
         return {}
      end
   end
end

function This:priority()
   return string.lower(self.file) == "readme.md" and 2 or 0.5
end

function This:html()
   local got = io.open(self.dir .. "/" .. self.file)
   if got then
      local ret = got:read("*a")
      got:close()
      return require("markdown")(ret) .. "<hr>"
   else
      return string.format("couldnt open <code>%s</code><hr>", self.dir)
   end
end

return c.metatable_of(This)

