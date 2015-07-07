local c = require "o_jasper_common"

local lfs = require "lfs"

local This = c.copy_meta(require "dirChrome.infofun.markdown")

function This.newlist(creator, entry)
   if not entry.data_uri then return {} end
   local file = entry.data_uri .. "/readme.md"
   local attrs = lfs.attributes(file)
   if attrs then
      attrs.dir  = c.path.dir(file)
      attrs.file = c.path.file(file)
      attrs.priority = function() return 0 end
      return {setmetatable(attrs, This)}
   else
      return {}
   end
end

function This:priority() return -1 end

return c.metatable_of(This)
