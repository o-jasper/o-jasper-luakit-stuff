--  Copyright (C) 24-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local config = globals.listview_bookmarks or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local entry_html = require "listview.entry_html"

local BookmarksEntry = require "listview.bookmarks.BookmarksEntry"

local SqlHelp = require("sql_help").SqlHelp

local this = c.copy_meta(SqlHelp)
this.values = BookmarksEntry.values

this.cur_id_add = 0
this.entry_meta = BookmarksEntry

function this:config() return config end

return c.metatable_of(this)
