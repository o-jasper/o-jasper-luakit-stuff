--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local AboutChrome = require "listview.AboutChrome"
local DirSearch = require "dirChrome.DirSearch"

local dir_fun  = require "dirChrome.dir_fun"

local function figure_path(args)
   return string.sub(args.path, #("search/") + 1)
end
local function figure_Dir(args) return dir_fun(figure_path(args)) end

local where = {"dirChrome", "listview"}

local pages = {
   default_name = "search",
   search = function(args)
      return DirSearch.new{"search", figure_Dir(args), where}
   end,
   aboutChrome = function(args)
      -- NOTE: inefficient, it mostly doesnt care about the result of dir_fun.
      return AboutChrome.new{"aboutChrome", figure_Dir(args), where}
   end,
}
local Public = {
   dirChrome = {
      chrome_name = "dirChrome",
      pages = pages
   }
}

-- Grabbing another `luakit://` name.
local config = globals.dirChrome or {}

if config.take_dir_chrome then  -- Take over the 'plain name'. (default:no)
   paged_chrome.paged_chrome("dir", dir_paged)
end

-- Add binding.
local function on_command(w, query)
   w:new_tab("luakit://dirChrome/search/" .. (query or ""))
end

add_cmds({ lousy.bind.cmd("dirChrome", on_command) })

return Public
