local c = require "o_jasper_common"

local this = {}

function this.maybe_new(path, dir)
   if string.match(string.lower(path), "[.]md$") then
      return setmetatable({ path=path }, this)
   end
end

function this:priority()
   if string.match(string.lower(self.path), "/readme[.]md]$") or
      return 1
   else
      return-1
   end
end

function this:html()
   local got = io.open(self.path)
   if got then
      local ret = got:read("*a")
      got:close()
      return require("markdown")(ret)
   else
      return string.format("couldnt open <code>%s</code>", self.path)
   end
end

return c.metatable_of(this)
