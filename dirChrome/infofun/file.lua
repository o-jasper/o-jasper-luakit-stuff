-- Shows readme functions and/or 

local config_from = (globals.dirChrome or {}).infofun or {}
-- Better not use `config.html`, add the asset.
local config = config_from.file or config_from.basic_file or {}

local c = require "o_jasper_common"
local lfs = require "lfs"
local entry_html = require "listview.entry_html" -- TODO there are simularities.. maybe

local this = {}

function this.maybe_new(path, file)
   return setmetatable({ path=path, file=file }, this)
end

function this:priority()
   return 0
end

function this:repl(asset_fun)
   local fp = self.path .. "/" .. self.file

   local funs = {
      slashifdir = function() return mode == "directory" and "/" or " " end,
      
      modification_date = function(attrs) return os.date("%c", attrs.modification) end,
      change_date       = function(attrs) return os.date("%c", attrs.change) end,
      access_date       = function(attrs) return os.date("%c", attrs.access) end,

      default = function(_, _, key)
         return string.match(key, "^[/_.%w]+$") and asset_fun(key)
      end,
   }
   local pattern_funs = {
      ["^date_"] = function(attrs, _, key)
         local inside = string.match(key, "_[%w]")
         local got = attrs[string.sub(inside, 2)]
         if type(got) == "number" then
            return os.date(string.sub(string.match(key, "_[%w]$") or "_%c", 2),
                           got)
         end
      end,
   }
   local attrs = lfs.attributes(fp)
   attrs.file = self.file
   attrs.path = self.path
   return c.repl(attrs, nil, attrs, funs, pattern_funs)
end

this.asset_file = "parts/show_elaborate.html"
function this:repl_pattern(asset_fun)
   return config.html or asset_fun(self.asset_file)
end

function this:html(asset_fun)
   return c.apply_subst(self:repl_pattern(asset_fun), self:repl(asset_fun))
end

return c.metatable_of(this)
