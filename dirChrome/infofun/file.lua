-- Shows readme functions and/or 

local config_from = (globals.dirChrome or {}).infofun or {}
-- Better not use `config.html`, add the asset.
local config = config_from.file or config_from.basic_file or {}

local c = require "o_jasper_common"
local lfs = require "lfs"

local This = c.copy_meta(require "dirChrome.infofun.show_1")

function This.maybe_new(creator, entry)
   local e = lfs.attributes(entry.dir .. "/" .. entry.file)
   if e then
      for k, v in pairs(entry) do e[k] = v end
      if not string.match(entry.file, "^[.]#.+") then
         return setmetatable({ from_dir=creator.from_dir, e=e }, This)
      end
   end
end

function This:priority()
   return 0
end

This.asset_file = "parts/show_elaborate.html"

return c.metatable_of(This)
