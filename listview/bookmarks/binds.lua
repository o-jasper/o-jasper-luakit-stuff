local bookmarks  = require "listview.bookmarks.bookmarks"

local config = (globals.listview or {}).bookmarks or {}
local take = config.take or {}
if take.all then take = setmetatable({}, {__index=function(...) return true end}) end

-- Add bindings.
local lousy = require "lousy"
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
