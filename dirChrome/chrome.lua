--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require "listview"
local dir_fun  = require "dirChrome.dir_fun"

local paged_chrome = require("paged_chrome")

local config = globals.dirChrome or {}
config.page = config.page or {}
-- If you specify a config.db, it'll load everything into that,
--  otherwise, a temporary db.

local run = {}

local function chrome_describe()
   assert(log)
   
   local where = config.assets or {}
   table.insert(where, "dirChrome")
   table.insert(where, "listview")
   local pages = {
      default_name = "search",
      search = function(args)
         return listview.new_Search(config.db or dir_fun(string.sub(args.path, 7)),
                                    where)
      end,
      aboutChrome = function(args)
         -- NOTE: inefficient, it mostly doesnt care about the result of dir_fun.
         return listview.new_AboutChrome(config.db or dir_fun(string.sub(args.path, 7)),
                                         where)
      end,
   }

   pages.search.limit_cnt = config.page.cnt or 20
   pages.search.limit_step = config.page.step or pages.search.step_cnt
   return pages
end

-- Make the chrome page.
local dir_paged = chrome_describe()
paged_chrome.paged_chrome("listviewDir", dir_paged)

if config.take_dir_chrome then  -- Take over the 'plain name'. (default:no)
   paged_chrome.paged_chrome("dir", dir_paged)
end

-- Add binding.
local function on_command(w, query)
   run.to_dir = query  -- Bit "global-value-ie.
   local v = w:new_tab("luakit://dirChrome/search")
end

add_cmds({ loudy.bind.cmd("dirChrome", on_command) })
