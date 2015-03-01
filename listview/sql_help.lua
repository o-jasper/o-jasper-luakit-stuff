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
   extcmd = function(self) return function(str, ...)
         local start = self.first and "WHERE " or self.how .. " "
         table.insert(self.cmd, string.format(start .. str, ...))
         self.first = false
   end end,

   incorporate = function(self) return function(subhelp)
         for _, cmd in pairs(subhelp.cmd)   do table.insert(self.cmd,   cmd) end
         for _, inp in pairs(subhelp.input) do table.insert(self.input, inp) end
   end end,

   equal_one_or_list = function (self) return function(which, input)
         if type(input) == "string" then
            table.insert(self.cmd, self.extcmd("%s == ?", which))
            table.insert(self.input, input)
         else
            assert(type(input) == "table")
            
            local str = {string.format("%s IN (?", which)}
            for i, f in pairs(input) do
               table.insert(self.input, f)
               if i ~= 1 then table.insert(str, "?") end
            end
            self.extcmd(table.concat(str, ", ") .. ")")
         end
   end end,

   sql_range  = function (self) return function(which, from, to)  -- TODO
         if type(from) == "table" then
            assert(not to)
            to = from[2]
            from = from[1]
         end
         if from == to then
            self.extcmd("%s == ?", which)
            table.insert(self.input, from)
         else
            if from then
               self.extcmd("%s >= ?", which)
               table.insert(self.input, from)
            end
            if to then
               self.extcmd("%s <= ?", which)
               table.insert(self.input, to)
            end
         end
   end end,

   -- Note assumes `taggings` exists.
   require_tags = function (self) return function(tags, w)
         table.insert(self.input, tags)
         local h = sql_compose("AND", string.format([[%sEXISTS (
SELECT * FROM taggings]], w))
         h.extcmd([[to_id == m.id)]])
         h.equal_one_or_list("tag", tags)
         
         self.incorporate(h)
   end end,

   search = function(self) return function(search, what)
         self.extcmd([[%s LIKE ?]], what)
         table.insert(self.input, "%" .. search .. "%")
   end end,

   searchtxt = function(self) return function(search)
         local h = sql_compose("OR")
         for _, what in pairs({"title", "uri", "desc"}) do h.search(search, what) end
         self.incorporate(h)
   end end,

   -- NOTE/TODO not getting use, might remove.
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
         return table.concat(self.cmd, "\n") 
   end end,
   
   -- Note: not what is used for the actual query.
   sql_code = function(self) return function()
         local pat = lousy.util.string.split(self.sql_pattern(), "?")
         local str = pat[1]
         for i, el in pairs(self.input) do
            if string.find(el, "[%%]") then
               el = "'" .. el .. "'"
            end
            str = str .. el .. pat[i + 1]
         end
         return str
   end end,
   
   result = function(self) return function(db)
         -- TODO check number of questionmarks?
         local list = (db or self.db):exec(self.sql_pattern(), self.input)
         return self.fun and map(list, self.fun) or list
   end end,

}})

function sql_compose(how, initial)  -- Less involved a bit.
   local helper = {cmd = initial and {initial} or {}, first=true,
                   input = {},
                   how = how or "AND" }
   setmetatable(helper, sql_help_meta.table)
   return helper
end

function new_sql_help(how, initial, db, fun)
   if type(initial) == "table" then -- Is a list of stuff we want.
      initial = string.format("SELECT %s FROM msgs m", table.concat(initial, ", "))
   end
   local helper = {db = db, fun = fun, first=true,
                   cmd = {initial or [[SELECT * FROM msgs m]]},
                   input = {},
                   how = how or "AND" }
   setmetatable(helper, sql_help_meta.table)
   return helper
end
