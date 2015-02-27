--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

function bad(msg, what)
   return what
end

function msg_tags_sanity(msg, which)
   if msg[which] == "table" then
      for _, tag in pairs(msg[which]) do 
         if type(tag) ~= "string" then
            return bad(msg, string.format("One of the %s not a string", which))
         end
      end
      msg[which] = table.concat(msg[which])
   end
   if msg[which] ~= "string" then 
      return bad(msg, string.format("%s not a plain table or string.", which) )
   end
end

string_els = {"kind", "origin", "data", "data_uri", "uri", "title", "desc"}
int_els = {"claimtime", "id", "re_assess_time"}

function msg_sanity(msg)
   for _, k in pairs(string_els) do
      if type(msg[k]) ~= "string" then
         return bad(msg, string.format("%s element of `msg` not a string: %s(%s)", 
                                       k, msg[k], type(msg[k])))
      end
   end

   for _, k in pairs(int_els) do
      if not isinteger(msg[k]) then  return bad(msg, k .. " is not an integer") end
   end
   msg_tags_sanity(msg, "tags")
   msg_tags_sanity(msg, "datatags")
   return "good"
end
