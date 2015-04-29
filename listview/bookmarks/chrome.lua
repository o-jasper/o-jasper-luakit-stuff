--  Copyright (C) 27-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require("o_jasper_common")

local paged_chrome = require "paged_chrome"
local listview = require "listview"
local bookmarks  = require "listview.bookmarks.bookmarks"

local config = (globals.listview or {}).more or {}
config.page = config.page or {}

-- Make the chrome page.
local bookmarks_paged = listview.new_Chrome(bookmarks, "listview/bookmarks")

local mod_Enter = {
   to_js = {
      manual_enter = function(self)  -- This one go onto the bindings for.
         return function(inp)
            add = {
               created=c.cur_time.s(),
               to_uri = inp.uri,
               title = inp.title,
               desc = inp.desc,
               data_uri = inp.data_uri,  -- Empty strings are can be auto-reinterpreted.
               
               tags = lousy.util.string.split(inp.tags, "[,; ]+") --(these are not done directly)
            }
            local ret = self.log:enter(add)
            for k,v in pairs(ret) do print(k,v) end
         end
      end,

      -- TODO show that the default data_uri would be.
   },
   repl_list = function(self, view, meta)
      -- TODO
      return { title = "Add bookmark",
               common_js = self:asset("common", ".js"),
               bookmarks_js = self:asset("bookmarks", ".js"),
               part_enter = self:asset("parts/enter"),
      }
   end,
}

local Enter = c.metatable_of(c.copy_meta(listview.Base, mod_Enter))

local enter_page = setmetatable({where="listview/bookmarks", log=bookmarks},
                          Enter)
bookmarks_paged.enter = paged_chrome.templated_page(enter_page)

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
