
local config = globals.listview_dir or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local DirEntry = require "dirChrome.DirEntry"
local SqlHelp = require("sql_help").SqlHelp
local Dir = c.copy_meta(SqlHelp)

Dir.values = DirEntry.values

-- Scratch some search matchabled that arent allowed.
Dir.searchinfo.matchable = {"like:", "-like:", "-", "not:", "\\-", "or:",
                            "mode:", "dir:", "file:", "dirlike:", "filelike:",
                            "sizelt:", "sizegt:",
                            "before:", "after:",
                            "access_before:", "access_after:",
                            "limit:"}
-- TODO implement the searches.

function Dir:config() return config end
function Dir:initial_state() return {} end

Dir.entry_meta = DirEntry

Dir.cmd_dict.has_path = "SELECT id FROM files WHERE dirname == ? AND filename == ?"

function Dir:update_or_enter(entry)
   local exist = self:sqlcmd("has_path"):exec({entry.dirname, entry.filename})
   if #exist > 0 then
      if #exist ~= 1 then print("DirChrome: More than one of the same file?!") end
      entry.id = exist[1].id
      return self:update(entry)
   else
      return SqlHelp.update_or_enter(self, entry)
   end
end

return c.metatable_of(Dir)
