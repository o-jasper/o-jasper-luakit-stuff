--  Copyright (C) 24-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local config = globals.listview_bookmarks or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"

local BookmarksEntry = require "listview.bookmarks.BookmarksEntry"

local SqlHelp = require("sql_help").SqlHelp

local This = c.copy_meta(SqlHelp)
This.__name = "Bookmarks"

This.values = BookmarksEntry.values
local via_link_columns = {"from_id", "to_id"}
This.values.via_link = {  -- TODO implement this way.
   table_name = "via_link",
   columns = via_link_columns,
   
   ids = via_link_columns,
   int_els = via_link_columns,
}

This.cur_id_add = 0
This.entry_meta = BookmarksEntry

This.cmd_dict.get_to_uri = "SELECT {%idname} FROM {%table_name} WHERE to_uri == ?"

function This:config() return config end

function This:topicsdir() 
   return self:config().topicsdir or ((os.getenv("HOME") or "TODO") .. "/topics")
end

function This:tag_topics()
   return self:config().tag_topics or {entity=true, idea=true, project=true, 
                                       data_source=true, refer=true, vacancy=true
                                      }
end

function This:init()
   SqlHelp.init(self)
   -- Make all the directories needed, if do not exist yet.
   local lfs = require "lfs"
   lfs.mkdir(self:topicsdir())
   for name, to in pairs(self:tag_topics()) do
      lfs.mkdir(self:topicsdir() .. "/" .. (to == true and name or to))
   end
end

function This:default_new_data_uri_fun()
   local config = self:config()
   local function figure_name(entry)
      for name, to in pairs(self:tag_topics()) do
         -- Search in the to-be-set entry, not the DB.
         for _, tag in pairs(entry.tags) do
            if name == tag then
               return (to == true and name) or to
            end
         end
      end
   end

   return function(entry)
      local name = figure_name(entry) or "other"
      -- TODO file-appropriatize the title.
      local dir = string.format("%s/%s/%s_%s", self:topicsdir(), name,
                                c.fromtext.domain_of_uri(entry.to_uri),
                                c.fromtext.disannoy_filename(entry.title))
      local n, opened = 0, io.open(dir)
      while opened do  -- Count up until no longer taken.
         io.close(opened)
         n = n + 1
         opened = io.open(dir .. "_" .. tostring(n))
      end
      local lfs = require "lfs"
      dir = dir .. ((n == 0 and "") or "_" .. tostring(n))
      lfs.mkdir(dir)
      return dir
   end
end

function This:ensure_data_uri(entry)
   if not entry.data_uri or entry.data_uri == "" then
      entry.data_uri = self:default_new_data_uri(entry)
   end
end

function This:default_new_data_uri(entry)
   return (self:config().default_new_data_uri_fun or self:default_new_data_uri_fun())(entry)
end

function This:enter(entry)
   self:ensure_data_uri(entry)
   -- Find if uri already obtained.
   local got = self:sqlcmd("get_to_uri"):exec{entry.to_uri}
   --assert(#got > 1, "One-bookmark-per-uri failed before?")
   if #got > 0 then entry.id = got[1].id end

   return SqlHelp.enter(self, entry)
end

return c.metatable_of(This)
