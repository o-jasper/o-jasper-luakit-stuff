--  Copyright (C) 11-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local lousy = require "lousy"

local c = require "o_jasper_common"

local listview = require "listview"
local bookmarks  = require "listview.bookmarks.bookmarks"

local config = (globals.listview or {}).bookmarks or {}

-- Make the chrome page.
local Enter = require "listview.bookmarks.Enter"
local BookmarksSearch = require "listview.bookmarks.BookmarksSearch"

local function mk_page(meta, name)
   return meta.new{name, bookmarks, "*listview/bookmarks"}
end
 
local bookmarks_pages = {
   default_name = "search",
   enter  = mk_page(Enter, "enter"),
   import  = mk_page(require "listview.bookmarks.import_page", "import"),
   search = mk_page(BookmarksSearch, "search"),
   aboutChrome = mk_page(listview.AboutChrome, "aboutChrome"),
}

local Public = {
   listviewBookmarks = {
      chrome_name = "listviewBookmarks",
      pages = bookmarks_pages,
   },
}

local take = config.take or {}
if take.all then take = setmetatable({}, {__index=function(...) return true end}) end

if take.bookmarks_chrome then  -- Take over the 'plain name'. (default:no)
   Public.bookmarks = {
      chrome_name = "bookmarks",
      pages = bookmarks_pages,
   }
end

-- Add bindings.
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function cmd_bookmarks(w, query)
   bookmarks.cmd_query = query  -- bit "global-value-ie"
   local v = w:new_tab("luakit://listviewBookmarks/search")
end
add_cmds({ cmd("listviewBookmarks", cmd_bookmarks) })
if take.bookmarks_cmd then add_cmds({ cmd("bookmarks", cmd_bookmarks) }) end


local function cmd_bookmark_new(w, desc)
   bookmarks.cmd_add = {uri = w.view.uri, title = w.view.title, desc=desc or ""}
   w:new_tab(config.add_bookmark_page or "luakit://listviewBookmarks/search")
end
add_cmds({ cmd("listviewBookmark_new", cmd_bookmark_new) })
if take.bookmark_cmd then add_cmds({ cmd("bookmark_new", cmd_bookmark_new) }) end

-- Add keybindings.
if take.binds then
   add_binds("normal", 
             { buf("^gb",   function(w) cmd_bookmark_new(w) end),
               key({}, "B", function(w) cmd_bookmark_new(w) end), })
end

return Public
