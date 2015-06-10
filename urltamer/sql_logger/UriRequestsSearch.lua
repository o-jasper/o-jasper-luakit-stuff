local c = require "o_jasper_common"

local This = c.copy_meta(require "listview.Search")

function This:infofun()
   return self:config().infofun or {require "urltamer.sql_logger.infofun.show_1"}
end

return c.metatable_of(This)
