--  Copyright (C) 18-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO taggings can be used for similar purposes..
--  Likely good to rename the concept, and have ability to use the concept
--   multiple times, the same way.

-- TODO make it only _compose_ it.

local Public = {}

require "o_jasper_common" -- TODO make this properly namespaced too.
--local common = require "o_jasper_common"
--local map = common.map  

local SqlEntry = require "sql_help.SqlEntry"
assert(type(SqlEntry) == "table")

local time_interpret = require("o_jasper_common.fromtext.time").time_interpret
local searchlike = require("o_jasper_common.fromtext.searchlike").searchlike

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
values = {  -- TODO these are the thing.. should instead just get an object with them.
      textlike = {"title", "uri", "desc"},
      taggings = "taggings", tagname="tag",
      order_by = "id",
      idname = "id", 
      time = "id", timemul = 0.001,
},
defaults = { input = {}, c = false, tags_last = 0, last_id_time = 0 },
direct = {
   -- Note: use this is you want to "build" a search.
   -- Otherwise the state is hanging around. (you can use it just the same)
   new_SqlHelp = function(self) return function(initial, fun)
         -- TODO multiple table names?
         initial = initial or string.format([[SELECT * FROM %s m]], self.values.table_name)
         return setmetatable({db=self.db, cmd={initial},
                              first=first or  "WHERE", produce_entry=fun},
                             getmetatable(self))
   end end,

   -- Stuff to help me construct queries based on searches.
   extcmd = function(self) return function(str, ...)
         if self.c then
            str = self.c .. " " .. str
            self.c = false
         end
         self.first = false
         self.c = ""
         table.insert(self.cmd, string.format(str, ...))
   end end,
   -- A piece of input.
   inp = function(self) return function(what)
         if type(what) ~= "table" then
            what = tostring(what)
         end
         assert(type(what) == "string",
                string.format("E(BUG): Not a string %s", what))
         table.insert(self.input, what)
   end end,
   -- Manually add string.
   addstr = function(self) return function(str, ...)
         self.cmd[#self.cmd] = self.cmd[#self.cmd] .. string.format(str, ...)
   end end,
   
   -- Combines the things.
   comb = function(self) return function(how, down)
         self.c = self.first or how or self.how
   end end,

   -- Lots of stuff to build searches from.
   equal_one_or_list = function (self) return function(which, input)
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
   end end,

   -- Value less/greater then ..
   lt  = function (self) return function(which, value)  -- TODO
         self:extcmd([[%s < ?]], which)
         self:inp(value)
   end end,   
   gt  = function (self) return function(which, value)  -- TODO
         self:extcmd([[%s > ?]], which)
         self:inp(value)
   end end,
   -- Time is after/before ..
   after = function(self) return function(time)
         self:gt(self.values.time, time)
   end end,
   before = function(self) return function(time)
         self:gt(self.values.time, time)
   end end,
   
   -- Add a like command.
   like = function(self) return function(value, what, n)
         self:extcmd([[%s LIKE ?]], n and what .." NOT" or what)
         self:inp(value)
   end end,
   not_like = function(self) return function(value, what)
         self:like(value, what, true)
   end end,

   -- a LIKE command on all textlike parts.
   text_like = function(self) return function(search, n)
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
   end end,

   -- Search wordm any textlike. (does that LIKE command with '%' around)
   text_sw = function(self) return function(search, n)
         if #search > 0 then
            self:text_like('%' .. search .. '%', n)
         end
   end end,

   -- Any exact tag.
   tags = function (self) return function(tags, taggingsname, tagname, w)
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
WHERE to_id == m.id]], w or "", self.values.taggings)
         self:comb("AND")
         self:equal_one_or_list(tagname or self.values.tagname, tags)
         self:addstr(")")
   end end,
   not_tags = function(self) return function(tags, taggingsname, tagname)
         self:tags(tags, taggingsname, tagname, "NOT ")
   end end,

   -- The actual search build from it.
   -- TODO thing is.. kindah becomes a myriad of things it has do..
   --  To keep things organized, separate this off into a file
   ---  particularly for this purpose.
   search = function(self) return function(str)
         local matchable = {"like:", "-like:", "tags:", "-tags", "-", "not:", "\\-", "or:",
                            "uri:", "desc:", "title:",
                            "urilike:", "desclike:", "titlelike:",
                            "before:", "after:"}
         local tagged_list = searchlike(portions(str), matchable)

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
   end end,

   -- Sorting it.
   order_by = function(self) return function(what, way)
         if type(what) == "table" then what = table.concat(what, ", ") end
         self.c = ""
         self:extcmd("ORDER BY %s %s", what, way or "DESC")
   end end,
   
   -- Limiting the number of results.
   row_range = function(self) return function(fr, cnt) 
         self.c = ""
         self:extcmd("LIMIT ?, ?")
         self:inp(fr)
         self:inp(cnt)
   end end,

   -- Patterns with all the questionmarks to be filled with `self.input`.
   sql_pattern = function(self) return function()
         return table.concat(self.cmd, "\n") 
   end end,
   
   -- Manually fill those in. USE THE SQL VERSION.
   -- TODO SQL exposes it?
   sql_code = function(self) return function()
         local pat = string_split(self:sql_pattern(), "?")
         local str = pat[1]
         for i, el in pairs(self.input) do
            if string.find(el, "[%%]") then
               el = "'" .. el .. "'"
            end
            str = str .. el .. pat[i + 1]
         end
         return str
   end end,
   
   -- Get the result of the current query on a DB.
   result = function(self) return function(db)
         -- TODO check number of questionmarks?
         local list = (self.db or db):exec(self:sql_pattern(), self.input)
         if self.produce_entry then
            --local ret = {}
            --for _, entry in pairs(list) do
            --assert(type(getmetatable(self).__index.produce_entry) == "function")
            --assert(type(getmetatable(self).direct.produce_entry(self)) == "function")
            --
            --print(getmetatable(self).direct.produce_entry(self)(entry))
            --
            --assert(type(self) == "table")
            --assert(type(entry) == "table")
            ----table.insert(ret, getmetatable(self).__index.produce_entry(self, entry))
            --table.insert(ret, getmetatable(self).direct.produce_entry(self)(entry))
            ----table.insert(ret, self:produce_entry(entry))
         --end
            --return ret
            return map(list, function(entry) return self:produce_entry(entry) end)
         else
            return list
         end
   end end,

   args_in_order = function(self) return function(entry)
         assert(type(self.values.row_names) == "table")
         return map(self.values.row_names, function(name) return entry[name] end)
   end end,

   -- Stuff that can be used later on.

   -- Time-based IDs.
   new_time_id = function(self) return function(db)
         local time = cur_time_ms()*1000
         if time == self.last_id_time then time = time + 1 end
         -- Search for matching.
         while self.values.time_overkill and
            (self.db or db):exec([[SELECT ? FROM ? WHERE ? == ?]], 
                                 {self.values.idname, self.values.table_name,
                                  self.values.idname, time}) > 0 do
            time = time + 1
         end
         last_time = time
         return time
   end end,
}}

function SqlHelp:produce_entry(data)
   assert(type(data) == "table")
         return setmetatable(data, SqlEntry)
end

return SqlHelp
