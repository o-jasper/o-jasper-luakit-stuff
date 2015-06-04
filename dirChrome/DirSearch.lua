local c = require "o_jasper_common"

local Search = require("listview.Search")

local this = c.copy_meta(Search)

-- Figures out the main file
--function this:main_file()
--   for k,v 
--end

function this:repl_list(args)
   self.log:update_whole_directory()  -- Ensure in the sql table.
   local ret = Search.repl_list(self, args)
   ret.cur_dir = self.log.path
   -- TODO better..
   ret.initial_query = "dirlike:" .. self.log.path
   ret.search_shown = "false"
--   ret.main_file = self:main_file()
   return ret
end

return c.metatable_of(this)
