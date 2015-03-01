--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.


local html = lousy.load_asset("listview/assets/show_1.html") or ""

local function tags_html(tags) return function(class)
   class = class == "" and "" or class and " class=" .. class or [[ class="msg_tag"]]
   local ret = {}
   for _, tag in pairs(tags) do
      table.insert(ret, string.format("<span%s>%s</span>", class, tag))
   end
   return table.concat(ret, ", ")
end end

local function delta_t_html(dt)
   local adt = math.abs(dt)
   local s, min, h, d = 1000, 60000, 3600000, 24*3600000
   if adt < s then  -- milliseconds
      return string.format("%dms", dt)
   elseif adt < 10*s then  -- ~ 1s
      return string.format("%g s", math.floor(10*dt/s)/10)
   elseif adt < min then -- seconds
      return string.format("%d s", math.floor(dt/s))
   elseif adt < 10*min then -- ~ 1 min
      return string.format("%g min", math.floor(10*dt/min)/10)
   elseif adt < h then -- minutes
      return string.format("%d min", math.floor(dt/min))
   elseif adt < 10*h then -- ~1 hour
      return string.format("%g hours", math.floor(10*dt/h)/10)
   elseif adt < 3*d then -- hours
      return string.format("%d hours", math.floor(dt/h))
   elseif adt < 10*d then -- ~ day
      return string.format("%g days", math.floor(10*dt/d)/10)
   else
      return string.format("%g days", math.floor(dt/d))
   end
end

msg_meta.direct.tagsHTML = function(self)
   return tags_html(self.tags)(self.html_state.tagsclass) 
end
msg_meta.direct.dateHTML = function(self)
   local state = self.html_state
   local t, ret = math.floor(self.id/1000), ""
   if not state.last_time then
         ret = os.date(nil, math.floor(t/1000)) 
   else
      ret = delta_t_html(t - state.last_time)
   end
   state.last_time = t
   return "<span class=\"time\">" .. ret .. "</span>"
end 

function html_msg(state)
   return function (index, msg)
      msg.html_state = state
--      for _, el in pairs({"tags", "date"}) do  -- Make then 'real' as needed.
--         if string.find(html, el .. "HTML") then
--            msg[el .. "HTML"] = msg[el .. "HTML"](state)
--         end
--      end
      msg.index = index
      for _, k in pairs({"title", "desc", "uri", "origin"}) do 
         msg[k] = msg[k] or ""
      end
      -- TODO put in more stuff.
      return string.gsub(html, "{%%(%w+)}", msg)
   end
end

function html_msg_list(data)
   local state = { last_time = cur_time_ms() }
   return html_list(data, html_msg(state))
end
