--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require "o_jasper_common"

local listview = require("listview")
local old_bookmarks  = require "listview.oldBookmarks.old_bookmarks"

local chrome_reg = require "paged_chrome.reg"

local config = (globals.listview or {}).old_bookmarks or {}
config.page = config.page or {}

local where = config.assets or {}
table.insert(where, "*listview/oldBookmarks")

local search = setmetatable({name = "search", log=old_bookmarks, where=where},
   require "listview.oldBookmarks.OldBookmarksSearch")

local pages = {
   default_name = default_name or "search",
   search = search,
   aboutChrome = listview.AboutChrome.new{"aboutChrome", old_bookmarks, where},
}
pages.search.limit_cnt = config.page.cnt or 20
pages.search.limit_step = config.page.step or pages.search.step_cnt

return {{
   chrome_name = "listviewOldBookmarks",
   pages = pages,
}}
