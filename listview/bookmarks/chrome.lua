--  Copyright (C) 27-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local paged_chrome = require("paged_chrome")
local listview = require("listview")
local bookmarks  = require "listview.bookmarks.bookmarks"

local config = (globals.listview or {}).more or {}
config.page = config.page or {}

-- Make the chrome page.
local bookmarks_paged = listview.new_Chrome(bookmarks, "listview/more")

paged_chrome.paged_chrome("listviewBookmarks", bookmarks_paged)

if config.take_bookmarks_chrome then  -- Take over the 'plain name'. (default:no)
   paged_chrome.paged_chrome("bookmarks", bookmarks_paged)
end

-- Add bindings.
local cmd = lousy.bind.cmd

local function on_command(w, query)
   bookmarks.latest_query = query
   local v = w:new_tab("luakit://listviewBookmarks/search")
   -- if query then  -- This would be without the nasty "global value" thing.
   --  v:eval_js(string.format("ge('search').value = %q; search();", query))
   -- end
end
add_cmds({ cmd("listviewBookmarks", on_command) })
if config.take_bookmarks_cmd then add_cmds({ cmd("bookmarks", on_command) }) end
