
local config = globals.listview_oldBookmarks or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local OldBookmarksEntry = require "listview.oldBookmarks.OldBookmarksEntry"

local OldBookmarks = c.copy_meta(require("sql_help").SqlHelp)
OldBookmarks.values = OldBookmarksEntry.values

-- Scratch some search matchabled that arent allowed.
OldBookmarks.searchinfo.matchable = {"-", "not:", "\\-", "or:",
                                     "uri:", "title:",
                                     "urilike:", "titlelike:",
                                     "before:", "after:", "limit:"}

function OldBookmarks:config() return config end

function OldBookmarks:initial_state()
   local html_calc = c.copy_table(require("listview.entry_html").default_html_calc)
   html_calc.tags_text = function(self, _)
      local got = rawget(self, "tags")
      if not got or type(got) == "function" then
         return " "
      else
         return got
      end
   end
   return { html_calc = html_calc }
end

function OldBookmarks:oldBookmarks_entry(entry)
   entry.origin = self
   return setmetatable(entry, OldBookmarksEntry)
end

OldBookmarks.entry_fun = OldBookmarks.oldBookmarks_entry

return c.metatable_of(OldBookmarks)
