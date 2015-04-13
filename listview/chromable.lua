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

-- TODO this not really usable as lib,
-- Function depending on a 'db', returns object for both the adding, and
-- searching.
-- .. hmm this is pretty close to what they are?
--    Perhaps paged_chrome just needs a 'combiner' function?

local function final_html_list(listview, list, as_msg)
   local config = { date={pre="<span class=\"timeunit\">", aft="</span>"} }
   return as_msg and html_msg_list(listview, list, config) or html_list_keyval(list)
end

local search_cnt = 0

local function js_listupdate(listview, list, as_msg)
   search_cnt = search_cnt + 1
   return { list=final_html_list(listview, list, as_msg),
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
         return js_listupdate(self, list, as_msg)
   end end,
   
   do_search = function(self) return function(search, as_msg)
      return js_listupdate(self, self.total_query(search).result(), as_msg)
   end end,
}

require "paged_chrome"

-- Making the objects that do the pages.

local listview_metas = {
   base = {
      defaults = { repl_pattern = false, to_js = {} },
      direct = {
         total_query = function(self) return function(search)
               -- How we end up searching.
               assert(type(search) == "string", "Search not string; " .. tostring(search))
               local query = self.log.new_sql_help()
               if search ~= "" then query.search(search) end
               query.order_by(self.log.values.order_by)
               query.row_range(0, 20)
               -- TODO other ones..
               return query
         end end,
         asset = function(self) return function(what, kind)
               if type(self.where) == "string" then self.where = {self.where} end
               local after = "/assets/" .. what .. (kind or ".html")
               for _, w in pairs(self.where) do
                  local got = load_asset(w .. after)
                  if got then return got end
               end
               return load_asset("listview" .. after) or "COULDNT FIND ASSET"
         end end,
         asset_getter = function(self) return function(what, kind) -- .. yah.
               return function() return self.asset(what, kind) end
         end end,
      },
      values = { to_js = {} },
}}

local function accept_js_funs(into_page_meta, names)
   for _, name in pairs(names) do
      into_page_meta.defaults.to_js[name] = to_js[name]
   end
end

-- Listview.
listview_metas.search = copy_table(listview_metas.base)
listview_metas.search.direct.repl_list = function(self) return function(view, meta)
      local query = self.total_query("")
      local list = query.result()
      local sql_shown = true
      return { searchInput   = self.asset("parts/search"),
               searchInitial = self.asset("parts/search_initial"),
               stylesheet    = self.asset("style", ".css"),
               js            = self.asset("js", ".js"),
               title = string.format("%s:%s", self.chrome_name, self.name),
               cnt = #list,
               list = final_html_list(self, list, true),
               sqlInput = config.sql_show and query.sql_code() or "",
               sqlShown = config.sql_shown and "true" or "false",
      }
end end
accept_js_funs(listview_metas.search, {"show_sql", "manual_sql", "do_search"})

-- Adding entries
listview_metas.add = copy_table(listview_metas.base)
function listview_metas.add.direct.repl_list(self) return function(view, meta)
      return { addManual  = self.asset("parts/add"),
               stylesheet = self.asset("style", ".css") or "", 
               js         = self.asset("js", ".js") or "",
               title = string.format("%s:%s", self.chrome_name, self.name),
      }
end end

accept_js_funs(listview_metas.add, {"manual_enter"})

-- Both those.
listview_metas.all = copy_table(listview_metas.base)
function listview_metas.all.direct.repl_list(self) return function(view, meta)
      -- Combine the two.
      local ret = listview_metas.search.direct.repl_list(self)(view, meta)
      local lst = listview_metas.add.direct.repl_list(self)(view, meta)
      for k, v in pairs(lst) do
         ret[k] = v
      end
      return ret
end end

listview_metas.all.values.to_js = to_js

local listview_metatables = {}
for k,v in pairs(listview_metas) do listview_metatables[k] = metatable_of(v) end

function listview_chrome(log, which, where)
   assert(log)
   return setmetatable({log = log, where=where}, listview_metatables[which])
end
