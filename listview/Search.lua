--  Copyright (C) 07-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require("o_jasper_common")

local This = c.copy_meta(require "listview.Base")

-- This.html_state = nil,
for k,v in pairs({search_cnt=0, limit_i=0, limit_cnt=20, limit_step=20}) do
   This[k] = v
end
This.to_js = require "listview.Search_to_js"

function This:initial_state() return {} end

function This:infofun()
   return self:config().infofun or {require "listview.infofun.show_1"}
end

function This:total_query(search)
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
end

function This:repl_list(args)
   return { 
      title = string.format("%s:%s", self.chrome_name, self.name),
      initial_query  = self.log.cmd_query or "",
      table_name    = self.log.values.table_name,
      cycleCnt = self.limit_step,
      sqlShown = self:config().sql_shown and "true" or "false",
      
      above_title = " ", below_title = " ", right_of_title = " ",
      below_search = " ",
      above_sql = " ", below_sql = " ",
      below_acts = " ", before = " ", after = " ",
   }
end

local infofun_lib = require "sql_help.infofun"

function This:js_listupdate(list, as_msg)
   list = infofun_lib.list_highest_priority_each(self.log, list, self:infofun())

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
   return { list=self:html_list(list, as_msg, reset_state),
            cnt=cnt,
            search_cnt=self.search_cnt,
   }
end

function This:list_to_html(list, state)
   local html = "<table>"
   for _, info in pairs(list) do html = html .. info:html(state, self:asset_fun()) end
   return html .. "</table>"
end

function This:html_list(list, as_msg)
   local config = { date={pre="<span class=\"timeunit\">", aft="</span>"} }
   if not as_msg then  -- Plain table.
      local ret = ""
      for _, el in pairs(list) do
         ret = ret .. [[<table class="plain_table">]] .. c.html.table(el) .. "</table><hr>"
      end
      return ret
   else
      self.html_state = self.html_state or self:initial_state()
      return self:list_to_html(list, self.html_state)
   end
end

return c.metatable_of(This)
