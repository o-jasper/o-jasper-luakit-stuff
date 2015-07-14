local c = require "o_jasper_common"

local This = {}

function This:init()
   self.sites = {}
end

function This:register(pageset)
   self.sites[pageset.chrome_name] = pageset
end
function This:register_table(tab)
   for _, v in pairs(tab) do self:register(v) end
end

return c.metatable_of(This)
