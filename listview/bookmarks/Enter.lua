
local c = require("o_jasper_common")

local this = c.copy_meta(listview.Base)

this.to_js = {
   manual_enter = function(self)
      return function(inp)
         if not inp.data_uri or inp.data_uri == "" then
            inp.data_uri = default_data_uri_fun(self)
            end
         add = {
            id = inp.id,  -- Potentially not provided.
            created = c.cur_time.s(),
            to_uri = inp.uri or "",
            title = inp.title or "",
            desc = inp.desc or "",
            data_uri = inp.data_uri or "",  -- Empty strings are can be auto-reinterpreted.
               --(these are not done directly)
            tags = lousy.util.string.split(inp.tags, "[,; ]+")
         }
         self.log:update_or_enter(add)
      end
   end,
}

local plus_cmd_add = require "listview.bookmarks.common".plus_cmd_add

function this:repl_list(args)
   local ret = { title = "Add bookmark", }
   plus_cmd_add(ret, self.log)
   return ret
end

return c.metatable_of(this)
