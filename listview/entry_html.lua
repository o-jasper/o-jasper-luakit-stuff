--  Copyright (C) 22-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require "o_jasper_common"
local ot = require "o_jasper_common.html.other"
local tt = require "o_jasper_common.html.time"

local SqlEntry = require("sql_help").SqlEntry

local Public = {}

Public.default_html_calc = {
   tagsHTML = function (self, state)
      if self.values.taggings then
         return ot.tagsHTML(self:tags(), state.tagsclass)
      else
         return " "
      end
   end,

   delta_dateHTML = function(self, state)
      return tt.delta_dateHTML(state, self:ms_t())
   end,
   
   timemarks = function(self, state)
      return tt.timemarks(state, self:ms_t())
   end,

   resay_timemarks = function(self, state)
      return tt.resay_timemarks(state, self:ms_t())
   end,

   identifier = function(self, _)
      return c.int_to_string(self[self.values.idname])
   end,
}
for k,v in pairs(os.date("*t", 0)) do
   Public.default_html_calc[k] = "{%time_" .. k .. "}"
end

Public.default_html_calc.min  = "{%time_M}"
Public.default_html_calc.hour = "{%time_H}"
Public.default_html_calc.month  = "{%time_h}"

local function datetab(ms_t)
   return os.date("*t", math.floor(ms_t/1000))
end

function Public.default_html_calc.dayname(self, _)
   return Public.day_names[datetab(self:ms_t()).wday]
end
function Public.default_html_calc.monthname(self, _)
   return Public.day_names[datetab(self:ms_t()).wday]
end

-- Replacement list.
function Public.repl(entry, state)
   assert(entry)
   local pass = {}
   for _,name in pairs(entry.values.row_names) do  -- Grab the data.
      if not entry[name] or entry[name] == "" then
         pass[name] = " "
      else
         pass[name] = entry[name]
      end
   end
   local function calc(_, key)
      local fun = state.html_calc[key]
      if type(fun) == "function" then
         return fun(entry, state)
      elseif type(fun) == "string" then
         return fun
      elseif string.match(key, "time_.+") then
         local got = datetab(entry:ms_t())[string.sub(key, 6)]
         if got then
            return got
         else
            return os.date("%" .. string.sub(key, 6), math.floor(entry:ms_t()/1000))
         end
      end
   end
   return setmetatable(pass, {__index=calc})
end

-- Single entry.
function Public.msg(listview, state)
   return function (index, msg)
      state.index = index
      return c.full_gsub(listview:asset("parts/show_1"),
                          Public.repl(msg, state))
   end
end

function Public.list(listview, data, state)
   assert(state) --state = state or {}
   state.last_time = state.last_time or c.cur_time.ms()
   state.config = state.config or {}
   state.html_calc = state.html_calc or Public.default_html_calc
   local str = "<table>"
   for i, el in pairs(data) do 
      str = str .. Public.msg(listview, state)(i, el)
   end
   return str .. "</table>"
end

return Public
