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

-- NOTE: high security risk zone.
function Sql:command_string(statement, args)  -- TODO question marks and arguments..
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
   return command_str
end

function Sql:_cursor(command_str)
   local cursor = self.conn:execute(command_str)
   if cursor then
      return cursor
   else  -- Close it and try again.
      self.conn:close()
      self.conn = sqlite3:connect(self.filename)
      return self.conn:execute(command_str)
   end
end

function Sql:cursor(statement, args)
   return self:_cursor(self:command_string(statement, args))
end

-- Produces an entire list immediately.
function Sql:list_cursor(cursor)
   if not cursor then return {} end  -- Hope its alright..

   local ret, new = {}, {}
   while cursor:fetch(new, "a") do
      table.insert(ret, new)
      new = {}
   end
   cursor:close()
   return ret
end

function Sql:exec(statement, args)
   return self:list_cursor(self:cursor(statement, args))
end

Sql.SqlCompiled = {
   __index = {
      exec = function(self, args) return self.sql:exec(self.statement, args) end,
   }
}

function Sql:compile(statement)  -- Doesnt actually compile anything..
   return setmetatable({sql=self, statement = statement}, self.SqlCompiled)
end

local c = require "o_jasper_common"

return c.metatable_of(Sql)
