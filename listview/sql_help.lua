--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "listview.common"

local string_split = lousy.util.string.split

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
         if self.first and self.first == "boolean" then self.first = "WHERE" end
         table.insert(self.cmd, string.format((self.first or "") .. str, ...))
         self.first = false
   end end,

   incorporate = function(self) return function(subhelp)
         for _, c in pairs(subhelp.cmd)   do table.insert(self.cmd,   c) end
         for _, i in pairs(subhelp.input) do table.insert(self.input, i) end
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

   -- TODO just higher-then and lower-then instead of this.
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
   tags = function (self) return function(tags, w)
         if #tags == 0 then return end
         local h = sql_compose(self.first or self.how, true, string.format([[%sEXISTS (
SELECT * FROM taggings]], w or ""))
         h.extcmd([[to_id == m.id)]])
         h.equal_one_or_list("tag", tags)
         
         self.incorporate(h)
   end end,
   not_tags = function(self) return function(tags)
         self.tags(tags, "NOT ")
   end end,

   like = function(self) return function(value, what, n)
         self.extcmd([[%s LIKE ?]], n and what .." NOT" or what)
         table.insert(self.input, value)
   end end,
   not_like = function(self) return function(value, what)
         self.like(value, what, true)
   end end,

   text_like = function(self) return function(search, n)
         local h = sql_compose("OR", (self.first or self.how))
         for _, what in pairs({"title", "uri", "desc"}) do
            h.like(search, n and what .. " NOT" or what)
         end
         table.insert(h.cmd, "(")
         self.incorporate(h)
         self.first = false
   end end,

   text_sw = function(self) return function(search, n)
         return self.text_like('%' .. search .. '%', n)
   end end,
   like_sw = function(self) return function(search, what, n)
         return self.like('%' .. search .. '%', what, n)
   end end,

   search = function(self) return function(str)
         local matchable = {"like:", "-like:", "tags:", "-tags", "-", "not:", "\\-", "or:",
                            "uri:", "desc:", "title:",
                            "urilike:", "desclike:", "titlelike:"}
         local tagged_list = tagged(portions(str), matchable)

         local n, tags, not_tags = false, {}, {}
         local h = sql_compose("AND", self.first)
         for i, el in pairs(tagged_list) do
            local m, v = el.m, el.v
            print(m, v)
            local reset = true
            if m == "-like:" or m == "-lk:" or m == "like:" or m == "lk:" then
               h.text_like(v, try, string.sub(m, 1, 2) == "-")
            elseif m == "tags:" then
               for _, t in pairs(string_split(v, "[,;]")) do table.insert(tags, t) end
            elseif m == "-tags:" then
               for _, t in pairs(string_split(v, "[,;]")) do table.insert(not_tags, t) end
            elseif m == "not: " or m == "-" then
               n = n or (m == "not:")
               h.text_sw(v, true)
            elseif m == "\\-" then
               h.text_sw("-" .. v, n)
            elseif m == "or:" then  -- NOTE `or:` takes precidence here!!
               h.how = "OR"
               if v then 
                  h.text_sw(w, n) 
               else -- Wait a sec.
                  reset = true
               end
            elseif m == "uri:" or m == "desc:" or m == "title:" then
               h.like_sw(v, string.sub(m, 1, #m - 1), n)
            elseif m == "urilike:" or m == "desclike:" or m == "titlelike:" then
               h.like(v, string.sub(m, 1, #m-5), n)
            --elseif m == "after:" then
            --elseif m == "before:" then
            else
               h.text_sw(v, n)
            end
            if reset then h.how = "AND" end
         end
         h.how = "AND"
         h.tags(tags)
         h.not_tags(not_tags)
         
         -- TODO for .. tags
         self.incorporate(h)
         self.first = false
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

   order_by = function(self) return function(what, way)
         if type(what) == "table" then what = table.concat(what, ", ") end
         table.insert(self.cmd, 
                      string.format("ORDER BY %s %s", what, way or "DESC"))
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

function sql_compose(how, first, initial)  -- Less involved a bit.
   if first == nil then first = true end
   local helper = {cmd = initial and {initial} or {}, first=first,
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
