-- Makes luasql behave the same as the luakit one.

local sqlite3 = require("luasql.sqlite3").sqlite3

local Sql = {}

function Sql.new(tab)
   tab = (type(tab) == "table" and tab)
      or (type(tab) == "string" and { filename = tab })
   tab.conn = sqlite3(""):connect(tab.filename)
   return setmetatable(tab, Sql)
end

local SqlCursor = {
   __index = function(self, key)
      return function(self, i)  -- Get them if we dont have it already.
         if not self.done and i < #self.got then
            local new = true
            while #self.got < i do  -- Fetch until there or end.
               if not new then
                  self.done = true
                  return nil
               end
               new = self.cursor:fetch()
               table.insert(self.got, new)
            end
            table.insert(self.got, new)
            return i, new
         else
            return self.got[i]
         end
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
}

function Sql:exec(statement)  -- TODO question marks and arguments..
  -- TODO does it :close() itself automatically? Dont see how to..
   local cursor = self.conn:execute(statement)
   self.conn:commit()  -- Dont really support non-committal.
   return setmetatable({cursor = cursor, got = {}}, SqlCursor)
end

local SqlCompiled = {
   __index = {
      exec = function(self, args) return self.sql:exec(self.statement, args) end,
   }
}

function Sql:compile(statement)  -- Doesnt actually compile anything..
   return setmetatable({self=sql, statement = statement}, SqlCompiled)
end

Sql.__index = Sql
return Sql
