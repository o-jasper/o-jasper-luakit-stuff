--  Copyright (C) 24-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO taggings can be used for similar purposes..
--  Likely good to rename the concept, and have ability to use the concept
--   multiple times, the same way.

-- TODO make it only _compose_ it.

local metatable_of = require "o_jasper_common.meta"
local cur_time = require("o_jasper_common.cur_time")

local Public = {}

local map = require("o_jasper_common.other").map

local SqlEntry = require "sql_help.SqlEntry"
assert(type(SqlEntry) == "table")

local time_interpret = require("o_jasper_common.fromtext.time").time_interpret
local searchlike = require("o_jasper_common.fromtext.searchlike")

local string_split = lousy.util.string.split

local function qmarks(n)  -- Makes a string with a number of question marks in it.
   if n == 0 then return "" end
   local str = "?"
   while n > 1 do
      str = str .. ", ?"
      n = n - 1
   end
   return str
end

local SqlHelp = {
   values = {
      textlike = {"title", "uri", "desc"},
      taggings = "taggings", tagname="tag",
      order_by = "id",
      idname = "id", 
      time = "id", timemul = 0.001,
   },
   c = false, tags_last = 0, last_id_time = 0,
   
   -- Intended as replacable ("virtual")
   listfun = function(_, list)
      for _, data in pairs(list) do
         assert(type(data) == "table")
         data.origin = self
         setmetatable(data, SqlEntry)
      end
      return list
   end,
   
   -- Important: gotta be a _new_ one!
   -- Note: use this is you want to "build" a search.
   -- Otherwise the state is hanging around. (you can use it just the same)
   new_SqlHelp = function(self, initial, fun)
      -- TODO multiple table names?
      initial = initial or {string.format([[SELECT * FROM %s m]], self.values.table_name)}
      return setmetatable({db=self.db, 
                           input = {}, cmd=initial,
                           first=first or  "WHERE", produce_entry=fun},
                          getmetatable(self))
   end,
   
   exec = function(self, ...) return self:listfun(self.db:exec(...)) end,
   
   -- Stuff to help me construct queries based on searches.
   extcmd = function(self, str, ...)
      if self.c then
         str = self.c .. " " .. str
         self.c = false
      end
      self.first = false
      self.c = ""
      table.insert(self.cmd, string.format(str, ...))
   end,
   -- A piece of input.
   inp = function(self, what)
      if type(what) ~= "table" then
         what = tostring(what)
      end
      assert(type(what) == "string",
             string.format("E(BUG): Not a string %s", what))
      table.insert(self.input, what)
   end,
   -- Manually add string.
   addstr = function(self, str, ...)
      self.cmd[#self.cmd] = self.cmd[#self.cmd] .. string.format(str, ...)
   end,
   
   -- Combines the things.
   comb = function(self, how, down)
      self.c = self.first or how or self.how
   end,
   
   -- Selecting.
   select_from_table = function(self, table_name)
      table.insert(self.cmd, string.format([[SELECT * FROM %s m]],
                                           table_name or self.values.table_name))
   end,
   
   -- Deleting. -- TODO problem is.. then you want to get all the tags too.
   --   delete = function(self, table_name)
   --      table.insert(self.cmd, string.format([[DELETE FROM %s m]],
   --                                           table_name or self.values.table_name))
   --   end,
   
   -- Lots of stuff to build searches from.
   equal_one_or_list = function(self, which, input)
      if type(input) == "table" then
         if #input > 1 then
            local str = {string.format("%s IN (?", which)}
            for i, f in pairs(input) do
               self:inp(f)
               if i ~= 1 then table.insert(str, "?") end
            end
            self:extcmd(table.concat(str, ", ") .. ")")
            return
         end
         input = input[1]
      end
      assert(type(input) == "string")
      self:extcmd("%s == ?", which)
      self:inp(input)
   end,
   
   -- Value less/greater then ..
   lt  = function (self, which, value)  -- TODO
      self:extcmd([[%s < ?]], which)
      self:inp(value)
   end,   
   gt  = function (self, which, value)  -- TODO
      self:extcmd([[%s > ?]], which)
      self:inp(value)
   end,
   -- Time is after/before ..
   after = function(self, time)
      self:gt(self.values.time, time)
   end,
   before = function(self, time)
      self:gt(self.values.time, time)
   end,
   
   -- Add a like command.
   like = function(self, value, what, n)
      self:extcmd([[%s LIKE ?]], n and what .." NOT" or what)
      self:inp(value)
   end,
   not_like = function(self, value, what)
      self:like(value, what, true)
   end,
   
   -- a LIKE command on all textlike parts.
   text_like = function(self, search, n)
      if self.first then 
         if n then
            self.first = self.first .. "NOT ("
         else
            self.first = self.first .. "(" 
         end
      end
      for i, what in pairs(self.values.textlike) do
         self:comb((i == 1 and self.c .. ((n and " NOT(") or "(")) or "OR")
         self:like(search, what)
      end
      self:addstr(")")
   end,
   
   -- Search wordm any textlike. (does that LIKE command with '%' around)
   text_sw = function(self, search, n)
      if #search > 0 then
         self:text_like('%' .. search .. '%', n)
      end
   end,
   
   -- Any exact tag.
   tags = function (self, tags, taggingsname, tagname, w)
      if #tags == 0 then return end
      --         self:addstr("\nJOIN %s t ON t.to_id == m.id AND %s (",
      --                     taggingsname or self.values.taggings, w or "")
      --         local fw, cw = self.first, self.c
      --         self.first = false
      --         self.c = ""
      --         self.equal_one_or_list("t." .. (tagname or self.values.tagname), tags)
      --         self.addstr(")")
      --         self.first, self.c = fw, cw
      
      self:extcmd([[%sEXISTS (
SELECT * FROM %s
WHERE to_id == m.id]], w or "", taggingsname or self.values.taggings)
      self:comb("AND")
      self:equal_one_or_list(tagname or self.values.tagname, tags)
      self:addstr(")")
   end,
   not_tags = function(self, tags, taggingsname, tagname)
      self:tags(tags, taggingsname, tagname, "NOT ")
   end,
   
   -- The actual search build from it.
   -- TODO thing is.. kindah becomes a myriad of things it has do..
   --  To keep things organized, separate this off into a file
   ---  particularly for this purpose.
   search = function(self, str)
      local matchable = {"like:", "-like:", "tags:", "-tags", "-", "not:", "\\-", "or:",
                         "uri:", "desc:", "title:",
                         "urilike:", "desclike:", "titlelike:",
                         "before:", "after:"}
      local tagged_list = searchlike.searchlike(searchlike.portions(str), matchable)
      
      local n, tags, not_tags, before_t, after_t = false, {}, {}, nil, nil
      for i, el in pairs(tagged_list) do
         local m, v = el.m, el.v
         self:comb()
         local reset = true
         if m == "-like:" or m == "-lk:" or m == "like:" or m == "lk:" then
            self:text_like(v, try, string.sub(m, 1, 2) == "-")
         elseif m == "tags:" or m == "tag:" then
            for _, t in pairs(string_split(v, "[,;]")) do table.insert(tags, t) end
         elseif m == "-tags:" or m == "-tag:" then
            for _, t in pairs(string_split(v, "[,;]")) do table.insert(not_tags, t) end
         elseif m == "not:" or m == "-" then
            n = n or (m == "not:")
            self:text_sw(v, true)
         elseif m == "\\-" then
            self:text_sw("-" .. v, n)
         elseif m == "or:" then  -- NOTE `or:` takes precidence here!!
            self.how = "OR"
            if v then 
               self:text_sw(w, n)
            else -- Wait a sec.
               reset = true
            end
         elseif m == "uri:" or m == "desc:" or m == "title:" then
            self:like(v, '%' .. string.sub(m, 1, #m - 1) .. '%', n)
         elseif m == "urilike:" or m == "desclike:" or m == "titlelike:" then
            self:like(v, string.sub(m, 1, #m-5), n)
         elseif m == "after:" and time_interpret(v) then
            after_t = math.max(after_t or 0, time_interpret(v))
         elseif m == "before:" and time_interpret(v) then
            if before_t then
               before_t = math.min(before_t, time_interpret(v))
            else
               before_t = time_interpret(v)
            end
         else
            self:text_sw(v, n)
         end
         if reset then self.how = "AND" end
      end
      self.how = "AND"
      self:comb()
      self:tags(tags)
      self:comb()
      self:not_tags(not_tags)
      if before_t then self:comb() self:before(before_t) end
      if after_t then self:comb() self:after(after_t) end
   end,
   
   -- Sorting it.
   order_by = function(self, what, way)
      if type(what) == "table" then what = table.concat(what, ", ") end
      self.c = ""
      self:extcmd("ORDER BY %s %s", what, way or "DESC")
   end,
   
   -- Limiting the number of results.
   row_range = function(self, fr, cnt) 
      self.c = ""
      self:extcmd("LIMIT ?, ?")
      self:inp(fr)
      self:inp(cnt)
   end,
   
   -- Patterns with all the questionmarks to be filled with `self.input`.
   sql_pattern = function(self)
      return table.concat(self.cmd, "\n") 
   end,
   
   -- Manually fill those in. USE THE SQL VERSION.
   -- TODO SQL exposes it?
   sql_code = function(self)
      local pat = string_split(self:sql_pattern(), "?")
      local str = pat[1] or "{NOPE1}"
      for i, el in pairs(self.input) do
         if string.find(el, "[%%]") then
            el = "'" .. el .. "'"
         end
         str = str .. el .. (pat[i + 1] or string.format("{NOPE%d}", i + 1))
      end
      return str
   end,
   
   raw_result = function(self, db)
      return (db or self.db):exec(self:sql_pattern(), self.input)
   end,
   
   -- Get the result of the current query on a DB.
   result = function(self, db) return self:listfun(self:raw_result(db)) end,
   
   -- Represents the entry as list in the order of the names.
   args_in_order = function(self, entry)
      assert(type(self.values.row_names) == "table")
      return map(self.values.row_names, function(name) return entry[name] end)
   end,
   
   -- Adding/removing
   
   -- Remove all positive results.
   delete_result = function(self, table_name, db)
      db = db or self.db
      local list = self:raw_result(self, db)
      for _, entry in pairs(list) do -- Then delete all of them.
         self:delete_id(self, entry[self.values.idname], table_name)
      end
      return list
   end,   
   
   -- Add an entry.
   enter = function(self, add)
      assert(self.values.table_name and self.values.row_names)
      
      local ret = {}
      if add.keep then  -- Only bother getting it if it is keepworthy.
         local sql = string.format("INSERT INTO %s VALUES (%s)",
                                   self.values.table_name, qmarks(#self.values.row_names))
         ret.add = self.db:exec(sql, self.args_in_order(add))
         -- And all the tags, if we do those.
         if add.tags and #add.tags > 0 and self.values.taggings then
            self.tags_last = cur_time.raw()  -- Note time last changed.
            local tags_insert = string.format([[INSERT INTO %s VALUES (?, ?);]],
                                              self.value.taggings)
            ret.tags = {}
            for _, tag in pairs(add.tags) do
               table.insert(ret.tags, self.db:exec(tags_insert, {add.id, tag}))
            end
         end
      end
      return ret
   end,
   
   -- Delete an entry.
   delete_id = function(self, id, table_name)
      table_name = table_name or self.values.table_name
      self.db:exec(string.format("DELETE FROM ? WHERE %s == ?", self.values.idname),
                   { table_name, id })
      
      if taggings then
         self.db.exec(string.format("DELETE FROM ? WHERE to_%s == ?",self.values.idname),
                      { self.values.taggings, id })
      end
   end,
   
   -- Change an entry.
   -- TODO use update and stuff.
   -- update_id
}

return metatable_of(SqlHelp)
