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
   taggings="taggings",
   string_els={}, int_els={},
   tagfinder=[[]],
   
   tags = function(self)
      local origin = self.origin
      -- Get the tags.
      self.tags = {}
      local sql = string.format("SELECT tag FROM %s WHERE to_id == ?", self.values.taggings)
      local got = origin.db:exec(sql, {self.id})
      for _, el in pairs(got) do
         table.insert(self.tags, el.tag)
      end
      return self.tags
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
   
   otherwise = function(self, key)
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
