
local c = require "o_jasper_common"

local config = (globals.listview or {}).bookmarks or {}

local topicsdir = config.topicsdir or ((os.getenv("HOME") or "TODO") .. "/topics")   -- TODO
local topics    = config.topics or {"entity", "idea", "project", "data_source", "vacancy"}

local bookmarks  = require "listview.bookmarks.bookmarks"

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

local This = c.copy_meta(require "listview.Base")

This.to_js = {
   manual_enter = function(self)
      return function(inp)
         if not inp.data_uri or inp.data_uri == "" then
            inp.data_uri = default_data_uri(self)
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

function This:repl(args)
   local ret = { title = "Add bookmark", }
   plus_cmd_add(ret, self.log)
   return ret
end

return c.metatable_of(This)
