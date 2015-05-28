--  Copyright (C) 24-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local config = globals.listview_bookmarks or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"

local SqlHelp = require("sql_help").SqlHelp
local Bookmarks = c.copy_meta(SqlHelp)

local entry_html = require "listview.entry_html"

local BookmarksEntry = require "listview.bookmarks.BookmarksEntry"
Bookmarks.values = BookmarksEntry.values

-- Bookmarks.searchinfo.matchable -- All of them.
-- TODO add data_uri: stuff.

local addfuns = {
   cur_id_add = 0,

   entry_meta = BookmarksEntry,

   config = function(self) return config end,
   
   -- State for the html writer.
   initial_state = function(self)
      local mod_html_calc = {
         data_uri = function(entry, _)
            if not entry.data_uri or entry.data_uri == "" then
               return [[<span class="minor">(no data uri)</span>]]
            else
               return entry.data_uri
            end
         end,
         title = function(entry, _)
            return entry.title or entry.uri or "(no title)"
         end
      }
      local html_calc = c.copy_table(entry_html.default_html_calc)
      for k,v in pairs(mod_html_calc) do html_calc[k] = v end
      return { html_calc=html_calc }
   end,
}


for k,v in pairs(addfuns) do Bookmarks[k] = v end

return c.metatable_of(Bookmarks)
