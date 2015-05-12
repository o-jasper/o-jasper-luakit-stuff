
local config = globals.listview_history or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local HistoryEntry = require "listview.history.HistoryEntry"

History = c.copy_meta(require("sql_help").SqlHelp)
History.values = HistoryEntry.values

-- Scratch some search matchabled that arent allowed.
History.searchinfo.matchable = {"like:", "-like:", "-", "not:", "\\-", "or:",
                                "uri:", "title:",
                                "urilike:", "titlelike:",
                                "before:", "after:", "limit:"}

function History:config() return config end

function History:history_entry(entry)
   entry.origin = self
   return setmetatable(entry, HistoryEntry)
end

History.entry_fun = History.history_entry

return c.metatable_of(History)
