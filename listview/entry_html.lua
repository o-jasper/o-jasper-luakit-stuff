--  Copyright (C) 22-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local cur_time = require "o_jasper_common.cur_time"

local ot = require "o_jasper_common.html.other"
local tt = require "o_jasper_common.html.time"

local html_list = require "listview.html_list"

local SqlEntry = require("sql_help").SqlEntry

local default_html_calc = {}

function html_repl(entry, state)
   assert(entry)
   local pass = {}
   for _,name in pairs(entry.values.row_names) do  -- Grab the data.
      pass[name] = entry[name]
   end
   local function calc(_, key)
      local fun = state.html_calc[key]
      if fun then
         return fun(entry, state)
      end
   end
   return setmetatable(pass, {__index=calc})
end

function default_html_calc.tagsHTML(self, state)
   return ot.tagsHTML(self.tags, state.tagsclass)
end

function default_html_calc.dateHTML(self, state)
   return tt.dateHTML(state, self:ms_t())
end

function default_html_calc.timemarks(self, state)
   return tt.timemarks(state, self:ms_t())
end

-- Single entry.
function html_msg(listview, state)
   return function (index, msg)
      state.index = index
      return string.gsub(listview:asset("parts/show_1"), "{%%(%w+)}",
                         html_repl(msg, state))
   end
end

function html_msg_list(listview, data, state)
   state = state or { last_time = cur_time.ms() }
   state.config = state.config or {}
   state.html_calc = state.html_calc or default_html_calc
   return html_list.list(data, html_msg(listview, state))
end
