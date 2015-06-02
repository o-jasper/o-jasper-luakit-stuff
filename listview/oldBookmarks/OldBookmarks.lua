
local config = globals.listview_oldBookmarks or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local OldBookmarksEntry = require "listview.oldBookmarks.OldBookmarksEntry"

local this = c.copy_meta(require("sql_help").SqlHelp)
this.values = OldBookmarksEntry.values

-- Scratch some search matchabled that arent allowed.
this.searchinfo.matchable = {"-", "not:", "\\-", "or:",
                                     "uri:", "title:",
                                     "urilike:", "titlelike:",
                                     "before:", "after:", "limit:"}

function this:config() return config end

function this:initial_state()
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

function this:oldBookmarks_entry(entry)
   entry.origin = self
   return setmetatable(entry, OldBookmarksEntry)
end

this.entry_fun = OldBookmarks.oldBookmarks_entry

return c.metatable_of(this)
