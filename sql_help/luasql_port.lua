-- Makes luasql behave the same as the luakit one.

local string_split = require "o_jasper_common.string_split"

local sqlite3 = require("luasql.sqlite3").sqlite3

local Sql = {}

function Sql.new(tab)
   tab = (type(tab) == "table" and tab)
      or (type(tab) == "string" and { filename = tab })
   tab.conn = sqlite3(""):connect(tab.filename)
   return setmetatable(tab, Sql)
end

local SqlCursor = {
   __index = function(self, i)
      local got, cur = rawget(self, "got"), rawget(self, "cursor")
      if not rawget(self, "done") and i < #got then
         local new = true
         while #got < i do  -- Fetch until there or end.
            if not new then
               self.done = true
               return nil
            end

            local here = table.pack(cur:fetch())
            new = {}
            for i, name in pairs(cur:getcolnames()) do
               new[name] = here[i]
            end
            table.insert(got, new)
         end
         table.insert(got, new)
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
}

-- NOTE: high security risk zone.
function Sql:exec(statement, args)  -- TODO question marks and arguments..
   args = args or {}
   local parts = string_split(statement, "?")
   assert( #args == #parts - 1, "not enough arguments")
   local command_str, j = "", 1
   while j < #parts do
      command_str = command_str .. parts[j] .. self.conn:escape(tostring(args[i]))
      j = j + 1
   end

   print(command_str)
  -- TODO does it :close() itself automatically? Dont see how to..
   local cursor = self.conn:execute(command_str)
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
