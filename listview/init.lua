--  Copyright (C) 27-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local config = globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local lousy = require("lousy")

local c = require("o_jasper_common")

local html_list = require "listview.html_list"
local html_entry = require "listview.entry_html"

local function final_html_list(listview, list, as_msg)
   local config = { date={pre="<span class=\"timeunit\">", aft="</span>"} }
   if not as_msg then
      return html_list.keyval(list)
   elseif listview.log.initial_state then
      return html_entry.list(listview, list, listview.log:initial_state())
   else
      return html_entry.list(listview, list)
   end
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

   addsearch = function(self) return function(name)
         return self:config().addsearch[name]
   end end,

   delete_id = function(self) return function(id)
         self.log:delete_id(id)
   end end,
   
   show_sql = function(self) return function(search)
         return { sql_input = self:total_query(search):sql_code() }
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
      repl_pattern = false, to_js = {},

      config = function(self) return config end,

-- TODO.. seems like something that might belong in `paged_chrome`.
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

      repl_list = function(self, view, meta)
         return {
            common_js     = self:asset("common", ".js"),
            stylesheet    = self:asset("style", ".css"),
            title = string.format("%s:%s", self.chrome_name, self.name),
         }
      end,
      },
}

-- The search part.
local mod_Search = {
   limit_i=0, limit_cnt=20,limit_step=20,

   to_js = to_js,

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

   repl_list = function(self, view, meta)
      local query = self:total_query("")
      local sql_shown, latest_query = true, self.log.latest_query or ""
      return {
         common_js     = self:asset("common", ".js"),
         stylesheet    = self:asset("style", ".css"), -- TODO These are from base..
         title = string.format("%s:%s", self.chrome_name, self.name),
         search_js     = self:asset("search", ".js"),

         latestQuery   = latest_query,
         table_name    = self.log.values.table_name,
         searchInput   = self:asset("parts/search"),
         search_initial_js = self:asset("parts/search_initial", ".js"),
         cycleCnt = self.limit_step,
         sqlShown = self:config().sql_shown and "true" or "false",
      }
   end,
}
Public.Search = c.copy_meta(Public.Base, mod_Search)

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
