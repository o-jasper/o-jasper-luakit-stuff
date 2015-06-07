local config = globals.dirChrome or globals.listview or {}

local c = require "o_jasper_common"

local Search = require("listview.Search")

local This = c.copy_meta(Search)

function This:config() return config end

function This:infofun()
   return self:config().infofun or {require "dirChrome.infofun.show_1"}
end

local infofun_lib = require "sql_help.infofun"

function This.to_js:html_of_id()
   return function(id)
      local entry = self.log:get_id(id)
      local list = infofun_lib.entry_thresh_priority(self.log, entry, 
                                                     self.log:dir_infofun(), -1)
      infofun_lib.priority_sort(list, self.config().priority_override)
      local html = self:list_to_html(list, {})
      return html and #html > 0 and html  -- Makes sense.
   end
end

function This:repl_list(args)
   self.log:update_whole_directory()  -- Ensure in the sql table.
   local ret = Search.repl_list(self, args)
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
