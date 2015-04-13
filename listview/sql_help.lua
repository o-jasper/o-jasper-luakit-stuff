--  Copyright (C) 14-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO taggings can be used for similar purposes..
--  Likely good to rename the concept, and have ability to use the concept
--   multiple times, the same way.

require "o_jasper_common"

local string_split = lousy.util.string.split

local function time_interpret(str, from_t)
   local i, j = string.find(str, "[%-]?[%d]+[.]?[%d]*")
   if j == 0 then
      i, j = string.find(str, "[%-]?[%d]*[.]?[%d]+")
   end
   if not i or i > 2 then return nil end
   if i == 2 then
      if string.sub(str, 1, 1) == "a" then from_t = 0 else return nil end
   end

   -- TODO next to time-differences could also do 'day before'
   local num = tonumber(string.sub(str, i or 1, j ~= 0 and j or #str))
   if j == #str then return 1000*((from_t or cur_time_ms()) + 1000*num) end

   local min = 60000
   local h = 60*min
   local d = 24*h
   local f = ({ms=1, s=1000, ks=1000000, min=min, h=h, d=d, D=d,
               week=7*d, wk=7*d, w=7*d, M=31*d, Y=365.25*d})[string.sub(str, j + 1)]
   
   return f and 1000*((from_t or cur_time_ms()) + num*f)
end

-- Splits things up by whitespace and quotes.
local function portions(str)
   local list = {}
   for i, el in pairs(string_split(str, "\"")) do
      if i%2 == 1 then
         for _, sel in pairs(string_split(el, " ")) do table.insert(list, sel) end
      else
         table.insert(list, el)
      end
   end
   return list
end

-- Finds commands in the search (TODO name is confusing)
function tagged(portions, matchable)
   local ret, dibs = {}, false
   for _, el in pairs(portions) do
      local done = false
      for _, m in pairs(matchable) do
         if string.sub(el, 1, #m) == m then -- Match.
            if #el == #m then
               dibs = m  -- All of them, keep.
               done = true
               break
            else
               table.insert(ret, {m=m, v=string.sub(el, #m + 1)})
               done = true
               break
            end
         end
      end
      if not done then
         if dibs then -- Previous matched, get it.
            table.insert(ret, {m=m, v=el})
            dibs = nil
         else 
            table.insert(ret, {v=el})
         end
      end
   end
   return ret
end

function qmarks(n)
   if n == 0 then return "" end
   local str = "?"
   while n > 1 do
      str = str .. ", ?"
      n = n - 1
   end
   return str
end

sql_help_meta = {
values = {
      textlike = {"title", "uri", "desc"},
      taggings = "taggings", tagname="tag",
      order_by = "id",
      idname = "id", 
      time = "id", timemul = 0.001,
},
determine = { input = function(self) return {} end,
              c = function(self) return false end,
              tags_last = function(self) return 0 end,
              --(note: this thing itself doesnt generate id's for you, but provides plumbing)
              last_id_time = function(self) return 0 end,
            },
direct = {
   -- Note: use this is you want to "build" a search.
   -- Otherwise the state is hanging around. (you can use it just the same)
   new_sql_help = function(self) return function(initial, fun)
         initial = initial or string.format([[SELECT * FROM %s m]], self.values.table_name)
         return setmetatable({db = self.db, cmd={initial},
                              first=first or  "WHERE", fun=fun},
                             getmetatable(self))
   end end,

   -- Enter a message.
   db_enter = function(self) return function(add)
         assert(self.values.table_name and self.values.row_names)
         
         local ret = {}
         if add.keep then  -- Only bother getting it if it is keepworthy.
            local sql = string.format("INSERT INTO %s VALUES (%s)",
                                      self.values.table_name, qmarks(#self.values.row_names))
            ret.add = self.db:exec(sql, self.args_in_order(add))
            -- And all the tags, if we do those.
            if add.tags and #add.tags > 0 and self.values.taggings then
               self.tags_last = cur_time()  -- Note time last changed.
               local tags_insert = string.format([[INSERT INTO %s VALUES (?, ?);]],
                                                 self.value.taggings)
               ret.tags = {}
               for _, tag in pairs(add.tags) do
                  table.insert(ret.tags, self.db:exec(tags_insert, {add.id, tag}))
               end
            end
         end
         return ret
   end end,

   db_delete = function(self) return function (id)
         local cmd = string.format([[DELETE FROM ? WHERE %s == ?;
DELETE FROM ? WHERE to_%s == ?;]],
                                   self.values.idname, self.values.idname)
         return self.db:exec(cmd, self.values.table_name, id, self.values.taggings, id)
   end end,
   
   db_update = function(self) return function(msg)
         local sql = string.format("UPDATE %s SET\n", self.values.table_name)
         for i, name in pairs(self.values.row_names) do
            if i ~= 0 then 
               sql = sql .. name
               if i ~= #self.values.row_names then
                  sql = sql .. "=?,\n"
               else
                  sql = sql .. "=?\n"
               end
            end
         end
         local args = self.args_in_order(add)
         table.insert(args, args[1])
         table.remove(args)
         sql = sql .. string.format("WHERE %s = ?", self.values.idname)
         local ret = {
            change  = self.db:exec(sql, args),
            -- Delete old ones, enter new ones.
            deltags = self.db:exec(string.format("DELETE FROM ? WHERE to_%s == ?", idname))
         }
         for _, tag in pairs(msg.tags) do
            table.insert(ret.tags, self.db:exec("INSERT INTO ? VALUES (?, ?)",
                                                self.values.taggings, msg.id, tag))
         end
         -- TODO tags?
         return ret
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

   inp = function(self) return function(what)
         if type(what) == "table" then
            for k,v in pairs(what) do print(k, v) end
         elseif type(what) == "number" then
            what = tostring(what)
         end
         assert(type(what) == "string",
                string.format("E(BUG): Not a string %s", what))
         table.insert(self.input, what)
   end end,
   
   addstr = function(self) return function(str, ...)
         self.cmd[#self.cmd] = self.cmd[#self.cmd] .. string.format(str, ...)
   end end,

   comb = function(self) return function(how, down)
         self.c = self.first or how or self.how
   end end,

   -- Lots of stuff to build searches from.
   equal_one_or_list = function (self) return function(which, input)
         if type(input) == "table" then
            if #input > 1 then
               local str = {string.format("%s IN (?", which)}
               for i, f in pairs(input) do
                  self.inp(f)
                  if i ~= 1 then table.insert(str, "?") end
               end
               self.extcmd(table.concat(str, ", ") .. ")")
               return
            end
            input = input[1]
         end
         assert(type(input) == "string")
         self.extcmd("%s == ?", which)
         self.inp(input)
   end end,

   lt  = function (self) return function(which, value)  -- TODO
         self.extcmd([[%s < ?]], which)
         self.inp(value)
   end end,
   gt  = function (self) return function(which, value)  -- TODO
         self.extcmd([[%s > ?]], which)
         self.inp(value)
   end end,

   after = function(self) return function(time)
         self.gt(self.values.time, time)
   end end,
   before = function(self) return function(time)
         self.gt(self.values.time, time)
   end end,

   like = function(self) return function(value, what, n)
         self.extcmd([[%s LIKE ?]], n and what .." NOT" or what)
         self.inp(value)
   end end,
   not_like = function(self) return function(value, what)
         self.like(value, what, true)
   end end,

   text_like = function(self) return function(search, n)
         if self.first then 
            if n then
               self.first = self.first .. "NOT ("
            else
               self.first = self.first .. "(" 
            end
         end
         for i, what in pairs(self.values.textlike) do
            self.comb((i == 1 and self.c .. ((n and " NOT(") or "(")) or "OR")
            self.like(search, what)
         end
         self.addstr(")")
   end end,

   text_sw = function(self) return function(search, n)
         if #search > 0 then
            self.text_like('%' .. search .. '%', n)
         end
   end end,
   like_sw = function(self) return function(search, what, n)
         if search > 0 then
            self.like('%' .. search .. '%', what, n)
         end
   end end,

   tags = function (self) return function(tags, taggingsname, tagname, w)
         if #tags == 0 then return end
--         self.addstr("\nJOIN %s t ON t.to_id == m.id AND %s (",
--                     taggingsname or self.values.taggings, w or "")
--         local fw, cw = self.first, self.c
--         self.first = false
--         self.c = ""
--         self.equal_one_or_list("t." .. (tagname or self.values.tagname), tags)
--         self.addstr(")")
--         self.first, self.c = fw, cw

         self.extcmd([[%sEXISTS (
SELECT * FROM %s
WHERE to_id == m.id]], w or "", self.values.taggings)
         self.comb("AND")
         self.equal_one_or_list(tagname or self.values.tagname, tags)
         self.addstr(")")
   end end,
   not_tags = function(self) return function(tags, taggingsname, tagname)
         self.tags(tags, taggingsname, tagname, "NOT ")
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
         local tagged_list = tagged(portions(str), matchable)

         local n, tags, not_tags, before_t, after_t = false, {}, {}, nil, nil
         for i, el in pairs(tagged_list) do
            local m, v = el.m, el.v
            self.comb()
            local reset = true
            if m == "-like:" or m == "-lk:" or m == "like:" or m == "lk:" then
               self.text_like(v, try, string.sub(m, 1, 2) == "-")
            elseif m == "tags:" or m == "tag:" then
               for _, t in pairs(string_split(v, "[,;]")) do table.insert(tags, t) end
            elseif m == "-tags:" or m == "-tag:" then
               for _, t in pairs(string_split(v, "[,;]")) do table.insert(not_tags, t) end
            elseif m == "not:" or m == "-" then
               n = n or (m == "not:")
               self.text_sw(v, true)
            elseif m == "\\-" then
               self.text_sw("-" .. v, n)
            elseif m == "or:" then  -- NOTE `or:` takes precidence here!!
               self.how = "OR"
               if v then 
                  self.text_sw(w, n)
               else -- Wait a sec.
                  reset = true
               end
            elseif m == "uri:" or m == "desc:" or m == "title:" then
               self.like_sw(v, string.sub(m, 1, #m - 1), n)
            elseif m == "urilike:" or m == "desclike:" or m == "titlelike:" then
               self.like(v, string.sub(m, 1, #m-5), n)
            elseif m == "after:" and time_interpret(v) then
               after_t = math.max(after_t or 0, time_interpret(v))
            elseif m == "before:" and time_interpret(v) then
               if before_t then
                  before_t = math.min(before_t, time_interpret(v))
               else
                  before_t = time_interpret(v)
               end
            else
               self.text_sw(v, n)
            end
            if reset then self.how = "AND" end
         end
         self.how = "AND"
         self.comb()
         self.tags(tags)
         self.comb()
         self.not_tags(not_tags)
         if before_t then self.comb() self.before(before_t) end
         if after_t then self.comb() self.after(after_t) end
   end end,

   order_by = function(self) return function(what, way)
         if type(what) == "table" then what = table.concat(what, ", ") end
         assert(what)
         self.c = ""
         self.extcmd("ORDER BY %s %s", what, way or "DESC")
   end end,
   
   row_range = function(self) return function(fr, cnt) 
         self.c = ""
         self.extcmd("LIMIT ?, ?")
         self.inp(fr)
         self.inp(cnt)
   end end,

   sql_pattern = function(self) return function()
         return table.concat(self.cmd, "\n") 
   end end,
   
   -- Note: not what is used for the actual query.
   -- TODO.. if it is a string at all, add the quotes? When quotes?
   sql_code = function(self) return function()
         local pat = string_split(self.sql_pattern(), "?")
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

   args_in_order = function(self) return function(entry)
         return map(self.values.row_names, function(name) return entry[name] end)
   end end,

   -- Stuff that can be used later on.

   -- Time-based IDs.
   new_time_id = function(self) return function()
         local time = cur_time_ms()*1000
         if time == self.last_id_time then time = time + 1 end
         -- Search for matching.
         while self.values.time_overkill and
               #db:exec([[SELECT id FROM ? WHERE id == ?]], 
                        {self.values.table_name, time}) > 0 do
            time = time + 1
         end
         last_time = time
         return time
   end end,
}}
