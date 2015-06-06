-- Shows readme functions and/or 

local c = require "o_jasper_common"
local lfs = require "lfs"

local this = {}

function this.maybe_new(path, file)
   return setmetatable({ path=path, file=file }, this)
end

function this:priority()
   return 0
end

function this:html()  -- TODO not allowed to touch local shit..
   local fp = self.path .. "/" .. self.file
   local ret = {}
   for k,v in pairs(lfs.attributes(fp)) do
      table.insert(ret, string.format("<b>%s</b>:%s", k,v))
   end
   return table.concat(ret, ", ")
end

return c.metatable_of(this)
