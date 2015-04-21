--  Copyright (C) 18-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common.meta"

-- Makes a metatable for entries, to get functions handy.
local SqlEntry = {
   taggings="taggings",
   string_els={}, int_els={},
   tagfinder=[[SELECT tag FROM taggings WHERE to_id == ?]],

   determine = { tags_last = function(self) return 0 end },

   realtime_tags = function(self)
      local origin = self.origin
      if self.tags_last > origin.tags_last and rawget(self, "tags") then
         return rawget(self, "tags")
            end
      -- Get the tags.
      self.tags_last = cur_time()
      self.tags = {}
      local got = origin.db:exec(self.values.tagfinder, {self.id})
      for _, el in pairs(got) do
         table.insert(self.tags, el.tag)
      end
      return self.tags
   end,

   ms_t = function(self)
      return math.floor(self[self.values.time]*self.values.timemul)
   end,

      -- Delete in DB.
      --db_delete = function(self, )
      --   self.origin:delete(self.id)
      --end,
      -- Pass any changes to object to the database.
      --db_update = function(self, )
            --self.origin:update_entirely_by(self)
      --end,

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
SqlEntry.rt_tags = SqlEntry.realtime_tags
SqlEntry.determine.tags = function(self) return self:realtime_tags() end

return metatable_of(SqlEntry)
