--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common"

local ot = require "o_jasper_common.html.other"
local tt = require "o_jasper_common.html.time"

SqlEntry = require("sql_help").SqlEntry

function SqlEntry.direct.html_repl(self) return function(state)
   assert(self)
   local pass = {}
   for _,name in pairs(self.values.row_names) do  -- Grab the data.
      pass[name] = self[name]
   end
   local calculators = self.html_calc
   local function calc(_, key)
      local fun = self.html_calc[key]
      if fun then
         return fun(self, state)
      end
   end
   return setmetatable(pass, {__index=calc})
end end

--- TODO better to add them to the other one?

function SqlEntry.html_calc.tagsHTML(self, state)
   return ot.tagsHTML(self.tags, state.tagsclass)
end

function SqlEntry.html_calc.dateHTML(self, state)
   return tt.dateHTML(state, self:ms_t())
end

function SqlEntry.html_calc.timemarks(self, state)
   return tt.timemarks(state, self:ms_t())
end

SqlEntry = metatable_of(SqlEntry)

-- TODO ... review below.

-- Single entry.
-- Requires a msg:repl_list
function html_msg(listview, state)
   return function (index, msg)
      state.index = index
      -- TODO..shouldnt be needed.
      for _, k in pairs({"title", "desc", "uri", "origin"}) do
         msg[k] = msg[k] or ""
      end
      -- TODO put in more stuff.
      return string.gsub(listview:asset("parts/show_1"), "{%%(%w+)}", msg:html_repl(state))
   end
end

function html_msg_list(listview, data)
   return html_list(data, html_msg(listview, { last_time = cur_time_ms(), config={} }))
end
