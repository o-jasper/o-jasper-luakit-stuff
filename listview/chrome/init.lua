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

local html_templates = {}
function get_template(name)
   if not html_templates[name] then
      html_templates[name] =
         lousy.load_asset(string.format("assets/%s.html", name))
   end
   return html_templates[name] or 
      string.format("AINT GOT A TEMPLATE FOR THIS<br> expect in assets/%s", name)
end

-- How we end up searching.
local function total_query(search)
   assert(type(search) == "string")
   local query = log.new_sql_help()
   if search ~= "" then query.search(search) end
   query.order_by("id")
   -- TODO other ones..
   return query
end

local current_search = ""

function final_html_list(list, as_msg)
   local config = { date={pre="<span class=\"timeunit\">", aft="</span>"} }
   return as_msg and html_msg_list(list, config) or html_list_keyval(list)
end

local chrome_ran_cnt, search_cnt = 0, 0

local function js_listupdate(list, as_msg)
   search_cnt = search_cnt + 1
   return { list=final_html_list(list, as_msg),
            cnt=#list, search_cnt=search_cnt }
end


function export_funcs(allow)
   local ret, funs = {}, {
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
      
      show_sql = function(inp)
         if inp.search ~= current_search then
            current_search = inp.search
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
   if allow == "all" then return ret end
   for _, el in pairs(allow) do ret[el] = funs[el] end
   return ret
end

require "paged_chrome"

pages = {
   all = { 
      html = function(view, meta)
         chrome_ran_cnt = chrome_ran_cnt + 1
         local query = total_query("")
         local list = query.result()
         local sql_shown = true
         return string.gsub(lousy.load_asset("assets/all.html"),
                            "{%%(%w+)}",
                            { stylesheet = lousy.load_asset("assets/style.css") or "", 
                              js         = lousy.load_asset("assets/js.js") or "",
                              title = string.format("%s:%s", chrome_name, "test"),
                              chromeRanCnt = tostring(chrome_ran_cnt),
                              cnt = tostring(#list),
                              list = final_html_list(list, true),
                              sqlInput = sql_show and query.sql_code() or "",
                              sqlShown = tostring(sql_shown)
                            })
      end,
      init = function(view, meta)
         for name, func in pairs(export_funcs({"manual_enter", "show_sql",
                                               "manual_sql", "do_search"})) do
            view:register_function(name, func)
         end
      end,
   }
}
pages.default = all

paged_chrome("listview", pages)
