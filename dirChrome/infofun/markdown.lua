-- Shows readme functions and/or 

local c = require "o_jasper_common"

local this = {}

function this.maybe_new(path, file)
   if string.match(string.lower(file), "[.]md$") then
      return setmetatable({ path=path, file=file }, this)
   end
end

function this:priority()
   return string.match(string.lower(self.file), "readme[.]md$") and 2 or -1
end

function this:html()
   local got = io.open(self.path .. "/" .. self.file)
   if got then
      local ret = got:read("*a")
      got:close()
      return require("markdown")(ret) .. "<hr>"
   else
      return string.format("couldnt open <code>%s</code><hr>", self.path)
   end
end

return c.metatable_of(this)
