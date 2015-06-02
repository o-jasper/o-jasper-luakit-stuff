--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require "o_jasper_common"

local listview = require("listview")
local old_bookmarks  = require "listview.oldBookmarks.old_bookmarks"

local paged_chrome = require("paged_chrome")

local config = (globals.listview or {}).old_bookmarks or {}
config.page = config.page or {}

local mod_OldBookmarksSearch = {
   repl_list = function(self, args)
      local ret = listview.Search.repl_list(self, args)
      ret.above_title = [[<br><span class="warn">This is just thrown together quickly,
the other bookmarks is the "serious" one.</span>]]
      return ret
   end,
}
local OldBookmarksSearch = c.metatable_of(c.copy_meta(listview.Search, mod_OldBookmarksSearch))

local function chrome_describe(log)
   assert(log)
   
   local where = config.assets or {}
   table.insert(where, "listview/oldBookmarks")

   local search = setmetatable({log=log, where=where}, OldBookmarksSearch)

   local pages = {
      default_name = default_name or "search",
      search = paged_chrome.templated_page(search, "search"),
      aboutChrome = paged_chrome.templated_page(
         listview.AboutChrome.new{log, where},
         "aboutChrome"),
   }
   pages.search.limit_cnt = config.page.cnt or 20
   pages.search.limit_step = config.page.step or pages.search.step_cnt
   return pages
end

-- Make the chrome page.
local paged = chrome_describe(old_bookmarks)
assert(paged.search.page.log.initial_state)
paged_chrome.paged_chrome("listviewOldBookmarks", paged)
