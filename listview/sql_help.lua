--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "listview.common"

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
   print(string.sub(str, i, j), from_t, i, j)

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

local sql_help_meta = metatable_for({
determine = {},
direct = {
   extcmd = function(self) return function(str, ...)
         if self.c then
            str = self.c .. " " .. str
            self.c = false
         end
         self.first = false
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
         self.gt(self.config.time or "id", time)
   end end,
   before = function(self) return function(time)
         self.gt(self.config.time or "id", time)
   end end,

   like = function(self) return function(value, what, n)
         self.extcmd([[%s LIKE ?]], n and what .." NOT" or what)
         self.inp(value)
   end end,
   not_like = function(self) return function(value, what)
         self.like(value, what, true)
   end end,

   text_like = function(self) return function(search, n)
         if self.first then self.first = self.first .. "(" end
         for i, what in pairs(self.config.textlike or {"title", "uri", "desc"}) do
            self.comb((i == 1 and self.c .. "(") or "OR")
            self.like(search, n and what .. " NOT" or what)
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

   tags = function (self) return function(tags, w)
         if #tags == 0 then return end
         self.extcmd([[%sEXISTS (
SELECT * FROM %s
WHERE to_id == m.id]], w or "", self.config.taggings or "taggings")
         self.comb("AND")
         self.equal_one_or_list("tag", tags)
         self.addstr(")")
   end end,
   not_tags = function(self) return function(tags)
         self.tags(tags, "NOT ")
   end end,

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
            elseif m == "tags:" then
               for _, t in pairs(string_split(v, "[,;]")) do table.insert(tags, t) end
            elseif m == "-tags:" then
               for _, t in pairs(string_split(v, "[,;]")) do table.insert(not_tags, t) end
            elseif m == "not: " or m == "-" then
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
         self.c = ""
         self.extcmd("ORDER BY %s %s", what, way or "DESC")
   end end,
      
   sql_pattern = function(self) return function()
         return table.concat(self.cmd, "\n") 
   end end,
   
   -- Note: not what is used for the actual query.
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

}})

function new_sql_help(how, initial, db, fun, config)
   if type(initial) == "table" then -- Is a list of stuff we want.
      initial = string.format("SELECT %s FROM msgs m", table.concat(initial, ", "))
   end
   local helper = {db = db, fun = fun, first=first or  "WHERE", c = false,
                   cmd = {initial or [[SELECT * FROM msgs m]]},
                   input = {},
                   how = how or "AND", config = config or {}}
   setmetatable(helper, sql_help_meta.table)
   return helper
end
