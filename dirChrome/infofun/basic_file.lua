-- Shows readme functions and/or 

local c = require "o_jasper_common"
local lfs = require "lfs"

local This = {}

function This:priority()
   return 0
end

function This:html()  -- TODO not allowed to touch local shit..
   local fp = self.path .. "/" .. self.file
   local ret = {}
   for k,v in pairs(lfs.attributes(fp)) do
      table.insert(ret, string.format("<b>%s</b>:%s", k,v))
   end
   return table.concat(ret, ", ")
end

return c.metatable_of(This)
