local Public = {}

-- Functions helping out in writing time as text/html.

function Public.delta_t_html(dt, pre, aft)
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

function Public.dateHTML(state, ms_t)
   local ret = ""
   if not state.last_time then
      ret = os.date(nil, math.floor(ms_t/1000))
   else
      local datecfg = state.config.date or {}
      ret = Public.delta_t_html(ms_t - state.last_time, datecfg.pre, datecfg.aft)
   end
   state.last_time = ms_t
   return ret
end 

function Public.timemarks(state, ms_t)
   local tm = state.timemarks
   if not tm then
      state.timemarks = os.date("*t", math.floor(ms_t/1000))
      return ""
   end
   local str, d = "", os.date("*t", math.floor(ms_t/1000))
   local timemarks = state.config.timemarks or
      {{"year", "Y"}, {"month", "M"}, {"yday", "d"},
       {"hour", "h"}, {"min", "<small>m</small>"}}
   for _, el in pairs(timemarks) do -- Things we care to mark.
      local k, v = el[1], el[2]
      -- If that aspect of the date is no longer the same, increament it.
      if d[k] ~= tm[k] then
         if v then str = str .. v end  -- If want a string.
         -- TODO for instance, a horizontal line instead.
         tm[k] = d[k]
      end
   end
   return str
end

return Public