--  Copyright (C) 02-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require("o_jasper_common")
local html_entry = require "listview.entry_html"

local mod_Search = {

   -- html_state = nil,
   search_cnt = 0,

   limit_i=0, limit_cnt=20,limit_step=20,

   to_js = require "listview.to_js",

   total_query = function(self, search)
      -- How we end up searching.
      assert(type(search) == "string", "Search not string; " .. tostring(search))
      local query = self.log:new_SqlHelp()
      if search ~= "" then query:search(search) end
      query:order_by(self.log.values.order_by)
      
      self.got_limit = query.got_limit
      if not query.got_limit then  -- Add a limit if dont have one yet.
         query:limit(self.limit_i, self.limit_cnt)
      end
      return query
   end,

   repl_list = function(self, args)
      return { 
         title = string.format("%s:%s", self.chrome_name, self.name),
         latestQuery   = self.log.cmd_query or "",
         table_name    = self.log.values.table_name,
         cycleCnt = self.limit_step,
         sqlShown = self:config().sql_shown and "true" or "false",
         
         above_title = " ", below_title = " ", right_of_title = " ",
         below_search = " ",
         above_sql = " ", below_sql = " ",
         below_acts = " ", after = " ",
      }
   end,

   js_listupdate = function (self, list, as_msg)
      self.search_cnt = self.search_cnt + 1
      -- TODO bit fussy.. really getting the return value straight out would be handy..
      local cnt = "BUG"
      local gl = self.got_limit
      if gl then
         if #gl == 1 then
            cnt = string.format("results 0 to %d", gl[1])
         else
            cnt = string.format("results %d to %d", gl[1], gl[1] + gl[2])
         end
      else
         cnt = string.format("results %d to %d", self.limit_i,
                             math.min(self.limit_i + self.limit_cnt,
                                      self.limit_i + #list))
      end
      return { list=self:final_html_list(list, as_msg, reset_state),
               cnt=cnt,
               search_cnt=self.search_cnt,
      }
   end,
   
   final_html_list = function(self, list, as_msg)
      local config = { date={pre="<span class=\"timeunit\">", aft="</span>"} }
      if not as_msg then
         return html_list.keyval(list)
      else
         assert(self.log.initial_state)
         --print(self.log.initial_state, html_state, self.log:initial_state())
         self.html_state = self.html_state or self.log:initial_state()
         return html_entry.list(self, list, self.html_state)                             
      end
   end,
}

return c.metatable_of(c.copy_meta(require "listview.Base", mod_Search))
