local c = require "o_jasper_common"

local Search = require("listview.Search")

local this = c.copy_meta(Search)

function this:repl_list(args)
   self.log:update_whole_directory()  -- Ensure in the sql table.
   local ret = Search.repl_list(self, args)
   ret.cur_dir = self.log.path
   -- TODO better..
   ret.initial_query = "dir=" .. self.log.path
   ret.search_shown = "false"

   ret.infofuns_immediate = self.log:info_immediate_html()
   --ret.main_file = self.log:main_file()
   return ret
end

return c.metatable_of(this)
