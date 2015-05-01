--  Copyright (C) 30-04-2015 Jasper den Ouden.
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
      if entry:has_tag(name) then
         -- TODO file-appropriatize the title.
         local dir = string.format("%s/%s/%s", topicsdir, name, entry.title)
         return dir
      end
   end
end

local default_data_uri = config.default_data_uri or default_data_uri_fun

local mod_Enter = {
   to_js = {
      manual_enter = function(self)  -- This one go onto the bindings for.
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
      return setmetatable({ title = "Add bookmark", }, self:repl_list_meta(args))
   end,
}
local Enter = c.metatable_of(c.copy_meta(listview.Base, mod_Enter))

local mod_BookmarksSearch = {
   -- Want the adding-entries js api too.
   to_js = c.copy_table(listview.Search.to_js, mod_Enter.to_js),
   
   repl_list = function(self, args, view, meta)
      local got = listview.Search.repl_list(self, args, view, meta)
      got.above_title = self:asset("parts/enter_span")
      return got
   end,
}

local BookmarksSearch = c.metatable_of(c.copy_meta(listview.Search, mod_BookmarksSearch))

local function mk_page(meta, name)
   local page = setmetatable({where="listview/bookmarks", log=bookmarks}, meta)
   return paged_chrome.templated_page(page, name)
end

local bookmarks_paged = {
   default_page = "search",
   enter  = mk_page(Enter, "enter"),
   search = mk_page(BookmarksSearch, "search"),
   aboutChrome = listview.new_AboutChrome("listview/bookmarks", bookmarks),
}

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
