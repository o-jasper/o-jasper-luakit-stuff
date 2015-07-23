
local c = require "o_jasper_common"
local ToxContactsEntry = require "listox.tox_contacts.ToxContactsEntry"

local This = c.copy_meta(require("sql_help").SqlHelp)

This.values = ToxContactsEntry.values

-- Scratch some search matchabled that arent allowed.
-- TOOD re-add.
This.searchinfo.matchable = {"like:", "-like:", "-", "not:", "\\-", "or:", "limit:"}

local config = (globals.listox or {}).tox_contacts or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

function This:config() return config end  -- TODO it never uses config..?

This.entry_meta = ToxContactsEntry

return c.metatable_of(This)
