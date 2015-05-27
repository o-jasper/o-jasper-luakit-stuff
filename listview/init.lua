--  Copyright (C) 11-05-2015 Jasper den Ouden.
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

local to_js = {

   addsearch = function(self) return function(name)
         return self:config().addsearch[name]
   end end,

   get_id = function(self) return function(id)
         local ret, got = {}, self.log:get_id(id)

         for k,v in pairs(got) do
            if type(v) ~= "table" and type(v) ~= "userdata" then
               ret[k] = v 
            end
         end
         if got.values.taggings then ret.tags = got:tags() end
         return ret
   end end,

   delete_id = function(self) return function(id)
         self.log:delete_id(id)
   end end,
   
   show_sql = function(self) return function(search)
         return { sql_input = self:total_query(search):sql_code() }
   end end,
   
   manual_sql = function(self) return function(sql, as_msg)
         return self:js_listupdate(self.log:exec(sql), as_msg)
   end end,
   
   do_search = function(self) return function(search, as_msg, reset_state)
         if reset_state then
            self.html_state = listview.log:initial_state()
         end
         return self:js_listupdate(self:total_query(search):result(), as_msg)
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
local Public = { Base = require "listview.Base" }

-- The search part.
local mod_Search = {

   -- html_state = nil,
   search_cnt = 0,

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

   repl_list = function(self, args, _, _)
      local query = self:total_query("")
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
Public.Search = c.copy_meta(Public.Base, mod_Search)

local mod_AboutChrome = {
   repl_list = function(self, args, _, _)
      return setmetatable(
         {   title = string.format("%s:%s", self.chrome_name, self.name),
         },
         {__index=function(kv, key)
             if self.log.values[key] then
                 return self.log.values[key]
             elseif key == "raw_summary" then
                return c.tableText(self.log.values,
                                   "&nbsp;&nbsp;", "","<br>")
             end
         end
         })
   end,
}
Public.AboutChrome = c.copy_meta(Public.Base, mod_AboutChrome)

local listview_metatables = {}  -- Prep metatables.
for k,v in pairs(Public) do Public[k] = c.metatable_of(v) end

local function tablize(x) if type(x) ~= "table" then return {x} else return x end end

function Public.new_Search(log, where)
   assert(log and where)
   return setmetatable({log = log, where=tablize(where)}, Public.Search)
end
function Public.new_AboutChrome(log, where)
   assert(log and where)
   return setmetatable({log=log, where=tablize(where)}, Public.AboutChrome)
end

local paged_chrome = require("paged_chrome")

-- Better not use.
function Public.new_Chrome(log, where, default_name)
   assert(log and where)
   return { default_name = default_name or "search",
            search = paged_chrome.templated_page(Public.new_Search(log, where), "search"),
            aboutChrome = paged_chrome.templated_page(Public.new_AboutChrome(log, where),
                                                      "aboutChrome"),
   }
end

return Public
