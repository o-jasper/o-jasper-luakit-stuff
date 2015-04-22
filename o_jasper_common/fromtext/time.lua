
local ms = require("o_jasper_common.cur_time").ms

local Public = {}

function Public.time_interpret(str, from_t)
   local i, j = string.find(str, "[%-]?[%d]+[.]?[%d]*")
   if j == 0 then
      i, j = string.find(str, "[%-]?[%d]*[.]?[%d]+")
   end
   if not i or i > 2 then return nil end
   if i == 2 then
      if string.sub(str, 1, 1) == "a" then from_t = 0 else return nil end
   end

   -- TODO next to time-differences could also do 'day before'
   local num = tonumber(string.sub(str, i or 1, j ~= 0 and j or #str))
   if j == #str then return 1000*((from_t or ms()) + 1000*num) end

   local min = 60000
   local h = 60*min
   local d = 24*h
   local f = ({ms=1, s=1000, ks=1000000, min=min, h=h, d=d, D=d,
               week=7*d, wk=7*d, w=7*d, M=31*d, Y=365.25*d})[string.sub(str, j + 1)]
   
   return f and 1000*((from_t or ms()) + num*f)
end

return Public
