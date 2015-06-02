local c = require "o_jasper_common"

local Search = require("listview.Search")

local this = c.copy_meta(Search)

function this:repl_list(args)
   local ret = Search.repl_list(self, args)
   ret.cur_dir = self.log.path
   -- TODO better..
   ret.above_title = "<b>DIR:" .. ret.path .. "</b><br>"
   ret.initial_query = "dirlike:" .. self.log.path
   ret.search_shown = "false"
   return ret
end

return c.metatable_of(this)
