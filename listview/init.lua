--  Copyright (C) 27-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local config = globals.listview or {}

local lousy = require("lousy")

local c = require("o_jasper_common")

local html_list = require "listview.html_list"
local html_entry = require "listview.entry_html"

local function final_html_list(listview, list, as_msg)
   local config = { date={pre="<span class=\"timeunit\">", aft="</span>"} }
   return as_msg and html_entry.list(listview, list) or html_list.keyval(list)
end

local search_cnt = 0

local function js_listupdate(listview, list, as_msg)
   search_cnt = search_cnt + 1
   -- TODO bit fussy.. really getting the return value straight out would be handy..
   local cnt = "BUG"
   local gl = listview.got_limit
   if gl then
      if #gl == 1 then
         cnt = string.format("results 0 to %d", gl[1])
      else
         cnt = string.format("results %d to %d", gl[1], gl[1] + gl[2])
      end
   else
      cnt = string.format("results %d to %d", listview.limit_i,
                          math.min(listview.limit_i + listview.limit_cnt,
                                   listview.limit_i + #list))
   end
   return { list=final_html_list(listview, list, as_msg),
            cnt=cnt,
            search_cnt=search_cnt
   }
end

local to_js = {
--Note these arent done (self, args..)-style because they are fed in
-- `view:register_function` in paged_chrome

   delete_id = function(self) return function(id)
         self.log:delete_id(id)
   end end,
   
   show_sql = function(self) return function(sql)
         return { sql_input = self:total_query(sql):sql_code() }
   end end,
   
   manual_sql = function(self) return function(sql, as_msg)
         return js_listupdate(self, self.log:exec(sql), as_msg)
   end end,
   
   do_search = function(self) return function(search, as_msg)
         return js_listupdate(self, self:total_query(search):result(), as_msg)
   end end,

-- TODO.. can we provide an interface to self directly?
--   get_limit_i    = function(self) return function() return self.limit_i end end,
--   get_limit_cnt  = function(self) return function() return self.limit_cnt end end,
--   get_limit_step = function(self) return function() return self.limit_step end end,
--
--   set_limit_i    = function(self) return function(to) self.limit_i = to end end,
--   set_limit_cnt  = function(self) return function(to) self.limit_cnt = to end end,
--   set_limit_step = function(self) return function(to) self.limit_step = to end end,
   
   got_limit = function(self) return function() return self.got_limit end end,

   change_cnt = function(self) return function(by)
         self.limit_cnt = math.max(1, self.limit_cnt + by)
         self.limit_step = self.limit_cnt
   end end,

   cycle_limit_values = function(self) return function(n)
         self.limit_i = self.limit_i + self.limit_step*(n or 1)
   end end,

   reset_limit_values = function(self) return function()
         self.limit_i   = nil -- self.values.limit_i
         self.limit_cnt = nil --self.values.limit_cnt
   end end,
}

-- Apparently we dont need to know in order to satisfy the interface.
-- local pagedChrome = require "paged_chrome"

-- Making the objects that do the pages.
local Public = {
   Base = {
      repl_pattern = false, to_js = {}, limit_i=0, limit_cnt = 20, limit_step=20,
      values = { to_js = {} },

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
      asset = function(self, what, kind)
         assert(type(self) == "table")
         if type(self.where) == "string" then self.where = {self.where} end
         local after = "/assets/" .. what .. (kind or ".html")
         for _, w in pairs(self.where) do
            local got = c.load_asset(w .. after)
            if got then return got end
         end
         return c.load_asset("listview" .. after) or "COULDNT FIND ASSET"
      end,
      asset_getter = function(self, what, kind) -- .. yah.
         return function() return self:asset(what, kind) end
      end,
      },
}

local function accept_js_funs(into_page_meta, names)
   for _, name in pairs(names) do
      into_page_meta.to_js[name] = to_js[name]
   end
end

-- Listview.
Public.Search = c.copy_meta(Public.Base)

function Public.Search.repl_list(self, view, meta)
   local query = self:total_query("")
   local sql_shown, latest_query = true, self.log.latest_query or ""
   -- TODO metatable it? Cant iterate it then tho.(unless also metatable that)
   return { latestQuery  = latest_query,
            table_name    = self.log.values.table_name,
            searchInput   = self:asset("parts/search"),
            searchInitial = self:asset("parts/search_initial"),
            stylesheet    = self:asset("style", ".css"),
            js            = self:asset("js", ".js"),
            title = string.format("%s:%s", self.chrome_name, self.name),
            cycleCnt = self.limit_step,
            sqlShown = config.sql_shown and "true" or "false",
   }
end
accept_js_funs(Public.Search, {"show_sql", "manual_sql", "do_search",
                                "cycle_limit_values", "change_cnt",
                                "reset_limit_values", "got_limit",
                                "delete_id"})

Public.AboutChrome = c.copy_meta(Public.Base)
function Public.AboutChrome.repl_list(self, view, meta)
   return setmetatable({
                          title = string.format("%s:%s", self.chrome_name, self.name),
                          stylesheet    = self:asset("style", ".css"),
                          --raw_summary = html_list.keyval({self.log.values})
                       },
                       {__index=function(_, key)
                           if self.log.values[key] then
                              return self.log.values[key]
                           elseif key == "raw_summary" then
                              return c.tableText(self.log.values, "&nbsp;&nbsp;", "","<br>")
                           end
                       end
                       })
end

local listview_metatables = {}  -- Prep metatables.
for k,v in pairs(Public) do Public[k] = c.metatable_of(v) end

function Public.new_Search(log, where)
   assert(log and where)
   return setmetatable({log = log, where=where}, Public.Search)
end
function Public.new_AboutChrome(log, where)
   assert(log and where)
   return setmetatable({log=log, where=where}, Public.AboutChrome)
end

local paged_chrome = require("paged_chrome")

function Public.new_Chrome(log, where, default_name)
   assert(log and where)
   return { default_name = default_name or "search",
            search = paged_chrome.templated_page(Public.new_Search(log, where)),
            aboutChrome = paged_chrome.templated_page(Public.new_AboutChrome(log, where)),
   }
end

return Public
