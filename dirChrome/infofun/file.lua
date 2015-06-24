-- Shows readme functions and/or 

local config_from = (globals.dirChrome or {}).infofun or {}
-- Better not use `config.html`, add the asset.
local config = config_from.file or config_from.basic_file or {}

local c = require "o_jasper_common"
local lfs = require "lfs"

local This = c.copy_meta(require "dirChrome.infofun.show_1")

function This.new(args)
   local ret = { e = args.e, from_dir=args.creator.path }
   -- More more info from lfs.attributes.(dont override)
   for k, v in pairs(lfs.attributes(args.e.dir .. "/" .. args.e.file) or {}) do
      ret.e[k] = ret.e[k] or v
   end
   return setmetatable(ret, This)
end

function This:priority()
   return (string.match(self.e.file, "^[.]#.+") and -2) or 0
end

This.asset_file = "parts/show_elaborate.html"

return c.metatable_of(This)
