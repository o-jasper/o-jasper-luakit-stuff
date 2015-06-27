
local config = globals.listview_cookies or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local CookiesEntry = require "listview.cookies.CookiesEntry"

local This = c.copy_meta(require("sql_help").SqlHelp)

This.values = CookiesEntry.values

-- Scratch some search matchabled that arent allowed.
This.searchinfo.matchable = {"like:", "-like:", "-", "not:", "\\-", "or:",
                             "before:", "after:", "limit:"}
-- TODO more complete the search options.

function This:config() return config end
This.entry_meta = CookiesEntry

return c.metatable_of(This)
