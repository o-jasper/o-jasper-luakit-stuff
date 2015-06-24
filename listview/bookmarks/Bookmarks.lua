--  Copyright (C) 24-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local config = globals.listview_bookmarks or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local domain_of_uri = require("o_jasper_common.fromtext.uri").domain_of_uri

local BookmarksEntry = require "listview.bookmarks.BookmarksEntry"

local SqlHelp = require("sql_help").SqlHelp

local This = c.copy_meta(SqlHelp)
This.values = BookmarksEntry.values

This.cur_id_add = 0
This.entry_meta = BookmarksEntry

function This:config() return config end

local function disannoy_filename(file)
   local function handler(c)
      local respond = {
         [" "] = "_", ["\n"] = "_", ["\t"] = "_",
      }
      if respond[c] then return respond[c] end
      return string.format ("%%%02X", string.byte(c))
   end
   return string.gsub(file, [[ ][()<>$|&~"']], handler)
end

function This:default_new_data_uri_fun()
   local config = self:config()
   local topicsdir = config.topicsdir or ((os.getenv("HOME") or "TODO") .. "/topics")
   -- Topics named by tags.
   local topics    = config.topics or {"entity", "idea", "project", "data_source", "vacancy"}

   return function(entry)
      local name = "other"
      for _,iter_name in pairs(topics) do
         if self:has_tag(entry.id, name) then name = iter_name break end
      end
      -- TODO file-appropriatize the title.
      local dir = string.format("%s/%s/%s_%s", topicsdir, name,
                                domain_of_uri(entry.to_uri),
                                disannoy_filename(entry.title))
      local n, opened = 0, io.open(dir)
      while opened do  -- Count up until no longer taken.
         io.close(opened)
         n = n + 1
         opened = io.open(dir .. "_" .. tostring(n))
      end
      return dir .. ((n == 0 and "") or "_" .. tostring(n))
   end
end

function This:default_new_data_uri(entry)
   return (self:config().default_new_data_uri_fun or self:default_new_data_uri_fun())(entry)
end

-- Apply the defaults.. I dont want to depend on the above being perfectly
-- deterministic forever.
function This:update(entry)
   if entry.data_uri == "" then entry.data_uri = self:default_new_data_uri(entry) end
   return SqlHelp.update(self, entry)
end

function This:enter(entry)
   if entry.data_uri == "" then entry.data_uri = self:default_new_data_uri(entry) end
   return SqlHelp.enter(self, entry)
end

return c.metatable_of(This)
