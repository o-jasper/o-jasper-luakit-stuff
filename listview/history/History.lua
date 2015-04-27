
local c = require "o_jasper_common"
local HistoryEntry = require "listview.history.HistoryEntry"

History = c.copy_meta(require("sql_help").SqlHelp)
History.values = HistoryEntry.values

-- Scratch some search matchabled that arent allowed.
History.searchinfo.matchable = {"like:", "-like:", "-", "not:", "\\-", "or:",
                                "uri:", "title:",
                                "urilike:", "titlelike:",
                                "before:", "after:", "limit:"}

function History:history_entry(entry)
   entry.origin = self
   return setmetatable(entry, HistoryEntry)
end

function History.listfun(self, list)
   for _, data in pairs(list) do
      data.origin = self
      setmetatable(data, HistoryEntry)
   end
   return list
end

return c.metatable_of(History)
