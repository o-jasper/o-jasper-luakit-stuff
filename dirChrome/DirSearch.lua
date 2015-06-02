local c = require "o_jasper_common"

local Search = require("listview.Search")

local this = c.copy_meta(Search)

function this:repl_list(args)
   local ret = Search.repl_list(self, args)
   ret.path = self.log.path
   ret.before = "<b>" .. ret.path .. "</b><br>"
   print("=======", ret.before)
   return ret
end

return c.metatable_of(this)
