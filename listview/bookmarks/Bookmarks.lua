local config = globals.listview_bookmarks or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"

local SqlHelp = require("sql_help").SqlHelp
local Bookmarks = c.copy_meta(SqlHelp)

local entry_html = require("listview.entry_html")

local BookmarksEntry = require "listview.bookmarks.BookmarksEntry"
Bookmarks.values = BookmarksEntry.values

-- Bookmarks.searchinfo.matchable -- All of them.
-- TODO add data_uri: stuff.

local addfuns = {
   cur_id_add = 0,

   config = function(self) return config end,

   bookmark_entry = function(self, entry)
      entry.origin = self
      return setmetatable(entry, BookmarkEntry)
   end,
   
   listfun = function(self, list)
      for _, data in pairs(list) do
         data.origin = self
         setmetatable(data, BookmarksEntry)
      end
      return list
   end,

   enter = function(self, add)
      if not add.id then
         local t_ms = c.cur_time.ms()
         if t_ms ~= self.last_t_ms then
            self.cur_id_add = 0
         else
            self.cur_id_add = self.cur_id_add + 1
         end
         add.id = 1000*t_ms + self.cur_id_add  -- NOTE: obviously not foolproof.
         self.last_t_ms = t_ms
      end
      -- Pass on the rest of the responsibility upstream.
      return SqlHelp.enter(self, add)
   end,

   -- State for the html writer.
   initial_state = function(self)
      local html_calc = c.copy_table(entry_html.default_html_calc)
      local mod_html_calc = {
         identifier = function(entry, _)
            local val = entry[entry.values.idname]
            return string.format("%d%d",  -- Ugly way to show the entire number.
               math.floor(val/1000000000),
                              math.floor(val%1000000000))
         end,
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
      for k,v in pairs(mod_html_calc) do html_calc[k] = v end
      return { html_calc=html_calc }
   end,
}

for k,v in pairs(addfuns) do Bookmarks[k] = v end

return c.metatable_of(Bookmarks)
