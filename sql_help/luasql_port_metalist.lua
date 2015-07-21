-- Keeps the cursor, and pretends we have the entire list already,
-- while actually draining as-needed from cursor.
--
-- Currently not used, because basically always all the list is
-- used anyway.

local c = require "o_jasper_common"

local Sql_metalist = c.copy_meta(require "sql_help.luasql_port")

-- Keeping the cursor, only getting what is needed.
-- (often end up doing the entire thing anyway)
-- NOTE: doesnt `:close` itself.
Sql_metalist.SqlCursor = {
   __index = function(self, i)
      local got, cur = rawget(self, "got"), rawget(self, "cursor")
      if not rawget(self, "done") and i > #got then
         local new = true
         while #got < i do  -- Fetch until there or end.
            new = {}
            if not cur:fetch(new, "a") then
               self.done = true
               return nil
            end
            table.insert(got, new)
         end
         return new
      else
         return got[i]
      end
   end,

   __pairs = function(self)
      return function(self, i)
         i = (i and i + 1) or 1
         if self[i] then
            return i, self[i] 
         end
      end, self
   end,

   --  afaik gotta get them all.
   __len = function(self)
      local n = #self.got
      while self[i] do n = n + 1 end
      return n
   end,
}

function Sql_metatlist:metalist_cursor(cursor)
   return setmetatable({cursor=cursor, got={}}, self.SqlCursor)
end

function Sql_metalist:exec(statement, args)
   return self:metalist_cursor(self:cursor(statement, args))
end

return c.metatable_of(Sql_metalist)
