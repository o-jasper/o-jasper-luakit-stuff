
local config = globals.listview_history or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local OldBookmarksEntry = require "listview.history.OldBookmarksEntry"

OldBookmarks = c.copy_meta(require("sql_help").SqlHelp)
OldBookmarks.values = OldBookmarksEntry.values

-- Scratch some search matchabled that arent allowed.
OldBookmarks.searchinfo.matchable = {"-", "not:", "\\-", "or:",
                                     "uri:", "title:",
                                     "urilike:", "titlelike:",
                                     "before:", "after:", "limit:"}

function OldBookmarks:config() return config end

function OldBookmarks:history_entry(entry)
   entry.origin = self
   return setmetatable(entry, OldBookmarksEntry)
end

OldBookmarks.entry_fun = OldBookmarks.history_entry

return c.metatable_of(OldBookmarks)
