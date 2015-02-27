--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "listview.common"

-- Chrome page of all logs. User may do subselection.

local sql_help_meta = metatable_for({
determine = {},
direct = {
   equal_one_or_list = function (self) return function(which, input)
         if type(input) == "string" then
            table.insert(self.cmd, string.format("WHERE %s == ?", which))
            table.insert(self.input, input)
         else
            assert(type(input) == "table")
            
            local str = inlist, {string.format("WHERE %s IN (?", which)}
            for i, f in pairs(input) do
               table.insert(self.input, f)
               if i ~= 1 then table.insert(str, "?") end
            end
            table.insert(self.cmd, table.concat(str, ", ") .. ")")
         end
   end end,

   sql_range  = function (self) return function(which, from, to)  -- TODO
         if type(from) == "table" then
            assert(not to)
            to = from[2]
            from = from[1]
         end
         if from == to then
            table.insert(self.cmd,   string.format("WHERE %s == ?", which))
            table.insert(self.input, from)
         else
            if from then
               table.insert(self.cmd, string.format("WHERE %s >= ?", which))
               table.insert(self.input, from)
            end
            if to then
               table.insert(self.cmd, string.format("WHERE %s <= ?", which))
               table.insert(self.input, to)
            end
         end
   end end,

   -- Note assumes `taggings` exists.
   require_tags = function (self) return function(tags, w)
         table.insert(self.input, tags)
         table.insert(self.cmd,   string.format([[WHERE %sEXISTS (
SELECT * FROM taggings]], w))
         self.equal_one_or_list("tag", tags)
         table.insert(self.cmd, [[AND to_id == m.id)]])
   end end,

   search = function(self) return function(search)
         table.insert(self.cmd, [[WHERE title LIKE ?
OR uri LIKE ?
OR desc LIKE ?]])
         local add = "%" .. search .. "%"
         table.insert(self.input, add)
         table.insert(self.input, add)
         table.insert(self.input, add)
         -- TODO also tags.
   end end,

   ui_data_selection = function(self) return function(config)
         if config.kind then self.equal_one_or_list("kind", config.kind) end
         if config.from then self.equal_one_or_list("origin", config.origin) end
         if config.must_tags then self.require_tags(config.must_tags) end
         if config.must_not_tags then self.require_tags(config.must_tags, " NOT ") end
         if config.search then self.search(config.search) end
         if config.claimtime then self.range("claimtime", config.claimtime) end
         if config.time then self.range("id", config.time) end
         if config.re_assess_time then self.range("claimtime", config.re_assess_time) end
   end end,

   sql_pattern = function(self) return function() 
         return table.concat(self.cmd, "\n") .. ";" 
   end end,
   
   -- Note: not what is used for the actual query.
   sql_code = function(self) return function()
         local pat = lousy.util.string.split(self.sql_pattern(), "?")
         local str = pat[1]
         for i, el in pairs(self.input) do
            str = str .. el .. pat[i + 1]
         end
         return str
   end end,
   
   result = function(self) return function()
         -- TODO check number of questionmarks?
         local ret = {}
         for _, el in pairs(self.db:exec(self.sql_pattern(), self.input)) do
            table.insert(ret, self.fun(el))
         end
         return ret
   end end,
}})

function new_sql_help(db, initial, fun)
   if type(initial) == "table" then -- Is a list of stuff we want.
      initial = string.format("SELECT %s FROM msgs m", table.concat(initial, ", "))
   end
   local helper = {db = db, fun=fun,
                   cmd = {initial or [[SELECT * FROM msgs m]]},
                   input = {}}
   setmetatable(helper, sql_help_meta.table)
   return helper
end
