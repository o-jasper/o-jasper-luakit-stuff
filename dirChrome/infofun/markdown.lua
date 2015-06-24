-- Shows readme functions and/or 

local c = require "o_jasper_common"

local this = c.copy_meta(require "listview.infofun.show_1")

function this.newlist(creator, entry)
   if string.match(string.lower(entry.file), "[.]md$") then
      return {setmetatable({ dir=entry.dir, file=entry.file }, this)}
   end
end

function this:priority()
   return string.match(string.lower(self.file), "readme[.]md$") and 2 or -1
end

function this:html()
   local got = io.open(self.dir .. "/" .. self.file)
   if got then
      local ret = got:read("*a")
      got:close()
      return require("markdown")(ret) .. "<hr>"
   else
      return string.format("couldnt open <code>%s</code><hr>", self.dir)
   end
end

return c.metatable_of(this)
