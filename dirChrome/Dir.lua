
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

Dir.cmd_dict.select_path = "SELECT id FROM {%table_name} WHERE dirname == ? AND filename == ?"
Dir.cmd_dict.delete_path = "DELETE FROM {%table_name} WHERE dirname == ? AND filename == ?"

local cur_time = require "o_jasper_common.cur_time"

function Dir:update_or_enter(entry)
   -- Delete pre-existing.
   self:sqlcmd("delete_path"):exec({entry.dirname, entry.filename})
   assert(not entry.id) -- Re enter.,
   return SqlHelp.update_or_enter(self, entry)
end

return c.metatable_of(Dir)
