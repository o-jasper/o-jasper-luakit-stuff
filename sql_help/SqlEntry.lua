--  Copyright (C) 18-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local metatable_of = require("o_jasper_common.meta").metatable_of
local cur_time_raw = require("o_jasper_common.cur_time").raw

-- Makes a metatable for entries, to get functions handy.
local SqlEntry = {

   tags = function(self)
      return self.origin:just_tags(self[self.values.idname])
   end,
   
   has_tag = function(self, tagname)
      return self.origin:has_tag(self[self.values.idname], tagname)
   end,

   ms_t = function(self)
      return math.floor(self[self.values.time]*self.values.timemul)
   end,
   
   -- Delete in DB.
   delete = function(self)
      self.origin:delete_id(self.id)
   end,
   -- Pass any changes to object to the database.
   --   db_update = function(self)
   --      self.origin:update_id(self)
   --   end,
   
   otherwise = function(self, key) -- TODO Uhm..
      local meta = getmetatable(self).meta
      if meta.values.string_els[key] then
         meta.defaults[key] = ""
         return meta.defaults[key]
      end
      if meta.values.int_els[key] then
         meta.defaults[key] = 0
         return meta.defaults[key]
      end
      --for k, _ in pairs(meta.values.string_els) do print(k, key) end
      --error(string.format("Dont know this key %s", key))
      return "N/A" -- Less control, but allows the html to request stuff we dont have.
   end,
}

return metatable_of(SqlEntry)
