--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local AboutChrome = require "listview.AboutChrome"
local DirSearch = require "dirChrome.DirSearch"

local dir_fun  = require "dirChrome.dir_fun"

local paged_chrome = require("paged_chrome")

local function figure_path(args) return string.sub(args.path, 7) end
local function figure_Dir(args)  return dir_fun(figure_path(args)) end

local function chrome_describe()
   local where = {"dirChrome", "listview"}
   return {
      default_name = "search",
      search = function(args)
         return DirSearch.new{"search", figure_Dir(args), where}
      end,
      aboutChrome = function(args)
         -- NOTE: inefficient, it mostly doesnt care about the result of dir_fun.
         return AboutChrome.new{"aboutChrome", figure_Dir(args), where}
      end,
   }
end

-- Make the chrome page.
local dir_paged = chrome_describe()
paged_chrome.chrome("dirChrome", dir_paged)

-- Grabbing another `luakit://` name.
local config = globals.dirChrome or {}

if config.take_dir_chrome then  -- Take over the 'plain name'. (default:no)
   paged_chrome.paged_chrome("dir", dir_paged)
end

-- Add binding.
local function on_command(w, query)
   w:new_tab("luakit://dirChrome/search" .. (query or ""))
end

add_cmds({ lousy.bind.cmd("dirChrome", on_command) })
