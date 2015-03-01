--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Chrome page of all logs. User may do subselection.

config = (globals.listview or {})

local lousy = require("lousy")

require "listview.common"
require "listview.html_list"
require "listview.log"
require "listview.log_html"
--require "listview.work"

log = new_log(capi.luakit.data_dir .. "/msgs.db")

-- How we end up searching.
local function total_query(search)
   assert(type(search) == "string")
   local query = log.new_sql_help()
   if search ~= "" then query.search(search) end
   query.order_by("id")
   -- TODO other ones..
   return query
end

function final_html_list(list, as_msg)
   local config = { date={pre="<span class=\"timeunit\">", aft="</span>"} }
   return as_msg and html_msg_list(list, config) or html_list_keyval(list)
end

local search_cnt = 0

local function js_listupdate(list, as_msg)
   search_cnt = search_cnt + 1
   return { list=final_html_list(list, as_msg),
            cnt=#list, search_cnt=search_cnt }
end

local current_search = ""

export_funcs = {
   manual_enter = function(inp)
      local v= log.enter("manual", 
                         { claimtime=cur_time_s(),
                           re_assess_time = cur_time_s() + 120,
                           kind = "manual test", origin = "manual test",
                           data = "", data_uri = "",
                           uri = "", title = inp.title, desc = inp.desc,
                           keep = true,
                           tags = lousy.util.string.split(inp.tags, "[,; ]+")
                         })
   end,
   
   show_sql = function(sql)
      if sql ~= current_search then
         current_search = sql
         if not string.match(current_search, "^[ ,;:]+$") then
            return { sql_input = total_query(current_search).sql_code() }
         end
      end
      return {}
   end,
   
   manual_sql = function(sql, as_msg)
      local list = log.db:exec(sql);
      if as_msg then list = map(list, log._msg) end
      return js_listupdate(list, as_msg)
   end,
   
   do_search = function(search, as_msg)
      return js_listupdate(total_query(search).result(), as_msg)
   end,
}

local function asset(what, kind) 
   return lousy.load_asset("listview/assets/" .. what .. (kind or ".html"))
      or "COULDNT FIND ASSET"
end

pages = {
   default_name = "search",

   all = { 
      html = function(self, view, meta)
         local query = total_query("")
         local list = query.result()
         local sql_shown = true

         return full_gsub(asset(self.name),
                          { addManual=asset("parts/add"), 
                            searchInput=asset("parts/search"),
                            -- Non-parts.
                            stylesheet = asset("assets/style", ".css"), 
                            js         = asset("assets/js", ".js"),
                            title = string.format("%s:%s", self.chrome_name, self.name),
                            cnt = #list,
                            list = final_html_list(list, true),
                            sqlInput = sql_show and query.sql_code() or "",
                            sqlShown = sql_shown,
                          })
      end,
      init = function(self, view, meta)
         export_fun(view, {"manual_enter", "show_sql", "manual_sql", "do_search"})
      end,
   },
   add = {
      html = function(self, view, meta)
         return full_gsub(asset(self.name),
                          { addManual=asset("parts/add"),
                            stylesheet = asset("style", ".css") or "", 
                            js         = asset("js", ".js") or "",
                            title = string.format("%s:%s", self.chrome_name, self.name),
                          })
      end,
      init = function(self, view, meta)
         export_fun(view, "manual_enter")
      end
   },
   search = {
      html = function(self, view, meta)
         local query = total_query("")
         local list = query.result()
         local sql_shown = true

         return full_gsub(asset(self.name),
                          { searchInput=asset("parts/search"),
                            stylesheet = asset("style", ".css"),
                            js         = asset("js", ".js"),
                            title = string.format("%s:%s", self.chrome_name, self.name),
                            cnt = tostring(#list),
                            list = final_html_list(list, true),
                            sqlInput = sql_show and query.sql_code() or "",
                            sqlShown = tostring(sql_shown),
                            chromeRanCnt=13
                          })
      end,
      init = function(self, view, meta)
         export_fun(view, {"show_sql", "manual_sql", "do_search"})
      end
   }
}

require "paged_chrome"
paged_chrome("listview", pages)
