-- Makes luasql behave the same as the luakit one.

local string_split = require "o_jasper_common.string_split"

local sqlite3 = require("luasql.sqlite3").sqlite3("")

local Sql = {}

function Sql.new(tab)
   tab = (type(tab) == "table" and tab)
      or (type(tab) == "string" and { filename = tab })
   tab.conn = sqlite3:connect(tab.filename)
   return setmetatable(tab, Sql)
end

local SqlCursor = {
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

-- NOTE: high security risk zone.
function Sql:exec(statement, args)  -- TODO question marks and arguments..
   args = args or {}
   local command_str = ""
   local parts = string_split(statement, "?")
   assert( #args == #parts - 1, "not enough arguments")
   local command_str, j = "", 1
   while j < #parts do
      local val = self.conn:escape(tostring(args[j]))
      if type(val) == "string" then val = "'" .. val .. "'" end
      command_str = command_str .. parts[j] .. val
      j = j + 1
   end
   return self:list_cursor(self:_cursor(command_str))
end

function Sql:_cursor(command_str)
   local cursor = self.conn:execute(command_str)
   if cursor then
      return cursor
   else  -- Close it and try again.
      print(command_str)
      self.conn:close()
      self.conn = sqlite3:connect(self.filename)
      return self.conn:execute(command_str)
   end
end

function Sql:list_cursor(cursor)
   -- TODO does it :close() itself automatically? Dont see how to..
   if cursor then
      local ret, new = {}, {}
      while cursor:fetch(new, "a") do
         table.insert(ret, new)
         new = {}
      end
      cursor:close()
      return ret
   else
      print("no cursor")
      return {}
   end
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
