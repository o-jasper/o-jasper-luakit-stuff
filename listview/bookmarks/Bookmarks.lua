
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
      local t_ms = c.cur_time.ms()
      if t_ms ~= self.last_t_ms then
         self.cur_id_add = 0
      else
         self.cur_id_add = self.cur_id_add + 1
      end
      add.id = 1000*t_ms + self.cur_id_add  -- NOTE: obviously not foolproof.
      self.last_t_ms = t_ms

--      for k,v in pairs(add) do print(k,v) end
      -- Pass on the rest of the responsibility upstream.
      return SqlHelp.enter(self, add)
   end,

   initial_state = function(self)
      local html_calc = c.copy_table(entry_html.default_html_calc)
      html_calc.identifier = function(entry, _)
         local val = entry[entry.values.idname]
         return string.format("%d%d",  -- Ugly way to show the entire number.
                              math.floor(val/1000000000),
                              math.floor(val%1000000000))
      end
--      html_calc.data_uri = function(entry, _)
--         return string.format("DATAURI:%s", entry.data_uri)
--      end
      return { html_calc=html_calc }
   end,
}

for k,v in pairs(addfuns) do Bookmarks[k] = v end

return c.metatable_of(Bookmarks)
