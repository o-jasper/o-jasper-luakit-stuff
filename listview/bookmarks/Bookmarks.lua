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
This.values = BookmarksEntry.values

This.cur_id_add = 0
This.entry_meta = BookmarksEntry

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
