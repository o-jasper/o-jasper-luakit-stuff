--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common"
local html = load_asset("listview/assets/parts/show_1.html") or ""

local function tags_html(tags) return function(class)
   class = class == "" and "" or class and " class=" .. class or [[ class="msg_tag"]]
   local ret = {}
   for _, tag in pairs(tags) do
      table.insert(ret, string.format("<span%s>%s</span>", class, tag))
   end
   return table.concat(ret, ", ")
end end

-- TODO pretty messy..
local function delta_t_html(dt, pre, aft)
   pre, aft = pre or "", aft or ""
   local adt = math.abs(dt)
   local s, min, h, d = 1000, 60000, 3600000, 24*3600000
   if adt < s then  -- milliseconds
      return string.format("%d%sms%s", dt, pre, aft)
   elseif adt < 10*s then  -- ~ 1s
      return string.format("%g%ss%s", math.floor(10*dt/s)/10, pre, aft)
   elseif adt < min then -- seconds
      return string.format("%d%ss%s", math.floor(dt/s), pre, aft)
   elseif adt < 10*min then -- ~ 1 min
      return string.format("%g%s min%s", math.floor(10*dt/min)/10, pre, aft)
   elseif adt < h then -- minutes
      return string.format("%d%smin%s", math.floor(dt/min), pre, aft)
   elseif adt < 10*h then -- ~1 hour
      return string.format("%g%s hours%s", math.floor(10*dt/h)/10, pre, aft)
   elseif adt < 3*d then -- hours
      return string.format("%d%shours%s", math.floor(dt/h), pre, aft)
   elseif adt < 10*d then -- ~ day
      return string.format("%g%sdays%s", math.floor(10*dt/d)/10, pre, aft)
   else
      return string.format("%g%sdays%s", math.floor(dt/d), pre, aft)
   end
end

function msg_meta.direct.tagsHTML(self)
   return tags_html(self.tags)(self.html_state.tagsclass) 
end
function msg_meta.direct.dateHTML(self, key)
   local state = self.html_state
   local t, ret = math.floor(self.id/1000), ""
   if not state.last_time then
      ret = os.date(nil, math.floor(t/1000)) 
   else
      local datecfg = state.config.date or {}
      ret = delta_t_html(t - state.last_time, datecfg.pre, datecfg.aft)
   end
   state.last_time = t
   return ret
end 

function msg_meta.direct.timemarks(self)
   local state, t = self.html_state, math.floor(self.id/1000000)
   local tm = state.timemarks
   if not tm then
      state.timemarks = os.date("*t", t)
      return ""
   end
   local str, d = "", os.date("*t", t)
   local default_care = {{"year", "Y"}, {"month", "M"}, {"yday", "d"},
                         {"hour", "h"}, {"min", "<small>m</small>"}}
   for _, el in pairs(state.config.timemarks or default_care) do
      local k, v = el[1], el[2]
      if d[k] ~= tm[k] then
         str = str .. v
         tm[k] = d[k]
      end
   end
   return str
end

function html_msg(state)
   return function (index, msg)
      msg.html_state = state
      msg.index = index
      for _, k in pairs({"title", "desc", "uri", "origin"}) do 
         msg[k] = msg[k] or ""
      end
      -- TODO put in more stuff.
      return string.gsub(html, "{%%(%w+)}", msg)
   end
end

function html_msg_list(data, config)
   local pass_state = { 
      last_time = cur_time_ms(),
      config = config or {}
   }
   return html_list(data, html_msg(pass_state))
end
