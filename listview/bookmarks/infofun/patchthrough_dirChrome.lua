-- Patches through dirchrome information.

local lfs = require "lfs"

local bookmarks_config = (globals.listview or {}).bookmarks or {}
local config = bookmarks_config.patchthrough or {}

local c = require "o_jasper_common"

local Public = {}

local DirSearch_infofun = require("listview.fn_infofun_ize")(require("dirChrome.DirSearch"))
local dir_fun  = require "dirChrome.dir_fun"

function Public.newlist(creator, entry)
   local data_uri = entry.data_uri
   -- Get the data uri if not already exists.
   if data_uri and data_uri ~= "" and lfs.attributes(data_uri) then
      local args = {"search", dir_fun(data_uri), {"dirChrome", "listview"}, as_info=true}
      -- Probably doesnt work _because accessing items is used to set items_
      return {DirSearch_infofun.new(args)}
   end
   return {}
end

return Public
