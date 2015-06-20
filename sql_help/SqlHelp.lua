--  Copyright (C) 19-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO taggings can be used for similar purposes..
--  Likely good to rename the concept, and have ability to use the concept
--   multiple times, the same way.

local metatable_of = require("o_jasper_common.meta").metatable_of

local SqlEntry = require "sql_help.SqlEntry"
assert(type(SqlEntry) == "table")

local time_interpret = require("o_jasper_common.fromtext.time").time_interpret
local searchlike = require("o_jasper_common.fromtext.searchlike")

local string_split = lousy.util.string.split

-- NOTE Is actually not less LOC...
-- local function formatfun(str, inputfun)
--   return function(...) return string.format(str, inputfun(...)) end
-- end

local matchfun = {
   text_like = function(self, state, m, v)
      self:text_like(v, nil, string.sub(m, 1, 2) == "-")
   end,
   tags = function(self, state, m, v)
      for _, t in pairs(string_split(v, "[,;]")) do table.insert(state.tags, t) end
   end,
   not_tags = function(self, state, m, v)
      for _, t in pairs(string_split(v, "[,;]")) do table.insert(state.not_tags, t) end
   end,
   ["not"] = function(self, state, m, v)
      state.n = state.n or (m == "not:")
      self:text_sw(v, true)
   end,

   search = function(self, state, m, v)
      self:like(string.sub(m, 1, #m - 1), '%' .. v .. '%', state.n)
   end,
   equal = function(self, state, m, v)  -- TODO no negation..
      -- TODO make a just `self:equal` function.
      self:equal_1(string.sub(m, 1, #m - 1), v)
   end,
   like = function(self, state, m, v)
      self:like(string.sub(m, 1, #m-5), v, state.n)
   end,

   order_by = function(self, state, m, v)
      for k in pairs(self.values.int_els) do
         if string.match(k, "^" .. v) then
            state.order_by = k
            return
         end
      end
   end,
}

function matchfun:order_by_desc(state, m, v)
   matchfun.order_by(state, m, v)
   state.order_by_way = "DESC"
end

local SqlHelp = {
   values = {
      textlike = {"title", "uri", "desc"},
      taggings = "taggings", tagname="tag",
      order_by = "id",
      idname = "id", 
      time = "id", timemul = 0.001,
   },
   entry_meta = SqlEntry,
   c = false, tags_last = 0, last_id_time = 0,
   
   searchinfo = {
      matchable = {"like:", "-like:", "tag:", "tags:", "-tag:", "-tags:",
                   "-", "not:", "\\-", "or:",
                   "uri:", "desc:", "title:",
                   "uri=", "desc=", "title=",
                   "urilike:", "desclike:", "titlelike:",
                   "before:", "after:", "limit:"
      },
      match_funs = {
         ["like:"] = matchfun.text_like, ["-like:"] = matchfun.text_like,
         ["lk:"]   = matchfun.text_like, ["-lk:"]   = matchfun.text_like,

         ["tags:"]  = matchfun.tags,     ["tag:"]  = matchfun.tags,
         ["-tags:"] = matchfun.not_tags, ["-tag:"] = matchfun.tags,

         ["not:"] = matchfun["not"], ["-:"] = matchfun["not"],
         ["\\-"] = function(self, state, m, v)  -- Should escape it.
            self:text_sw("-" .. v, state.n)
         end,

         ["or:"] = function(self, state, m, v)  -- NOTE `or:` takes precidence here!!
            self.how = "OR"
            if v then 
               self:text_sw(w, state.n)
            else -- Wait a sec.
               state.reset = true
            end
         end,
         ["uri:"] = matchfun.search,
         ["uri="] = matchfun.equal,
         ["urilike:"] = matchfun.like,

         ["desc:"] = matchfun.search,
         ["desc="] = matchfun.equal,
         ["desclike:"] = matchfun.like,

         ["title:"] = matchfun.search,
         ["title="] = matchfun.equal,
         ["titlelike:"] = matchfun.like,
         
         ["after:"] = function(self, state, m, v)
            local t = time_interpret(v)
            if t then self:after(t) end
         end,
         ["before:"] = function(self, state, m, v)
            local t = time_interpret(v)
            if t then self:before(t) end
         end,
         ["limit:"] = function(self, state, m, v)
            local list = string_split(v, ",")
            -- TODO  collect more nicely.(might be bad user-input)
            assert(#list == 1 or #list == 2)
            assert(not self.got_limit)
            self.got_limit = {}
            for _, el in pairs(list) do
               assert(string.match(el, "[%d]+"))
               table.insert(self.got_limit, tonumber(el))
            end
         end,

         ["order:"]   = matchfun.order_by,
         ["orderby:"] = matchfun.order_by,
         ["sort:"]    = matchfun.order_by,

         ["orderdesc:"]   = matchfun.order_by_desc,
         ["orderbydesc:"] = matchfun.order_by_desc,
         ["sortdesc:"]    = matchfun.order_by_desc,
         
         default = function(self, state, m, v)
            self:text_sw(v, state.n)
         end
      }
   },
   -- Important: gotta be a _new_ one!
   -- Note: use this is you want to "build" a search.
   -- Otherwise the state is hanging around. (you can use it just the same)
   new_SqlHelp = function(self, initial, fun)  -- TODO rename to `copy`
      -- TODO multiple table names? 
      initial = initial or {string.format([[SELECT * FROM %s m]], self.values.table_name)}
      return setmetatable({db=self.db, 
                           input = {}, cmd=initial,
                           first=first or  "WHERE", produce_entry=fun},
                          getmetatable(self))
   end,
   
   exec = function(self, ...) return self:list_fun(self.db:exec(...)) end,
   
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
   
   -- Lots of stuff to build searches from.
   equal_1 = function(self, which, input)
      assert(type(input) == "string")
      self:extcmd("%s == ?", which)
      self:inp(input)
   end,

   equal_list = function(self, which, input)
      assert(type(input) == "table")
      local str = {string.format("%s IN (?", which)}
      for i, f in pairs(input) do
         self:inp(f)
         if i ~= 1 then table.insert(str, "?") end
            end
      self:extcmd(table.concat(str, ", ") .. ")")
   end,
   
   equal = function(self, which, input)
      if type(input) == "table" then
         if #input > 1 then return self:equal_list(which, input) end
         input = input[1]
      end
      return self:equal_1(which, input)
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
      self:lt(self.values.time, time)
   end,
   
   -- Add a like command.
   like = function(self, what, value)
      self:extcmd([[%s LIKE ?]], what)
      self:inp(value)
   end,
   not_like = function(self, value, what)
      self:extcmd([[%s NOT LIKE ?]], what)
      self:inp(value)
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
         self:like(what, search)
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
      --         self.equal("t." .. (tagname or self.values.tagname), tags)
      --         self.addstr(")")
      --         self.first, self.c = fw, cw
      
      self:extcmd([[%sEXISTS (
SELECT * FROM %s
WHERE to_id == m.id]], w or "", taggingsname or self.values.taggings)
      self:comb("AND")
      self:equal(tagname or self.values.tagname, tags)
      self:addstr(")")
   end,
   not_tags = function(self, tags, taggingsname, tagname)
      self:tags(tags, taggingsname, tagname, "NOT ")
   end,
   
   -- The actual search build from it.
   search = function(self, str)
      local tagged_list = searchlike.searchlike(searchlike.portions(str),
                                                self.searchinfo.matchable)
      
      local state = {n=false, tags={}, not_tags={}, before_t=nil, after_t=nil, reset=true}
      local match_funs = self.searchinfo.match_funs

      for i, el in pairs(tagged_list) do
         self:comb()
         local fun = (match_funs[el.m] or match_funs.default)
         fun(self, state, el.m, el.v)

         if state.reset then self.how = "AND" end
      end
      self.how = "AND"
      self:comb()
      self:tags(state.tags)
      self:comb()
      self:not_tags(state.not_tags)
      if before_t then self:comb() self:before(state.before_t) end
      if after_t then self:comb() self:after(state.after_t) end
      if state.order_by then
         self.dont_auto_order = true
         self:order_by(state.order_by, state.order_by_way)
      end
   end,
   
   -- Sorting it.
   order_by = function(self, what, way)
      if type(what) == "table" then what = table.concat(what, ", ") end
      self.c = ""
      self:extcmd("ORDER BY %s %s", what, way or "DESC")
   end,

   auto_order_by = function(self)
      if not self.dont_auto_order and self.values.order_by then
         self:order_by(self.values.order_by, self.values.order_way)
      end
   end,
   
   -- Limiting the number of results.
   limit = function(self, fr, cnt) 
      self.c = ""
      self:extcmd("LIMIT ?, ?")
      self:inp(fr)
      self:inp(cnt)
   end,
   
   finish = function(self)  -- Add requested searches.
      if self.got_limit then
         if #self.got_limit == 2 then
            self:limit(self.got_limit[1], self.got_limit[2])
         else
            self:limit(0, self.got_limit[1])
         end
         self.got_limit = nil
      end
   end,

   -- Patterns with all the questionmarks to be filled with `self.input`.
   sql_pattern = function(self)
      self:finish()
      return table.concat(self.cmd, "\n") 
   end,
   
   -- Manually fill those in. USE THE SQL VERSION.
   -- TODO SQL exposes it?
   sql_code = function(self)
      self:finish()
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
   result = function(self, db) return self:list_fun(self:raw_result(db)) end,
   
   -- Represents the entry as list in the order of the names.
   args_in_order = function(self, entry)
      assert(type(self.values.row_names) == "table")
      local ret = {}
      for _, name in pairs(self.values.row_names) do
         table.insert(ret, entry[name])
      end
      return ret
   end,
   
   -- Adding/removing
   
   -- Remove all results of the search.
   delete_result = function(self, table_name, db)
      db = db or self.db
      local list = self:raw_result(self, db)
      for _, entry in pairs(list) do -- Then delete all of them.
         self:delete_id(entry[self.values.idname])
      end
      return list
   end,
}

local c = require("o_jasper_common")

local This = c.copy_meta(require "sql_help.SqlCmds_w_tags")

for k, v in pairs(SqlHelp) do This[k] = v end

return c.metatable_of(This)
