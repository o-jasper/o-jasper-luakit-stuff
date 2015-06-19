--  Copyright (C) 19-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require "o_jasper_common"

local SqlCmds = require "sql_help.SqlCmds"
local This = c.copy_meta(SqlCmds)

local function qmarks(n)  -- Makes a string with a number of question marks in it.
   if n == 0 then return "" end
   local str = "?"
   while n > 1 do
      str = str .. ", ?"
      n = n - 1
   end
   return str
end

local mod_cmd_dict = {
   -- Tag stuff, less likely to apply for the user, but here anyway.
   just_tags = "SELECT tag FROM {%taggings} WHERE to_id == ?",
   has_tag   = "SELECT tag FROM {%taggings} WHERE to_id == ? AND {%tagname} == ?",
   
   tags_insert     = "INSERT INTO {%taggings} VALUES (?, ?);",
   delete_tags_id  = "DELETE FROM {%taggings} WHERE to_{%idname} == ?",
}
for k,v in pairs(mod_cmd_dict) do This.cmd_dict[k] = v end

function This:enter(entry)
   local ret = SqlCmds.enter(self, entry)
   -- And all the tags, if we do those.
   if entry.tags and #entry.tags > 0 and self.values.taggings then
      self.tags_last = cur_time.raw()  -- Note time last changed.
      local tags_insert = self:sqlcmd("tags_insert")
      ret.tags = {}
      for _, tag in pairs(entry.tags) do
         table.insert(ret.tags, tags_insert:exec({entry[self.values.idname], tag}))
      end
   end
   return ret
end

function This:delete_id(id)
   SqlCmds.delete_id(id)
   if self.values.taggings then
      self:sqlcmd("delete_tags_id"):exec({id})
   end
end

This.just_tags = SqlCmds.classhelp.sqlcmd.to_method_list_col("just_tags", "tag")
This.has_tag   = SqlCmds.classhelp.sqlcmd.to_method("has_tag")

return c.metatable_of(This)
