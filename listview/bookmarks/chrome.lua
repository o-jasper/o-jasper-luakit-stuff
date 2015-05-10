--  Copyright (C) 01-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local lousy = require "lousy"

local c = require("o_jasper_common")

local paged_chrome = require "paged_chrome"
local listview = require "listview"
local bookmarks  = require "listview.bookmarks.bookmarks"

local config = (globals.listview or {}).more or {}
config.page = config.page or {}

-- Make the chrome page.

local topicsdir = config.topicsdir or ((os.getenv("HOME") or "TODO") .. "/topics")   -- TODO
local topics    = config.topics or {"entity", "idea", "project", "data_source",
                                    "vacancy"}

local function default_data_uri_fun(entry)
   for _,name in pairs(topics) do
      if bookmarks:has_tag(entry.id, name) then
         -- TODO file-appropriatize the title.
         local dir = string.format("%s/%s/%s", topicsdir, name, entry.title)
         return dir
      end
   end
end

local default_data_uri = config.default_data_uri or default_data_uri_fun

local function plus_cmd_add(ret, log)
   local cmd_add = log.cmd_add or {}
   for _,k in pairs({"uri", "title", "desc"}) do  -- Ill conceived but harmless.
      ret["cmd_add_" .. k] = cmd_add[k] or ""
   end
   ret.cmd_add_gui = log.cmd_add and "true" or "false"
   log.cmd_add = nil
end

local mod_Enter = {
   to_js = {
      manual_enter = function(self)
         return function(inp)
            if not inp.data_uri or inp.data_uri == "" then
               inp.data_uri = default_data_uri_fun(self)
            end
            add = {
               created=c.cur_time.s(),
               to_uri = inp.uri,
               title = inp.title,
               desc = inp.desc,
               data_uri = inp.data_uri,  -- Empty strings are can be auto-reinterpreted.
               --(these are not done directly)
               tags = lousy.util.string.split(inp.tags, "[,; ]+")
            }
            local ret = self.log:enter(add)
            for k,v in pairs(ret) do print(k,v) end
         end
      end,

      -- TODO show what the default data_uri would be.
   },
   repl_list = function(self, args, _,_)
      local ret = { title = "Add bookmark", }
      plus_cmd_add(ret, self.log)
      return ret
   end,
}
local Enter = c.metatable_of(c.copy_meta(listview.Base, mod_Enter))

local mod_BookmarksSearch = {
   -- Want the adding-entries js api too.
   to_js = c.copy_table(listview.Search.to_js, mod_Enter.to_js),
   
   repl_list = function(self, args, view, meta)
      local got = listview.Search.repl_list(self, args, view, meta)
      got.above_title = self:asset("parts/enter_span")
      got.right_of_title = [[&nbsp;&nbsp;
<button id="toggle_add_gui" style="width:13em;"onclick="set_add_gui(!add_gui)">BUG</button><br>
]]
      got.after = [[<script type="text/javascript">{%bookmarks.js}</script>]]

      plus_cmd_add(got, self.log)
      return got
   end,
}

local BookmarksSearch = c.metatable_of(c.copy_meta(listview.Search, mod_BookmarksSearch))

assert(mod_BookmarksSearch.to_js.manual_enter)

local function mk_page(meta, name)
   local page = setmetatable({where="listview/bookmarks", log=bookmarks}, meta)
   return paged_chrome.templated_page(page, name)
end

local bookmarks_paged = {
   default_name = "search",
   enter  = mk_page(Enter, "enter"),
   search = mk_page(BookmarksSearch, "search"),
   aboutChrome = listview.new_AboutChrome("listview/bookmarks", bookmarks),
}

paged_chrome.paged_chrome("listviewBookmarks", bookmarks_paged)

local take = config.take or {}

if take.bookmarks_chrome then  -- Take over the 'plain name'. (default:no)
   paged_chrome.paged_chrome("bookmarks", bookmarks_paged)
end

-- Add bindings.
local cmd = lousy.bind.cmd

local function cmd_bookmarks(w, query)
   bookmarks.cmd_query = query  -- bit "global-value-ie"
   local v = w:new_tab("luakit://listviewBookmarks/search")
end
add_cmds({ cmd("listviewBookmarks", cmd_bookmarks) })
if take.bookmarks_cmd then add_cmds({ cmd("bookmarks", cmd_bookmarks) }) end


local function cmd_bookmark_new(w, desc)
   bookmarks.cmd_add = {uri = w.view.uri, title = w.view.title, desc=desc}
   local v = w:new_tab(config.add_bookmark_page or "luakit://listviewBookmarks/search")
end
add_cmds({ cmd("listviewBookmark_new", cmd_bookmark_new) })
if take.bookmark_cmd then add_cmds({ cmd("bookmark_new", cmd_bookmark_new) }) end
