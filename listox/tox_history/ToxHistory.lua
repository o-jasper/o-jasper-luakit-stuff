
local c = require "o_jasper_common"
local ToxHistoryEntry = require "listox.tox_history.ToxHistoryEntry"

local This = c.copy_meta(require("sql_help").SqlHelp)

This.values = ToxHistoryEntry.values

-- Scratch some search matchabled that arent allowed.
-- TODO re-add.
This.searchinfo.matchable = {"like:", "-like:", "-", "not:", "\\-", "or:", "limit:",
                             "after:", "before:",
                             "order:", "orderby:", "sort:"}

local config = (globals.listox or {}).tox_history or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

function This:config() return config end
This.entry_meta = ToxHistoryEntry

return c.metatable_of(This)
