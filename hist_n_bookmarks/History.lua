
local c = require "o_jasper_common"

local SqlHelp = require("sql_help").SqlHelp
local HistoryEntry = require "hist_n_bookmarks/HistoryEntry"

History = c.copy_table(SqlHelp)
History.values = HistoryEntry.values

function History:history_entry(entry)
   entry.origin = self
   return setmetatable(history_entry, HistoryEntry)
end

function History.listfun(self, list)
   print(self.values.table_name)
   for _, data in pairs(list) do
      data.origin = self
      setmetatable(data, HistoryEntry)
   end
   return list
end

return c.metatable_of(History)
