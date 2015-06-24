local c = require "o_jasper_common"
local This = c.copy_meta(require "listview.infofun.show_1")

function This:priority() return 0 end

This.asset_file = "parts/show_elaborate.html"

return c.metatable_of(This)
