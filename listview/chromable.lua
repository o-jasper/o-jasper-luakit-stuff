--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Chrome page of all logs. User may do subselection.

config = (globals.listview or {})

local lousy = require("lousy")

require "o_jasper_common"
require "listview.html_list"
require "listview.log"
require "listview.log_html"
--require "listview.work"

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

local to_js = {
   manual_enter = function(self) return function(inp)
         local v= self.log.db_enter({ claimtime=cur_time_s(),
                                   re_assess_time = cur_time_s() + 120,
                                   origin = "manual",
                                   kind = "manual test",
                                   data = "", data_uri = "",
                                   uri = "", title = inp.title, desc = inp.desc,
                                   keep = true,
                                   tags = lousy.util.string.split(inp.tags, "[,; ]+")
                                 })
   end end,
   
   show_sql = function(self) return function(sql)
         return { sql_input = self.total_query(sql).sql_code() }
   end end,
   
   manual_sql = function(self) return function(sql, as_msg)
         local list = self.log.db:exec(sql);
         if as_msg then list = map(list, self.log._msg) end
         return js_listupdate(list, as_msg)
   end end,
   
   do_search = function(self) return function(search, as_msg)
      return js_listupdate(self.total_query(search).result(), as_msg)
   end end,
}

require "paged_chrome"

-- Making the objects that do the pages.

listview_meta = {
   defaults = { repl_pattern = false, to_js = {} },
   direct = {
      total_query = function(self) return function(search)
            -- How we end up searching.
            assert(type(search) == "string", "Search not string; " .. tostring(search))
            local query = self.log.new_sql_help()
            if search ~= "" then query.search(search) end
            query.order_by("id")
            -- TODO other ones..
            return query
      end end,
   },
   determine = {
      log = function(self) return new_log(capi.luakit.data_dir .. "/msgs.db") end
   },
   values = { to_js = {} },
}

function accept_js_funs(into_page_meta, names)
   for _, name in pairs(names) do
      into_page_meta.defaults.to_js[name] = to_js[name]
   end
end

-- Listview.
listview_search_meta = copy_table(listview_meta)
listview_search_meta.direct.repl_list = function(self) return function(view, meta)
      local query = self.total_query("")
      local list = query.result()
      local sql_shown = true
      return { searchInput=asset("parts/search"),
               searchInitial=asset("parts/search_initial"),
               stylesheet = asset("style", ".css"),
               js         = asset("js", ".js"),
               title = string.format("%s:%s", self.chrome_name, self.name),
               cnt = #list,
               list = final_html_list(list, true),
               sqlInput = config.sql_show and query.sql_code() or "",
               sqlShown = config.sql_shown and "true" or "false",
      }
end end
accept_js_funs(listview_search_meta, {"show_sql", "manual_sql", "do_search"})

-- Adding entries
listview_add_meta = copy_table(listview_meta)
function listview_add_meta.direct.repl_list(self) return function(view, meta)
      return { addManual=asset("parts/add"),
               stylesheet = asset("style", ".css") or "", 
               js         = asset("js", ".js") or "",
               title = string.format("%s:%s", self.chrome_name, self.name),
      }
end end

accept_js_funs(listview_add_meta, {"manual_enter"})

-- Both those.
listview_all_meta = copy_table(listview_meta)
listview_all_meta.values.to_js = to_js
function listview_all_meta.direct.repl_list(self) return function(view, meta)
      -- Combine the two.
      local ret = listview_search_meta.direct.repl_list(self)(view, meta)
      for k, v in pairs(listview_add_meta.direct.repl_list(self)(view, meta)) do
         ret[k] = v
      end
      return ret
end end
