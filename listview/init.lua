--  Copyright (C) 02=-2015 Jasper den Ouden.
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
local Public = {
   Base = require "listview.Base",
   Search = require "listview.Search",
   AboutChrome = require "listview.AboutChrome"
}

-- TODO dunno if the below are good to have around.. What about a `SomeName.new` instead..
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
