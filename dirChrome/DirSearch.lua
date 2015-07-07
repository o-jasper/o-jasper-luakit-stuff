local config = globals.dirChrome or globals.listview or {}

local c = require "o_jasper_common"

local Search = require "listview.Search"

local This = c.copy_meta(Search)
This.__name = "dirChrome.DirSearch"

function This:config() return config end

function This:infofun()
   return self:config().infofun or {require "dirChrome.infofun.show_1"}
end

function This:side_infofun()  -- TODO should be in DirSearch..
   return self:config().side_infofun or {
         require "dirChrome.infofun.markdown", require "dirChrome.infofun.basic_img", 
         require "dirChrome.infofun.file"}
end

function This:priority()  -- For when used as side panel ..
   assert(self.as_info)
   return 0
end

function This:repl(args)
   self.log:update_whole_directory()  -- Ensure in the sql table.
   local ret = Search.repl(self, args)
   ret.cur_dir = self.log.path
   -- TODO better..
   ret.initial_query = "dir=" .. self.log.path
   ret.search_shown = "false"

   --local list = infofun_lib.list_highest_priority_each(self,  
   ret.infofuns_immediate = self:list_to_html(self.log:info_from_dir(), {})
   --ret.main_file = self.log:main_file()
   return ret
end

return c.metatable_of(This)
