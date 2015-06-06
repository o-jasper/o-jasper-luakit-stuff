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
   tagsHTML = function (entry, state)
      if entry.values.taggings then
         return ot.tagsHTML(entry:tags(), state.tagsclass)
      else
         return " "
      end
   end,

   dateText = function(entry)
      return os.date("%c", entry:ms_t()/1000)
   end,

   dateHTML = function(entry)  -- TODO tad primitive...
      return "{%dateText}"
   end,

   -- NOTE: the delta/resay cases only make sense when sorting by time.
   -- TODO: perhaps the state/state.config should tell this and have proper behavior.
   delta_dateHTML = function(entry, state)
      return tt.delta_dateHTML(state, entry:ms_t())
   end,
   
   timemarks = function(entry, state)
      return tt.time(state, entry:ms_t())
   end,

   resay_time = function(entry, state)
      return tt.resay_time(state, entry:ms_t(), (state.config.resay or {}).long)
   end,
   
   short_resay_time = function(entry, state)
      local config = (state.config.resay or {}).short or {
         {"year", "Year {%year}"},
         {"yday", "{%month}/{%day} {%short_dayname}"},
         init = " ", nochange = " ",
      }
      return tt.resay_time(state, entry:ms_t(), config)
   end,

   -- Writes it out properly.
   identifier = function(entry, _)
      return c.int_to_string(entry[entry.values.idname])
   end,

   markdown_desc = {
      function(entry)
         -- TODO.. ... discount isnt co-operating..
         --  strange, luajit works, but luakit compiled with it doesnt.
         -- local discount = require("discount") --package.loaded("discount")
         local markdown = require "markdown"
         if markdown then
            return markdown(entry.desc or ""), 2
         else
            return entry.desc, 1
         end
      end,
   },
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

Public.default_html_pattern_calc = {
   ["^time_"] = function(entry, state, key)
      local got = datetab(entry:ms_t())[string.sub(key, 6)]
      if got then
         return got
      else
         return os.date("%" .. string.sub(key, 6), math.floor(entry:ms_t()/1000))
      end
   end,
}

function Public.default_html_calc.dayname(entry)
   return tt.day_names[datetab(entry:ms_t()).wday]
end
function Public.default_html_calc.monthname(entry)
   return tt.day_names[datetab(entry:ms_t()).wday]
end

--local function cap_priority(fun, to_priority)
--   return function(entry, priority)
--      local result, ret_priority = fun(entry, priority)
--      return result, math.max(ret_priority, to_priority)
--   end
--end

-- Replacement list. -- TODO use `c.repl`?
local function replacement(entry, state)
   assert(entry)
   local pass = {}
   for _,name in pairs(entry.values.row_names) do  -- Grab the data.
      if not entry[name] or entry[name] == "" then
         pass[name] = " "
      else
         pass[name] = entry[name]
      end
   end
   return c.repl(entry, state,
                 pass, state.html_calc, state.html_pattern_calc)
end

-- Single entry.
function Public.msg(listview, state)
   return function (index, msg)
      state.index = index
      return c.apply_subst(listview:asset("parts/show_1.html"), replacement(msg, state))
   end
end

function Public.list(listview, data, state)
   assert(state) --state = state or {}
   state.last_time = state.last_time or c.cur_time.ms()
   state.config = state.config or {}
   state.config.priority_funs = state.config.priority_funs or Public.default_priority_funs

   state.html_calc = state.html_calc or Public.default_html_calc
   state.html_pattern_calc = state.html_pattern_calc or Public.default_html_pattern_calc
   local str = "<table>"
   for i, el in pairs(data) do 
      str = str .. Public.msg(listview, state)(i, el)
   end
   return str .. "</table>"
end

return Public
