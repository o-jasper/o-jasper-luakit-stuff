--  Copyright (C) 14-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Makes a metatable for entries, to get functions handy.
sqlentry_meta = {
   defaults = {},
   values={
      taggings="taggings",
      string_els={}, int_els={},
      tagfinder=[[SELECT tag FROM taggings WHERE to_id == ?]],
   },
   determine = {},
   direct = {
      realtime_tags = function(self) return function()
            local logger = self.logger
            if logger.tags_last < logger.tags_last and rawget(self, "tags_last") then
               return rawget(self, "tags_last")
            end
            -- Get the tags.
            self.tags_last = cur_time()
            self.tags = {}
            local got = logger.db:exec(self.values.tagfinder, {self.id})
            for _, el in pairs(got) do
               table.insert(self.tags, el.tag)
            end
            return self.tags
      end end,
      -- Delete in DB.
      db_delete = function(self) return function()
            self.logger.delete(self.id)
      end end,
      -- Pass any changes to object to the database.
      db_update = function(self) return function()
            self.logger.update_entirely_by(self)
      end end,
   },
   otherwise=function(self, key)
      local meta = getmetatable(self).meta
      if meta.values.string_els[key] then
         meta.defaults[key] = ""
         return meta.defaults[key]
      end
      if meta.values.int_els[key] then
         meta.defaults[key] = 0
         return meta.defaults[key]
      end
      for k, _ in pairs(meta.values.string_els) do print(k, key) end
      error(string.format("Dont know this key %s", key))
   end,
}
sqlentry_meta.direct.rt_tags = sqlentry_meta.direct.realtime_tags
sqlentry_meta.determine.tags = function(self) return self.realtime_tags() end
