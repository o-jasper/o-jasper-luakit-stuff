local c = require "o_jasper_common"
local sql_help = require "sql_help"

local Public = {}

local function in_list(list, name)
   for i, el in ipairs(list) do
      if el == name then
         return i
      end
   end
end

-- Returns a list of strings to exec that makes a table, or entries nil if not possible.
function Public.db_creator_str_from_values(values)
   if not values.idname then  -- need a name for an id.
      return { no_idname = true }
   end
   local pre = values.pre_table or "CREATE TABLE IF NOT EXISTS"
   local ret = {}
   if values.row_names then
      local list = {}
      for _, name in ipairs(values.row_names) do
         local after = (name == values.idname and "PRIMARY KEY") or "NOT NULL"
         if in_list(values.string_els, name) then
            table.insert(list, string.format("%s TEXT %s", name, after))
         elseif in_list(values.int_els, name) then
            table.insert(list, string.format("%s INTEGER %s", after))
         end
      end
      ret.main = string.format("%s %s (\n%s);\n",
                               pre, values.table_name, table.concat(list, ",\n"))
   else
      ret.main = false
   end

   if values.taggings then
      ret.taggings = string.format("%s %s (\n  to_%s INTEGER NOT NULL,\n  %s TEXT NOT NULL\n);\n",
                                   pre, values.taggings, values.idname, values.tagname)
   else
      ret.taggings = false
   end
   return ret
end

-- Returns un-finalized entry pair, and a string sql can execute to create.
-- Trying it, it seems to make things more complicated sooner than making things simpler.
-- so i dont use it.
function Public.entry_help_whole(modboth, modhelp)
   local entry = c.copy_meta(Public.SqlEntry, modboth)
   local help  = c.copy_meta(Public.SqlHelp, modboth)
   help.entry_meta = entry -- (potentially overridden in subsequent loop)
   for k, v in pairs(modhelp) do help[k] = v end
   return help, entry, Public.db_creator_str_from_values(entry.values)
end

return Public
